function [res_ica]=st_do_sica(data,opt)

% ICA processing of 2D dataset
%
% [res_ica]=st_do_sica(data,algo,param,opt)
% 
% INPUTS
% data          2D matrix (size n*p) with p samples of n mixed channels
% opt   (structure) opt.algo   (optional, default 'Infomax') the type of algorithm to be used
%                               for the sica decomposition: 'Infomax', 'Fastica-Def'
%                               or 'Fastica-Sym, 'Infomax-Prior'.
%                   opt.type_nb_comp:  (optional, default 1) 
%                                      0, to choose directly the number of component to compute
%                                      1, to choose the ratio of the variance to keep 
%                   opt.param_nb_comp: if type_nb_comp = 0, number of components to
%                                      compute
%                                      if type_nb_comp = 1, ratio of the variance to keep
%                                       (default, 90 %)  
%                   opt.save_residus: 1 to save residus, 0 otherwise
%                   opt.prior:  (used if opt.algo = 'Infomax-Prior') 2D matrix whose columns are the temporal priors 
%
% OUTPUTS
% res_ica       structure containing: 
%                   res_ica.S 	= independent components matrix
%                   res_ica.A 	= matrix of associated factors (mixing matrix)
%                   res_ica.nbcomp = number of components calculated
%                   res_ica.algo = algorithm use to process ICA (Fastica or
%                   Infomax)
%
% COMMENTS
% Vincent Perlbarg 02/07/05

% Copyright (C) 07/2009 Vincent Perlbarg, LIF/Inserm/UPMC-Univ Paris 06, 
% vincent.perlbarg@imed.jussieu.fr
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

if isfield(opt,'type_nb_comp')
    type_nb_comp = opt.type_nb_comp;
else
    type_nb_comp = 1;
    param_nb_comp = 0.9;
end

if isfield(opt,'param_nb_comp')
    param_nb_comp = opt.param_nb_comp;
end

if isfield(opt,'algo')
    algo = opt.algo;
    if strcmp(algo,'Infomax-Prior')
        if isfield(opt,'prior')
            prior = opt.prior;
        else
            fprintf('You must specify the priors for Infomax-Prior/n');
            return
        end
    end        
else
    algo = 'Infomax';
end

if ~isfield(opt,'save_residus')
    opt.save_residus = 1;
end

if type_nb_comp == 1 %energie  conserver sans gui
        
    covarianceMatrix = cov(data', 1);
    [E, D] = eig(covarianceMatrix);
    [eigenval,index] = sort(diag(D));
    index=rot90(rot90(index));
    eigenvalues=rot90(rot90(eigenval))';
    eigenvectors=E(:,index);
	
    r = rank(data);
	for i=1:r
	    ener_ex(i) = sum(eigenvalues(1:i))/sum(eigenvalues);
	end
	nbcomp = min(find(floor(ener_ex - ones(1,r)*param_nb_comp)>=0));
elseif type_nb_comp==0 %param=nbcomp
    if param_nb_comp == -1
        covarianceMatrix = cov(data', 1);
        [E, D] = eig(covarianceMatrix);
        [eigenval,index] = sort(diag(D));
        eigenvalues=rot90(rot90(eigenval))';
        nsamp = size(data,2);
        [nbcomp] = st_estimate_ncomps(eigenvalues,nsamp);
    else
        nbcomp = param_nb_comp;
    end
end

varData = (1/(size(data,1)-1))*sum((data').^2,2);
residus = [];

if strcmp(algo,'Infomax')
    [weights,sphere,residus] = runica2(data,'sphering','off','ncomps',nbcomp,'pca',nbcomp,'verbose','on','maxsteps',300);
    W=weights*sphere;
    a = pinv(W);
    IC=W*data;
    s=IC';
    for num_comp = 1:size(a,2)
        C = s(:,num_comp)*a(:,num_comp)';
        var_C=(1/(size(C,2)-1))*sum(C.^2,2);
        varCompRatio(:,num_comp) = var_C./varData;
        contrib(num_comp) = mean(varCompRatio(:,num_comp));
    end
elseif strcmp(algo,'Fastica-Def')
    [IC,a,W] = fastica(data,'numOfIC',nbcomp,'approach','defl');
    IC=W*data;
    s=IC';
    for num_comp = 1:size(a,2)
        C = s(:,num_comp)*a(:,num_comp)';
        var_C=(1/(size(C,2)-1))*sum(C.^2,2);
        varCompRatio(:,num_comp) = var_C./varData;
        contrib(num_comp) = mean(varCompRatio(:,num_comp));
    end
elseif strcmp(algo,'Fastica-Sym')
    [IC,a,W] = fastica(data,'numOfIC',nbcomp,'approach','symm');
    IC=W*data;
    s=IC';
    for num_comp = 1:size(a,2)
        C = s(:,num_comp)*a(:,num_comp)';
        var_C=(1/(size(C,2)-1))*sum(C.^2,2);
        varCompRatio(:,num_comp) = var_C./varData;
        contrib(num_comp) = mean(varCompRatio(:,num_comp));
    end
end

contrib = contrib(:);
[sortcontrib,index]=sort(contrib);
s = s(:,index(end:-1:1));
a = a(:,index(end:-1:1));
contrib = sortcontrib(end:-1:1);

res_ica.composantes = s;
clear s
res_ica.poids = a;
clear a
res_ica.nbcomp = nbcomp;
res_ica.algo = algo;
%res_ica.varatio = varCompRatio;
res_ica.contrib = contrib;
if opt.save_residus
    res_ica.residus = residus';
end

