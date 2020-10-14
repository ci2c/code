function CorrelationROIs(fs_dir,subject)


%% Read registered and binarised ROIs and define names
fid = fopen(fullfile(fs_dir,'ListeROIs.txt'), 'r');
T = textscan(fid,'%s','delimiter','\n');
Names = T{1};
Ts = length(Names); 
fclose(fid);

nROI = Ts;

%% Read epi filename run 1
epiTmp= fullfile(fs_dir,subject,'fmri1ter/run01/seeds/rs6fcarepi_al.nii');

if exist(epiTmp,'file') == 2

    fprintf('Reading fMRI dataset %s ...\n',epiTmp);
    [hdr,vol]     = niak_read_vol(epiTmp);

    for i = 1 : (nROI-1)
        tic;
        roiFile = fullfile(fs_dir,subject,'fmri1ter/run01/seeds',[Names{i} '.nii']);
        if exist(roiFile,'file') == 2   

            fprintf('Reading mask %s ...\n',roiFile);
            [hdr2,mask] = niak_read_vol(roiFile);

            opt_tmp.correction.type = 'none';
            opt_tmp.flag_all = false;
            [tseries,std_tseries,labels_roi] = FMRI_Build_Tseries(vol,mask>0,opt_tmp);
            
            tseries = niak_correct_mean_var(tseries,'mean');

            for j = (i+1) : nROI
                
                roiFile = fullfile(fs_dir,subject,'fmri1ter/run01/seeds',[Names{j} '.nii']);
                if exist(roiFile,'file') == 2  
                    fprintf('Reading mask %s ...\n',roiFile);
                    [hdr2,mask2] = niak_read_vol(roiFile);

                    opt_tmp.correction.type = 'none';
                    opt_tmp.flag_all = false;
                    [tseries2,std_tseries2,labels_roi2] = FMRI_Build_Tseries(vol,mask2>0,opt_tmp);

                    tseries2 = niak_correct_mean_var(tseries2,'mean');

                    C = corr(tseries,tseries2);

                    fid = fopen(fullfile(fs_dir,subject,'fmri1ter/run01/seeds', 'CorrelationROIs_run1.txt'), 'a');
                    fprintf(fid, '%s_2_%s %f\n', Names{i}, Names{j}, C);
                    fclose(fid);      
                else
                    continue;
                end
            end
        else
            continue;
        end
        disp(['1-Processing step ', num2str(i, '%.3d'), ' out of ', num2str(nROI-1), ' | Time : ', num2str(toc)]);
    end
else
    disp('le fichier epi1 n existe pas');
    exit;
end

%% Read epi filename run 2
epiTmp= fullfile(fs_dir,subject,'fmri2ter/run01/seeds/rs6fcarepi_al.nii');

if exist(epiTmp,'file') == 2

    fprintf('Reading fMRI dataset %s ...\n',epiTmp);
    [hdr,vol]     = niak_read_vol(epiTmp);

    for i = 1 : (nROI-1)
        tic;
        roiFile = fullfile(fs_dir,subject,'fmri2ter/run01/seeds',[Names{i} '.nii']);
        if exist(roiFile,'file') == 2   

            fprintf('Reading mask %s ...\n',roiFile);
            [hdr2,mask] = niak_read_vol(roiFile);

            opt_tmp.correction.type = 'none';
            opt_tmp.flag_all = false;
            [tseries,std_tseries,labels_roi] = FMRI_Build_Tseries(vol,mask>0,opt_tmp);
            
            tseries = niak_correct_mean_var(tseries,'mean');

            for j = (i+1) : nROI
                
                roiFile = fullfile(fs_dir,subject,'fmri2ter/run01/seeds',[Names{j} '.nii']);
                if exist(roiFile,'file') == 2  
                    fprintf('Reading mask %s ...\n',roiFile);
                    [hdr2,mask2] = niak_read_vol(roiFile);

                    opt_tmp.correction.type = 'none';
                    opt_tmp.flag_all = false;
                    [tseries2,std_tseries2,labels_roi2] = FMRI_Build_Tseries(vol,mask2>0,opt_tmp);

                    tseries2 = niak_correct_mean_var(tseries2,'mean');

                    C = corr(tseries,tseries2);

                    fid = fopen(fullfile(fs_dir,subject,'fmri2ter/run01/seeds', 'CorrelationROIs_run2.txt'), 'a');
                    fprintf(fid, '%s_2_%s %f\n', Names{i}, Names{j}, C);
                    fclose(fid);      
                else
                    continue;
                end
            end
        else
            continue;
        end
        disp(['2-Processing step ', num2str(i, '%.3d'), ' out of ', num2str(nROI-1), ' | Time : ', num2str(toc)]);
    end
else
    disp('le fichier epi2 n existe pas');
    exit;
end

  