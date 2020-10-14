function resClust = FMRI_ComputeStatsOnNetworks(resClust,groups,netw,nb_tir)

for g = 1:length(groups)
    
    data = {};
    maskClust = [];
    subj = groups{g};
    
    for k = 1:length(subj)
        data{k} = [];
        for i = 1:length(netw)
            data{k} = [data{k} resClust.roi{netw(i)}.meanBold{subj(k)}];
        end
    end
    maskClust = [];
    for i = 1:length(netw)
        maskClust = [maskClust netw(i)*ones(1,resClust.roi{netw(i)}.N)];
    end

    tS{g}  = donnees_vers_covariance_hierarchique(data,nb_tir);    
    tR{g}  = covariance_vers_correlation(tS{g});
    tP{g}  = covariance_vers_corrpar(tS{g});
    mtR{g} = echant_vers_stats(tR{g},'moy');
    mtP{g} = echant_vers_stats(tP{g},'moy');

    entropie_totale{g}    = covariance_vers_entropie(tS{g});
    integration_totale{g} = covariance_vers_integration_totale(tS{g});
    
    % intégration inter
    tI = zeros(length(netw),length(netw),size(tS{g},3));
    integration_intra{g} = zeros(1,size(tS{g},3));
    for ii = 1:length(netw)
        for jj = 1:length(netw)
            if jj~=ii
                AA = covariance_vers_entropie(tS{g}(find((maskClust==netw(ii))|(maskClust==netw(jj))),find((maskClust==netw(ii))|(maskClust==netw(jj))),:));
                tI(ii,jj,:) = covariance_vers_entropie(tS{g}(find((maskClust==netw(ii))),find((maskClust==netw(ii))),:)) + covariance_vers_entropie(tS{g}(find((maskClust==netw(jj))),find((maskClust==netw(jj))),:)) - AA;
            else
                tI(ii,jj,:) = covariance_vers_integration_totale(tS{g}(find((maskClust==netw(ii))),find((maskClust==netw(ii))),:));
                integration_intra{g} = integration_intra{g} + squeeze(tI(ii,jj,:))';
            end
        end
    end
    [mtI,vtI]              = echant_vers_stats(tI,'moy','std');
    integration_matrix{g}  = tI;
    mI(:,:,g)              = mtI;
    vI(:,:,g)              = vtI;
    integration_inter{g}   = integration_totale{g} - integration_intra{g};
    integration_ratio(g,:) = [mean(integration_inter{g}./integration_totale{g})' mean(integration_intra{g}./integration_totale{g})'];
    ratio_intra_inter(g,:) = integration_intra{g}./integration_inter{g};
        
    R_noi = zeros(length(unique(maskClust)),length(unique(maskClust)),nb_tir);
    P_noi = zeros(length(unique(maskClust)),length(unique(maskClust)),nb_tir);

    for ii = 1:length(unique(maskClust));
        for jj = 1:length(unique(maskClust));
            R_bloc = tR{g}(maskClust==netw(ii),maskClust==netw(jj),:);
            P_bloc = tP{g}(maskClust==netw(ii),maskClust==netw(jj),:);
            n = size(R_bloc,2);
            II = repmat(eye(size(R_bloc,1),size(R_bloc,2)),[1 1 nb_tir]);
            TT = tril(true(n),-1);
            if ii==jj
                R_tmp = reshape(R_bloc-II,[n*n nb_tir]);
                P_tmp = reshape(P_bloc-II,[n*n nb_tir]);
                Yr = R_tmp(TT,:);
                Yp = P_tmp(TT,:);
                R_noi(ii,jj,:) = mean(Yr,1);
                P_noi(ii,jj,:) = mean(Yp,1);
            else
                [n1,n2,n3] = size(R_bloc);
                R_noi(ii,jj,:) = mean(reshape(R_bloc,[n1*n2 n3]),1);
                P_noi(ii,jj,:) = mean(reshape(R_bloc,[n1*n2 n3]),1);
            end
        end
    end
    tR_noi{g}       = R_noi;
    [mR_tmp,vR_tmp] = echant_vers_stats(R_noi,'moy','std');
    mR_noi(:,:,g)   = mR_tmp;
    vR_noi(:,:,g)   = vR_tmp;
    tP_noi{g}       = P_noi;
    [mP_tmp,vP_tmp] = echant_vers_stats(P_noi,'moy','std');
    mP_noi(:,:,g)   = mP_tmp;
    vP_noi(:,:,g)   = vP_tmp;
    
end

resClust.stats.nb_tir = nb_tir;
resClust.stats.mtR    = mtR;
resClust.stats.mtP    = mtP;
resClust.stats.tS     = tS;
resClust.stats.tR     = tR;
resClust.stats.tP     = tP;
resClust.stats.entropie_totale    = entropie_totale;
resClust.stats.integration_totale = integration_totale;
resClust.stats.integration_intra  = integration_intra;
resClust.stats.integration_matrix = integration_matrix;
resClust.stats.mI = mI;
resClust.stats.vI = vI;
resClust.stats.integration_inter = integration_inter;
resClust.stats.integration_ratio = integration_ratio;
resClust.stats.ratio_intra_inter = ratio_intra_inter;
resClust.stats.tR_noi = tR_noi;
resClust.stats.mR_noi = mR_noi;
resClust.stats.vR_noi = vR_noi;
resClust.stats.tP_noi = tP_noi;
resClust.stats.mP_noi = mP_noi;
resClust.stats.vP_noi = vP_noi;
resClust.stats.maskClust = maskClust;

