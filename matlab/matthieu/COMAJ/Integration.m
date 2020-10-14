clear all; close all;

fsdir  = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/FS53';
indir  = 'run01';

% subjs_AD = {'BAUANT','BERGMAR','BOUGEO','BOWSEB','BOZSOP','CADDEN','CREJEA','DEPPAT','DUBFRA',...
% 'DUBFRAN','DUBMAR','FAUMAR','FLAMIC','FONNEL','GREJEA','KUTALE','LANMIC','LAUJEA','LEMGIS','LESCHR','LETADR','MALREG','MALYVE',...
% 'MARGAB','MASCEC','RENJOE','ROBMON','TISSER','VANHEL','VANJOS','VERSER'};
% subjs_EOAD = {'207073','BELLUC','BERREG','CARALA','CROMON','DALCHR','DELAMARY','DELMAR',...
%     'DEMDAN','GAWBEA','HAUMAR','LAGSYL','MAGMAR','PENDAN','ROUGIN','SPEPAS','207026','BERGAE',...
%     'BROFRA','COUREG','CUVNEL','DECPAT','DELHEN','DELTHE','DUBJEA','FRAALI','GRYJAC','JORBEA',...
%     'LIESUZ','ORLCAT','PRUMAR','ROUMAR','STRJEA'};

subjs_AD = {'BAUANT','BERGMAR','BOUGEO','BOWSEB','CADDEN','CREJEA','DUBMAR','FAUMAR','FONNEL',...
    'KUTALE','LAUJEA','LESCHR','LETADR','MALREG','MALYVE','MASCEC','ROBMON','VANJOS'};
subjs_EOAD = {'207026','BELLUC','BERGAE','BERREG','COUREG','CROMON','CUVNEL','DALCHR','DELAMARY','DELHEN','DELMAR',...
    'DELTHE','DEMDAN','GAWBEA','GRYJAC','HAUMAR','JORBEA','LAGSYL','LIESUZ','MAGMAR','ORLCAT','PENDAN','PRUMAR',...
    'ROUGIN','ROUMAR','SPEPAS'};

% roiFiles{1} = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Networks/ALN.nii';
% roiFiles{2} = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Networks/ARN.nii';
% roiFiles{3} = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Networks/CEN.nii';
% roiFiles{4} = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Networks/SN.nii';
% roiFiles{5} = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Networks/DMN.nii';


NetworkDir = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Networks';
NetworkNames = {'ALN','ARN','CEN','SN','DMN'};
% roiFiles = {fullfile(NetworkDir,['DMN' '.nii']) fullfile(NetworkDir,['SN' '.nii'])};

prefepi = 'wcarepi_al';
outdir  = '/NAS/dumbo/protocoles/AD_EOAD/resting_state_bene/Integration';
nb_tir  = 1000;

for k = 1:length(subjs_AD)
    epiDirAD{k} = fullfile(fsdir,subjs_AD{k},'fmri',indir);
end
for k = 1:length(subjs_EOAD)
    epiDirEOAD{k} = fullfile(fsdir,subjs_EOAD{k},'fmri',indir);
end

filter.do=false;

% for j = 2:length(NetworkNames)
%     for k = 1:(j-1)
%         
%         roiFiles = {fullfile(NetworkDir,[NetworkNames{j} '.nii']) fullfile(NetworkDir,[NetworkNames{k} '.nii'])};
% 
%         [tS,data,indice_roi,nb_tir,dataNN] = HierarchicCovariance(epiDirAD,prefepi,roiFiles,nb_tir,filter);
%         save(fullfile(outdir,['covariance_integration_AD_' NetworkNames{j} '_' NetworkNames{k} '.mat']),'tS','nb_tir','data','indice_roi','dataNN');
% 
%         [tS,data,indice_roi,nb_tir,dataNN] = HierarchicCovariance(epiDirEOAD,prefepi,roiFiles,nb_tir,filter);
%         save(fullfile(outdir,['covariance_integration_EOAD_'  NetworkNames{j} '_' NetworkNames{k} '.mat']),'tS','nb_tir','data','indice_roi','dataNN');
%     end
% end


