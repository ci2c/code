function RunLevelByFmriStat(datapath,outname,rem_beg,sot,TR)

input_file = fullfile(datapath,'run1','epi_pre_vol.nii');
[hdr,vol]  = niak_read_vol(input_file);
n_slices   = size(vol,3);
n_frames   = size(vol,4);
clear hdr vol;

nbruns = 2;
frametimes = 0:TR:(n_frames-1)*TR;

% interleaved
slicetimes = [];
space      = round(sqrt(n_slices));
for k=1:space
    tmp        = k:space:n_slices;
    slicetimes = [slicetimes tmp];
end
slicetimes = slicetimes * (TR ./ n_slices);

hrf_array = [5.4 5.2 10.8 7.35 0.35,  % array of different hrfs
             3 5.2 10.8 7.35 0,
             5 5.2 10.8 7.35 0,
             7 5.2 10.8 7.35 0,
             9 5.2 10.8 7.35 0];

hrf_type = ['glove'; 'peak3'; 'peak5'; 'peak7'; 'peak9'];

out_path = fullfile(datapath,outname);

if isdir(out_path)
    cmd = sprintf('rm -rf %s',out_path);
    unix(cmd);
end
mkdir(out_path);

for run=1:nbruns
    
    ev1 = sot{run,5}-rem_beg*TR; 
    ev2 = sot{run,6}-rem_beg*TR; 
    ev3 = sot{run,7}-rem_beg*TR; 
    ev4 = sot{run,8}-rem_beg*TR; 
    ev5 = sot{run,9}-rem_beg*TR; 
    ev6 = sot{run,10}-rem_beg*TR;
    ev7 = sot{run,11}-rem_beg*TR;
    ev8 = sot{run,12}-rem_beg*TR;
    ev9 = sot{run,15}-rem_beg*TR;
    ev10 = sot{run,16}-rem_beg*TR;
    
    ev1 = ev1(ev1>0);
    ev2 = ev2(ev2>0);
    ev3 = ev3(ev3>0);
    ev4 = ev4(ev4>0);
    ev5 = ev5(ev5>0);
    ev6 = ev6(ev6>0);
    ev7 = ev7(ev7>0);
    ev8 = ev8(ev8>0);
    ev9 = ev9(ev9>0);
    ev10 = ev10(ev10>0);
    
    eventimes = [sort(ev1) sort(ev2) sort(ev3) sort(ev4) sort(ev5) sort(ev6) sort(ev7) sort(ev8) sort(ev9) sort(ev10)]';
    eventid   = [1*ones(1,length(ev1)) ...
                 2*ones(1,length(ev2)) ... 
                 3*ones(1,length(ev3)) ...
                 4*ones(1,length(ev4)) ...
                 5*ones(1,length(ev5)) ...
                 6*ones(1,length(ev6)) ...
                 7*ones(1,length(ev7)) ...
                 8*ones(1,length(ev8)) ...
                 9*ones(1,length(ev9)) ...
                 10*ones(1,length(ev10))];
    durations = zeros(length(eventid),1);
    height    = ones(length(eventimes),1);
    
    design{run}.eventimes = eventimes;
    design{run}.eventid   = eventid;
    design{run}.durations = durations;
    design{run}.height    = height;
    
    logfile    = spm_select('FPList', fullfile(datapath,['run' num2str(run)],'spm'), ['^rp_.*\.txt$']);
    input_file = fullfile(datapath,['run' num2str(run)],'epi_pre_vol.nii');

    %% Run level
    for j = 1:length(hrf_array) % loop over the different hrfs

        out_dir = [out_path, '/', hrf_type(j, :)];

        if ~isdir(out_dir)
            mkdir(out_dir);
        end

        if(length(eventimes)>0)
            t = 0;
            % ev(1,length(eventid)) = 0;
            ev = zeros(1, length(eventid));
            output_file_base = '';
            for q = 1:100      
                if ~isempty(find(eventid == q))
                    t = t+1;
                    ev(find(eventid == q)) = t;
                    output_file_base(t, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(q, '%.2d')];
                end
            end
            output_file_base(t+1, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+1, '%.2d')];
            output_file_base(t+2, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+2, '%.2d')];
            output_file_base(t+3, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+3, '%.2d')];
            output_file_base(t+4, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+4, '%.2d')];
            output_file_base(t+5, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+5, '%.2d')];
            output_file_base(t+6, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+6, '%.2d')];
            output_file_base(t+7, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+7, '%.2d')];
            output_file_base(t+8, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+8, '%.2d')];
            output_file_base(t+9, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+9, '%.2d')];
            output_file_base(t+10, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+10, '%.2d')];
            output_file_base(t+11, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+11, '%.2d')];
            output_file_base(t+12, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+12, '%.2d')];
            output_file_base(t+13, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+13, '%.2d')];
            output_file_base(t+14, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+14, '%.2d')];
            output_file_base(t+15, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+15, '%.2d')];
            output_file_base(t+16, :) = [out_dir, '/run', num2str(run, '%.2d'), '_type_', num2str(t+16, '%.2d')];

            evid           = ev';
            events         = [evid  eventimes  durations  height];
            S              = [];
            exclude        = [];
            hrf_parameters = hrf_array(j,:);	% take each line of hrf_array in turn
            X_cache        = fmridesign(frametimes, slicetimes, events, [], hrf_parameters);
            %contrast       = zeros(t+2,t+4);
            contrast       = zeros(t+16,t);

            for i = 1:t
                contrast(i,i) = 1;
            end
            contrast(t+1,[1 3]) = [1 1]; % left words
            contrast(t+2,[2 4]) = [1 1]; % right words
            contrast(t+3,[5 7]) = [1 1]; % left nowords
            contrast(t+4,[6 8]) = [1 1]; % right nowords
            contrast(t+5,[1 2]) = [1 -1]; % true left vs right words
            contrast(t+6,[1 2]) = [-1 1]; % true right vs left words
            contrast(t+7,[5 6]) = [1 -1]; % true left vs right nowords
            contrast(t+8,[5 6]) = [-1 1]; % true right vs left nowords
            contrast(t+9,[1 2 3 4]) = [1 -1 1 -1]; % left vs right words
            contrast(t+10,[1 2 3 4]) = [-1 1 -1 1]; % right vs left words
            contrast(t+11,[5 6 7 8]) = [1 -1 1 -1]; % left vs right nowords
            contrast(t+12,[5 6 7 8]) = [-1 1 -1 1]; % right vs left nowords
            contrast(t+13,[1 2 5 6])  = [1 -1 1 -1]; % true left vs right 
            contrast(t+14,[1 2 5 6]) = [-1 1 -1 1]; % true right vs left
            contrast(t+15,[1 2 3 4 5 6 7 8])  = [1 -1 1 -1 1 -1 1 -1]; % left vs right 
            contrast(t+16,[1 2 3 4 5 6 7 8]) = [-1 1 -1 1 -1 1 -1 1]; % right vs left

            which_stats = [1 1 1 0 0 0 0];
            fwhm_rho    = 15;
            n_poly      = 3;

            confounds = load(logfile);
            confounds = confounds(:,1:6);

            [DF,P] = fmrilm(input_file, output_file_base, X_cache, contrast, exclude, which_stats, fwhm_rho, n_poly, confounds);

            DF_array(run)=DF;
        end
    end

