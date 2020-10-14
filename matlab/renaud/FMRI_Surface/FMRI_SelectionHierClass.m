function [P_final,R_final,U_final] = FMRI_SelectionHierClass(hier,compsName_lh,compsName_rh,sessname)

% Procedure for automatic selection of classes from hierarchy

Thres_R = 1;
R_mini  = 0.5;
U_mini  = 0.75;
maxNC   = 70;
%maxNC = round(length(listSelectedData)*1.5);

% disp('initialization...')
P_final    = zeros(length(compsName_lh),1);
R_final    = [];
U_final    = [];
numCOI     = 1;
test       = 1;
nc         = 1;
classified = [];
U_former   = 0;
R_former   = 1;
P_old      = FMRI_Hier2Partition(hier,nc,1);

while test
    
    nc = nc+1;
    
    P  = FMRI_Hier2Partition(hier,nc,1);
    R  = [];
    U  = [];
    for pp = 1:nc
        AA            = char(compsName_lh{find(P == pp)});
        [R(pp),U(pp)] = FMRI_ComputeScores(AA,sessname);
    end

    tt    = 1;
    testm = 0;
    while (tt <= nc-1) & (testm == 0)
        I = find(P_old == tt);
        if length(unique(P(I))) > 1
            testm    = 1;
            merge    = unique(P(I));
            U_values = U(merge);
            R_values = R(merge);
            U_old    = U_former(tt);
            R_old    = R_former(tt);
        end
        tt=tt+1;
    end
    
    test_R = R_values<=R_mini;
    test_U = U_values>=U_mini;
    II     = find(test_R==1);
    II2    = find(test_U==1);
    if ~isempty(II)
        
        ttest = zeros(1,length(II));
        for ff = 1:length(II)
            ttest(ff) = isempty(intersect(classified,find(P == merge(II(ff)))));
        end
        JJ = find(ttest>0);
        
        if length(JJ) == 2
            P_final(I)      = numCOI;
            classified      = unique([classified;I]);
            R_final(numCOI) = R_old;
            U_final(numCOI) = U_old;
            disp(['nb classes = ' num2str(numCOI)])
            numCOI          = numCOI + 1;
        elseif length(JJ) == 1
            KK = find(test_R==0);
            if R_values(KK)>R_mini && U_values(KK)>U_mini
                for ii=1:length(merge)
                    P_final(find(P == merge(ii))) = numCOI;
                    classified                    = unique([classified;find(P == merge(ii))]);
                    R_final(numCOI)               = R_values(ii);
                    U_final(numCOI)               = U_values(ii);
                    disp(['nb classes = ' num2str(numCOI)])
                    numCOI                        = numCOI + 1;
                end
            else
                P_final(find(P == merge(II(JJ)))) = numCOI;
                classified                        = unique([classified;find(P == merge(II(JJ)))]);
                R_final(numCOI)                   = R_values(II(JJ));
                U_final(numCOI)                   = U_values(II(JJ));
                disp(['nb classes = ' num2str(numCOI)])
                numCOI                            = numCOI + 1;
            end
   
        end
        
    elseif ~isempty(II2)
        
        ttest = zeros(1,length(II2));
        for ff = 1:length(II2)
            ttest(ff) = isempty(intersect(classified,find(P == merge(II2(ff)))));
        end
        JJ = find(ttest>0);
        for ii=1:length(JJ)
            P_final(find(P == merge(II2(JJ(ii))))) = numCOI;
            classified                             = unique([classified;find(P == merge(II2(JJ(ii))))]);
            R_final(numCOI)                        = R(merge(II2(JJ(ii))));
            U_final(numCOI)                        = U(merge(II2(JJ(ii))));
            disp(['nb classes = ' num2str(numCOI)])
            numCOI                                 = numCOI + 1;
        end
        
    end
    
    R_former = R;
    U_former = U;
    P_old    = P;
    if isempty(find(P_final == 0))
        test = 0;
    elseif nc == maxNC;
        % créer les classes restantes
        KK = find(P_final==0);
        TT = unique(P(KK));
        for gg = 1:length(TT)
            P_final(find(P==TT(gg))) = numCOI;
            disp(['nb classes = ' num2str(numCOI)])
            numCOI                   = numCOI + 1;
        end
        test = 0;
    end

end