for j = 2:length(NetworkNames)
    for l = 1:(j-1)
        
        roiFiles = {fullfile(NetworkDir,[NetworkNames{j} '.nii']) fullfile(NetworkDir,[NetworkNames{l} '.nii'])};
        
        maskClust = [];
        load(fullfile(outdir,['covariance_integration_AD_' NetworkNames{j} '_' NetworkNames{l} '.mat']),'tS','nb_tir','data','indice_roi');
        S{1} = tS;
        maskClust = [maskClust ones(1,length(indice_roi))];
        load(fullfile(outdir,['covariance_integration_EOAD_'  NetworkNames{j} '_' NetworkNames{l} '.mat']),'tS','nb_tir','data','indice_roi');
        S{2} = tS;
        maskClust = [maskClust 2*ones(1,length(indice_roi))];

        numNOI    = 1:length(roiFiles);

        for k = 1:length(S)

            tR{k} = covariance_vers_correlation(S{k});
            tP{k} = covariance_vers_corrpar(S{k});
            mtR   = echant_vers_stats(tR{k},'moy');
            mtP   = echant_vers_stats(tP{k},'moy');

            entropie_totale{k}    = covariance_vers_entropie(S{k});
            integration_totale{k} = covariance_vers_integration_totale(S{k});

            % intégration inter
            tI = zeros(length(roiFiles),length(roiFiles),size(S{k},3));
            integration_intra{k} = zeros(1,size(S{k},3));
            for ii = 1:length(roiFiles)
                for jj = 1:length(roiFiles)
                    if jj~=ii
                        AA = covariance_vers_entropie(S{k}(find((maskClust==numNOI(ii))|(maskClust==numNOI(jj))),find((maskClust==numNOI(ii))|(maskClust==numNOI(jj))),:));
                        tI(ii,jj,:) = covariance_vers_entropie(S{k}(find((maskClust==numNOI(ii))),find((maskClust==numNOI(ii))),:)) + covariance_vers_entropie(S{k}(find((maskClust==numNOI(jj))),find((maskClust==numNOI(jj))),:)) - AA;
                    else
                        tI(ii,jj,:) = covariance_vers_integration_totale(S{k}(find((maskClust==numNOI(ii))),find((maskClust==numNOI(ii))),:));
                        integration_intra{k} = integration_intra{k} + squeeze(tI(ii,jj,:))';
                    end
                end
            end
            [mtI,vtI] = echant_vers_stats(tI,'moy','std');
            integration_matrix{k} = tI;
            mI(:,:,k) = mtI;
            vI(:,:,k) = vtI;
            integration_inter{k}   = integration_totale{k} - integration_intra{k};
            integration_ratio(k,:) = [mean(integration_inter{k}./integration_totale{k})' mean(integration_intra{k}./integration_totale{k})'];
            ratio_intra_inter(k,:) = integration_intra{k}./integration_inter{k};

            R_noi = zeros(length(unique(maskClust)),length(unique(maskClust)),nb_tir);
            P_noi = zeros(length(unique(maskClust)),length(unique(maskClust)),nb_tir);

            for ii = 1:length(unique(maskClust));
                for jj = 1:length(unique(maskClust));
                    R_bloc = tR{k}(maskClust==numNOI(ii),maskClust==numNOI(jj),:);
                    P_bloc = tP{k}(maskClust==numNOI(ii),maskClust==numNOI(jj),:);
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
            tR_noi{k}       = R_noi;
            [mR_tmp,vR_tmp] = echant_vers_stats(R_noi,'moy','std');
            mR_noi(:,:,k)   = mR_tmp;
            vR_noi(:,:,k)   = vR_tmp;
            tP_noi{k}       = P_noi;
            [mP_tmp,vP_tmp] = echant_vers_stats(P_noi,'moy','std');
            mP_noi(:,:,k)   = mP_tmp;
            vP_noi(:,:,k)   = vP_tmp;

        end


        % Display

        numSelection = [1 2];
        nbSelection  = length(S);
        selection(1).name = 'AD';
        selection(2).name = 'EOAD';
        NOIname = {NetworkNames{j},NetworkNames{l}};

        % Total integration
        x_pos = 1:nbSelection;
        h_fig = figure('Units','normalized','Name','total integration','Resize','on','Position',[0.3 0.0302734 0.5 0.42]);
        Itot = zeros(nbSelection,size(ratio_intra_inter,2));
        for ll=1:nbSelection
            Itot(ll,:) = integration_totale{ll};
        end
        errorbar(x_pos,mean(Itot,2),std(Itot,0,2))
        ylabel('Total integration')
        set(gca,'XTick',x_pos);
        set(gca,'XTickLabel',char(selection(numSelection).name));
        grid on;
        hold on
        for kk=1:nbSelection-1
            prob = mean(Itot(kk+1,:)>Itot(kk,:));
            text(mean(x_pos(kk:kk+1)),mean(mean(Itot,2)),['p(right>left) = ' num2str(prob)])
        end


        % Intra integration
        handleInt_intra = figure('Units','normalized','Name','integration intra','Resize','on','Position',[0.3 0.0302734 0.5 0.42]);
        hold on;
        grid on;
        couleurs=colormap(hsv(length(numNOI)));
        for qq = 1:length(numNOI)
            errorbar(x_pos,squeeze(mI(qq,qq,:)),squeeze(vI(qq,qq,:)),'Color',couleurs(qq,:))
            for kk=1:nbSelection-1
                prob = mean(squeeze(integration_matrix{numSelection(kk+1)}(qq,qq,:))>squeeze(integration_matrix{numSelection(kk)}(qq,qq,:)));
                text(mean(x_pos(kk:kk+1)),mean(squeeze(mI(qq,qq,kk:kk+1))),['p(right>left) = ' num2str(prob)])
            end
            legendNOI{qq} = NOIname{numNOI(qq)};
        end
        legend(legendNOI,'Interpreter','none')
        set(gca,'XTick',x_pos);
        set(gca,'XTickLabel',char(selection(numSelection).name));
        title(['integration intra']);

%         pause;
    end
end