end


%% NORMALIZATION

for run = 1:nbruns
    
    meanFile = spm_select('FPList', fullfile(datapath,['run' num2str(run)],'spm'), ['^meanaepi_.*\.nii$']);
    
    a = which('spm_normalise');
    [path] = fileparts(a);

    VG      = fullfile(path,'templates','EPI.nii');
    VF      = meanFile;
    matname = '';
    VWG     = '';
    VWF     = '';
    opt_normalize.estimate.smosrc  = 8;
    opt_normalize.estimate.smoref  = 0;
    opt_normalize.estimate.regtype = 'mni';
    opt_normalize.estimate.weight  = '';
    opt_normalize.estimate.cutoff  = 25;
    opt_normalize.estimate.nits    = 16;
    opt_normalize.estimate.reg     = 1;
    opt_normalize.estimate.wtsrc   = 0;

    if ~exist(fullfile(datapath,['run' num2str(run)],'spm','param_normalize.mat'))
        params_normalize = spm_normalise(VG,VF,matname,VWG,VWF,opt_normalize.estimate);
        save(fullfile(datapath,['run' num2str(run)],'spm','param_normalize.mat'),'params_normalize');
    else
        load(fullfile(datapath,['run' num2str(run)],'spm','param_normalize.mat'),'params_normalize');
    end
    
    opt_normalize.write.preserve = 0;
    opt_normalize.write.bb       = [-78 -112 -50 ; 78 76 85];
    opt_normalize.write.vox      = [3 3 3];   
    opt_normalize.write.interp   = 3;
    opt_normalize.write.wrap     = [0 0 0];
    
    spm_write_sn(meanFile,params_normalize,opt_normalize.write);

    for j = 1:length(hrf_type)
        
        out_dir  = [out_path, '/', hrf_type(j, :)];
        
        epiFiles = spm_select('FPList', out_dir, ['^run' num2str(run, '%.2d') '_type_.*\_ef.nii$']);
        
        warning('off')
        for k = 1:size(epiFiles,1)
            spm_write_sn(epiFiles(k,:),params_normalize,opt_normalize.write);
        end
        
        wepiFiles = spm_select('FPList', out_dir, ['^wrun' num2str(run, '%.2d') '_type_.*\_ef.nii$']);
        for k = 1:size(epiFiles,1)
            
            d1      = fmris_read_nifti(epiFiles(k,:));
            d2      = fmris_read_nifti(wepiFiles(k,:));
            d3      = d2;
            d3.df   = d1.df;
            d3.fwhm = d1.fwhm;
            d3.file_name = fullfile(out_dir,'imatmp.nii');
            fmris_write_nifti(d3);
            cmd = sprintf('mv %s %s',d3.file_name,d2.file_name);
            unix(cmd);
            clear d1 d2 d3;
            
        end
        
        epiFiles = spm_select('FPList', out_dir, ['^run' num2str(run, '%.2d') '_type_.*\_sd.nii$']);
        
        warning('off')
        for k = 1:size(epiFiles,1)
            spm_write_sn(epiFiles(k,:),params_normalize,opt_normalize.write);
        end
        
        wepiFiles = spm_select('FPList', out_dir, ['^wrun' num2str(run, '%.2d') '_type_.*\_sd.nii$']);
        for k = 1:size(epiFiles,1)
            
            d1      = fmris_read_nifti(epiFiles(k,:));
            d2      = fmris_read_nifti(wepiFiles(k,:));
            d3      = d2;
            d3.df   = d1.df;
            d3.fwhm = d1.fwhm;
            d3.file_name = fullfile(out_dir,'imatmp.nii');
            fmris_write_nifti(d3);
            cmd = sprintf('mv %s %s',d3.file_name,d2.file_name);
            unix(cmd);
            clear d1 d2 d3;
            
        end
        
    end
    
