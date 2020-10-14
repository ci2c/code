function FMRI_SurfConnectivityMatrix(fspath,subjdir,subjlist,prefix,resClust,noderoi,selCOI,nb_tir)

listCOI = resClust.COI.num;
numCOI  = length(selCOI);
norm    = 1;

surf_lh = SurfStatReadSurf([fullfile(fspath,'surf/lh.white')]);
surf_rh = SurfStatReadSurf([fullfile(fspath,'surf/rh.white')]);

vertmax_lh = [];
vertmax_rh = [];
coord      = [];
maskClust  = [];

for k = 1:length(subjlist)

    disp('---------------------------------------------------');
    disp(['subject: ' subjlist{k}]);
    disp('---------------------------------------------------');
    
    List_lh = SurfStatListDir(fullfile(subjdir,subjlist{k},'surffmri',['lh.' prefix '*']));
    List_rh = SurfStatListDir(fullfile(subjdir,subjlist{k},'surffmri',['rh.' prefix '*']));
    Data    = SurfStatReadData([List_lh]);
    data_lh = Data.Data.Data;
    Data    = SurfStatReadData([List_rh]);
    data_rh = Data.Data.Data;
    nbleft  = size(data_lh,1);
    clear List_rh List_lh Data;
    
    decours1{k} = [];
        
    for j = 1:numCOI

        ind      = find(listCOI==selCOI(j));
        coord_lh = noderoi{ind,1}.coordidxs;
        coord_rh = noderoi{ind,2}.coordidxs;
        
        if(k==1)
            vertmax_lh  = [vertmax_lh noderoi{ind,1}.node_max];
            vertmax_rh  = [vertmax_rh noderoi{ind,2}.node_max];
            coord       = [coord surf_lh.coord(:,noderoi{ind,1}.node_max) surf_rh.coord(:,noderoi{ind,2}.node_max)];
            maskClust   = [maskClust j*ones(1,length(noderoi{ind,1}.node_max)+length(noderoi{ind,2}.node_max))];
        end
                
        decours = [];
        for n=1:length(coord_lh)

            vert    = coord_lh{n};
            tseries = data_lh(vert,:)';

            if norm == 1
                va = var(tseries);
                I=find(va==0);
                if length(I)~=0
                    J=find(va~=0);
                    tseries=tseries(:,J);
                end

                tseries = tseries_normalize(tseries);
            end
            decours(:,n) = mean(tseries,2);

        end

        %decours = st_detrend_array(decours,2);
        decours  = st_normalise(decours);
        decours1{k} = [decours1{k} decours];
        
        decours = [];
        for n=1:length(coord_rh)

            vert    = coord_rh{n};
            tseries = data_rh(vert,:)';

            if norm == 1
                va = var(tseries);
                I=find(va==0);
                if length(I)~=0
                    J=find(va~=0);
                    tseries=tseries(:,J);
                end

                tseries = tseries_normalize(tseries);
            end
            decours(:,n) = mean(tseries,2);

        end

        %decours = st_detrend_array(decours,2);
        decours  = st_normalise(decours);
        decours1{k} = [decours1{k} decours];

    end
    
end

tS{1} = donnees_vers_covariance_hierarchique(decours1,nb_tir);

tR{1} = covariance_vers_correlation(tS{1});
tP{1} = covariance_vers_corrpar(tS{1});
mtR   = echant_vers_stats(tR{1},'moy');
mtP   = echant_vers_stats(tP{1},'moy');

save(fullfile(subjdir,'surfnedica','ConnMatrix.mat'),'nb_tir','selCOI','mtR','mtP','coord','maskClust');

% entropie_totale{1} = covariance_vers_entropie(tS{1});
% integration_totale{1} = covariance_vers_integration_totale(tS{1});

% % Compute p-value:
% Pr = ComputePvalue(mtR,size(decours1{1},1));
% Pp = ComputePvalue(mtP,size(decours1{1},1));
% % [ir,jr] = find(Pr<0.05);  % find significant correlations
% % [ip,jp] = find(Pp<0.05);  % find significant correlations
% mtRthres = mtR;
% mtRthres(Pr>0.05) = 0;
% mtPthres = mtP;
% mtPthres(Pp>0.05) = 0;
% 
% save(fullfile(sesspath,'conn_matrix.mat'),'nb_tir','listcoi','mtR','mtP','mtRthres','mtPthres','coord','maskClust');

 
%% Connectivity matrix

selectionName = 'Selection 1';

% Correlation

handleMatrix11 = figure('Units','normalized','Name',['Correlation Matrix - Roi_level - ' selectionName],'Resize','on','Position',[0.3 0.0302734 0.5 0.42]);
%subplot(1,2,1)
imagesc(mtR,[-1 1])
title(['Correlation Matrix - Roi_level - ' selectionName],'Interpreter','none')
c1 = hot(256);
c2 = c1(:,[3 2 1]);
c= [c2(length(c1):-1:1,:) ; c1];
colormap(c(1:2:512,:))
colorbar
axis('square');

% Partial correlation

handleMatrix12 = figure('Units','normalized','Name',['Partial Correlation Matrix - Roi_level - ' selectionName],'Resize','on','Position',[0.3 0.0302734 0.5 0.42]);
%subplot(1,2,1)
imagesc(mtP,[-1 1])
title(['Partial Correlation Matrix - Roi_level - ' selectionName],'Interpreter','none')
c1 = hot(256);
c2 = c1(:,[3 2 1]);
c= [c2(length(c1):-1:1,:) ; c1];
colormap(c(1:2:512,:))
colorbar
axis('square');


function courbes2 = tseries_normalize(courbes)

courbes2 = courbes-ones([size(courbes,1) 1])*mean(courbes,1);
courbes2 = courbes2./(ones([size(courbes,1) 1])*sqrt((1/(size(courbes2,1)-1))*sum(courbes2.^2,1)));