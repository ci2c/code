function [S, Coeff] = wav_graph(g, M, filterh, J)
% Usage: [S, COEFF] = wav_graph(G, MATRIX, h, J)
%
% Inputs:
%     G        : Input graph of nodes (not graph of lines)
%     MATRIX   : Connectivity matrix of G containing continuous values
%     h        : Can be the scaling function filter
%                Or can be the wavelet name, for example 'db2'. 
%     J        : Number of decomposition scale
%
% Output:
%    S         : Structure grouping all sequences such as : 
%                * S.kn.seq is the original sequence at edge n
%                * S.kn.wavj are the wavelet coeffs of S.kn at level j=1..J
%                * S.kn.scaJ are the scaling coeffs of S.kn at level J
%
%    COEFF     : Structure of graphs of the wavelet and scaling
%    coefficients
%
% This function automatically computes the line graph
%
% Note that the wavelet decomposition scheme is the classical one :
% reccursive decomposition of the low pass component. Other schemes require
% a bit of coding.
%
% See also: WFILTERS
%
% Pierre Besson, January 2009

    if nargin ~= 4
        error('Invalid expression');
    end

    if ischar(filterh)
        [LO_D, HI_D] = wfilters(filterh);
        filterh = sqrt(2) .* flipdim(LO_D, 2);
        filterg = sqrt(2) .* flipdim(HI_D, 2);
    end

    [Hedge, Gedge, Pre, Post] = computeEdgeMat(filterh); % Compute edge filters

    h = graph;
    line_graph(h, g); % h : Line graph of g
    Edges_list = sortrows(edges(g)); 
    V = getLineGraph(g, M); % Vector of values corresponding to edges : V(n) is the connectivity attributed to edge n
    S = []; % Sequence
    M_temp = zeros(size(M));

    % Init scaling and wavelet coefficients
    Coeff = [];
%     for j = 1 : J
%         Coeff = setfield(Coeff, strcat('wav', int2str(j)), zeros(size(M)));
%     end
%     Coeff = setfield(Coeff, strcat('sca', int2str(J)), zeros(size(M)));

    % Use matlab waitbar
    stop=false;
    Bar = waitbar(0.0, 'WavGraph Processing...', 'CreateCancelBtn',@CancelButton);
    LV=length(V);
    wav_coeff = zeros(size(M, 1),size(M, 1),J);
    sca_coeff = zeros(size(M));
    %
    for k = 1 : LV
        SEQ = getSequence(h, V, k);
        S = setfield(S, strcat('k', int2str(k)), 'seq', SEQ);
        [C, D] = getEdgeCoeff(filterh, filterg, Hedge, Gedge, SEQ, J);
        for j = 1 : J
%             M_temp = getfield(Coeff, strcat('wav', int2str(j)));
            Temp = getfield(D, strcat('j', int2str(j)));
%             M_temp(Edges_list(k, 1), Edges_list(k, 2)) = Temp(1);
%             M_temp(Edges_list(k, 2), Edges_list(k, 1)) = Temp(1);
%             Coeff = setfield(Coeff, strcat('wav', int2str(j)), M_temp);
%             S = setfield(S, strcat('k', int2str(k)), strcat('wav', int2str(j)), Temp);
            wav_coeff(Edges_list(k, 1), Edges_list(k, 2), j) = Temp(1);
            wav_coeff(Edges_list(k, 2), Edges_list(k, 1), j) = Temp(1);
        end
%         M_temp = getfield(Coeff, strcat('sca', int2str(J)));
        Temp = getfield(C, strcat('j', int2str(J)));
%         M_temp(Edges_list(k, 1), Edges_list(k, 2)) = Temp(1);
%         M_temp(Edges_list(k, 2), Edges_list(k, 1)) = Temp(1);
%         Coeff = setfield(Coeff, strcat('sca', int2str(J)), M_temp);
%         S = setfield(S, strcat('k', int2str(k)), strcat('sca', int2str(J)), Temp);
        sca_coeff(Edges_list(k, 1), Edges_list(k, 2)) = Temp(1);
        sca_coeff(Edges_list(k, 2), Edges_list(k, 1)) = Temp(1);
        waitbar(k/LV, Bar);
        if stop
           break;
        end
    end
    
    for j = 1 : J
%         Coeff = setfield(S, strcat('k', int2str(k)), strcat('wav', int2str(j)), wav_coeff(:,:,j));
        Coeff = setfield(Coeff, strcat('wav', int2str(j)), wav_coeff(:,:,j));
    end
%     Coeff = setfield(S, strcat('k', int2str(k)), strcat('sca', int2str(J)), sca_coeff);
    Coeff = setfield(Coeff, strcat('sca', int2str(J)), sca_coeff);

    if ~stop
       delete(Bar);
       free(h);
    end
    free(h); % for no bar

    function CancelButton(a1, a2)
        stop = true;
        disp('Aborted');
        S = [];
        Coeff = [];
        free(h);
        if exist('Bar') 
            delete(Bar);
        end
    end
end