end


%% COMBINE RUNS

root        = [out_path, '/'];
hrf         = hrf_type;
output_name = 'multi_motion';
basedf      = n_frames; % df for no events (df for 1 event type is this -1)

max1        = max([design{1}.eventid design{2}.eventid]);
df(1,1:nbruns) = basedf;

not_done = [];

%compute df for all runs
for i = 1:nbruns
    for j = 1:max1
        f = find(design{i}.eventid == j);
        if isempty(f) == 0
            df(i) = df(i)-1;
        end

    end
end

df(find(df == basedf)) = 0;

for types = 1:max1+16
    
    input_files_df = [];
    input_files_Y  = '';
    input_files_sd = '';
    
    ef = spm_select('FPList', fullfile(out_path,hrf_type(1, :)), ['^wrun.*\_type_' num2str(types, '%.2d') '_mag_ef.nii$']);
    sd = spm_select('FPList', fullfile(out_path,hrf_type(1, :)), ['^wrun.*\_type_' num2str(types, '%.2d') '_mag_sd.nii$']);

    if isempty(ef)
        continue;
    end

    if size(ef,1) > 1  % if thee is only 1 run with that event type, multistat doesn't need to run
        
        %compute df for this type
        for runs = 1:nbruns
            if isempty(find(design{runs}.eventid==types)) ==0
                input_files_df(length(input_files_df)+1)=df(runs);
            end
        end

        %basic multistat variables
        %input_files_fwhm = 6;

        X=ones(size(ef,1),1);

        contrast = 1;

        which_stats =ones(1,3);

        fwhm_varatio = Inf;

        % loops  through hrfs and creates input_file_Y and input_file_sd for each hrf and runs multistat
        for i = 1:size(hrf,1)
            input_files_Y = spm_select('FPList', fullfile(out_path,hrf_type(i, :)), ['^wrun.*\_type_' num2str(types, '%.2d') '_mag_ef.nii$']);
            input_files_sd = spm_select('FPList', fullfile(out_path,hrf_type(i, :)), ['^wrun.*\_type_' num2str(types, '%.2d') '_mag_sd.nii$']); 
            output_file_base = [root output_name 'type_' num2str(types, '%.2d') '_' hrf(i,:)];  
            df_mstat         = multistat(input_files_Y, input_files_sd, [], [], X, contrast, output_file_base,which_stats, fwhm_varatio);
        end


    else
        not_done(length(not_done)+1) = types;
    end

end %end for types = 1:max
