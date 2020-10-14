function [Synth_seq, M] = invEdgeCoeff(S, g, Coeff, h)
% Usage: [Synth_seq, M] = invEdgeCoeff(S, g, Coeff, filterh)
%
% Input :  S             : List of sequences
%          Coeff         : Scaling and wavelet coefficients
%          g             : Input graph of nodes
%          inv_filterh   : Filter to use. It can be the filter name (e.g. 'db2')
%               or the line vector of the decomposition filter h
% Output : Synth_seq     : Synthetized sequences
%          M_struc       : Synthetized matrix

    if nargin ~= 4
        error('Invalid usage');
    end

    Synth_seq=[];
    Edges_list = sortrows(edges(g));
    [nV, nE] = size(g);
    M=zeros(nV);
    % Debug
    dbstop if error

    % Construct filters
    if ischar(h)
        [LO_D, HI_D] = wfilters(h);
        h = sqrt(2) .* flipdim(LO_D, 2);
        g = sqrt(2) .* flipdim(HI_D, 2);
    end

    [Hedge, Gedge, Pre, Post] = computeEdgeMat(h);
    N = size(Hedge, 1);

    % Get parameters
    LS = size(fieldnames(S), 1);
    J = size(fieldnames(Coeff), 1) - 1;

    % Use matlab waitbar
    stop=false;
    Bar = waitbar(0.0, 'Inverse WavGraph Processing...', 'CreateCancelBtn',@CancelButton);


    % Loops
    for v = 1 : LS
        if stop
            break;
        end
        % Original sequence stored in S.kn.seq
        Seq = getfield(S, strcat('k', int2str(v)), 'seq');
        LSeq = length(Seq);

        % Reconstruct signal
        % Coefficients are in S.kn.wavj and S.kn.scaJ
        C = getfield(S, strcat('k', int2str(v)), strcat('sca', int2str(J)));
        for j = J : -1 : 1
            D = getfield(S, strcat('k', int2str(v)), strcat('wav', int2str(j)));

            % Expand sequences
            Lc = size(C, 1);
            FilterM = zeros(2.*Lc, 2.*Lc);
            S_exp = zeros(2.*Lc, 1);
            S_exp(1:2:end) = C;
            S_exp(2:2:end) = D;
            
            % Construct filters matrices
            H = zeros(Lc, 2.*Lc);
            G = H;
            H(1:size(Hedge, 1), 1:size(Hedge, 2)) = Hedge;
            G(1:size(Gedge, 1), 1:size(Gedge, 2)) = Gedge;
            for k = N : Lc - 1
                for l = 0 : 2.*Lc - 1
                    try
                        H(k+1, l+1) = h(l - 2*k + N) ./ sqrt(2);
                        G(k+1, l+1) = g(l - 2*k + N) ./ sqrt(2);
                    catch
                        H(k+1, l+1) = 0;
                        G(k+1, l+1) = 0;
                    end
                end
            end
            FilterM(1:2:end, :) = H;
            FilterM(2:2:end, :) = G;
            I_Lc = eye(Lc);
            inv_FilterM = inv(FilterM);
            Synth = inv_FilterM * S_exp;
            if j == 1
                Synth = Synth(1:LSeq);
                M(Edges_list(v, 1), Edges_list(v, 2)) = Synth(1);
                M(Edges_list(v, 2), Edges_list(v, 1)) = Synth(1);
            end
            Synth_seq = setfield(Synth_seq, strcat('k', int2str(v)), strcat('synth', int2str(j)), Synth);
            C=Synth;
        end
        waitbar(v/LS, Bar);
    end

    if ~stop
        delete(Bar);
    end

    function CancelButton(a1, a2)
        stop = true;
        disp('Aborted');
        M=[];
        if exist('Bar') 
            delete(Bar);
        end
    end
end
