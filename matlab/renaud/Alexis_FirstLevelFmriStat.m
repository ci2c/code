function Alexis_FirstLevelFmriStat(datapath,outname,prefix_prepro,sot,TR,last_dyn)

nbruns = 2;

hrf_array = [5.4 5.2 10.8 7.35 0.35,  % array of different hrfs
             3 5.2 10.8 7.35 0,
             5 5.2 10.8 7.35 0,
             7 5.2 10.8 7.35 0,
             9 5.2 10.8 7.35 0];

hrf_type = ['glove'; 'peak3'; 'peak5'; 'peak7'; 'peak9'];

out_path = fullfile(datapath,outname);

if ~isdir(out_path)
    mkdir(out_path)
end

for run = 1:nbruns
    
    input_file = fullfile(datapath,[prefix_prepro num2str(run) '/epi_pre_al.nii']);
    
    [hdr,vol] = niak_read_vol(input_file);
    n_frames  = size(vol,4);
    n_slices  = size(vol,3);
    clear hdr vol;
    
    frametimes = 0:TR:(n_frames-1)*TR;

    % interleaved
    slicetimes = [];
    space      = round(sqrt(n_slices));
    for k=1:space
        tmp        = k:space:n_slices;
        slicetimes = [slicetimes tmp];
    end
    slicetimes = slicetimes * (TR ./ n_slices);
    
    ev1 = [sot{run,1}.vect sot{run,3}.vect]; ev2 = [sot{run,2}.vect sot{run,4}.vect];
    ev3 = [sot{run,5}.vect sot{run,7}.vect]; ev4 = [sot{run,6}.vect sot{run,8}.vect];
    eventimes = [sort(ev1) sort(ev2) sort(ev3) sort(ev4)]';
    eventid   = [1*ones(1,length(sot{run,1}.vect)+length(sot{run,3}.vect)) ...
                 2*ones(1,length(sot{run,2}.vect)+length(sot{run,4}.vect)) ... 
                 3*ones(1,length(sot{run,5}.vect)+length(sot{run,7}.vect)) ...
                 4*ones(1,length(sot{run,6}.vect)+length(sot{run,8}.vect)) ];
    durations = zeros(length(eventid),1);
    height    = ones(length(eventimes),1);
    
    design{run}.eventimes = eventimes;
    design{run}.eventid   = eventid;
    design{run}.durations = durations;
    design{run}.height    = height;
    
    logfile    = fullfile(datapath,[prefix_prepro num2str(run) '/motion_values.txt']);

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

            evid           = ev';
            events         = [evid  eventimes  durations  height];
            S              = [];
            exclude        = [1 2 3 last_dyn:n_frames];
            hrf_parameters = hrf_array(j,:);	% take each line of hrf_array in turn
            X_cache        = fmridesign(frametimes, slicetimes, events, [], hrf_parameters);
            contrast       = zeros(t+2,t+4);

            for i = 1:t
                contrast(i,i) = 1;
            end
            contrast(t+1,[1 2]) = [-1 1];
            contrast(t+2,[3 4]) = [-1 1];

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

%% COMBINE RUNS

root        = [out_path, '/'];
hrf         = hrf_type;
output_name = 'multi_motion';
basedf      = n_frames-4; % df for no events (df for 1 event type is this -1)

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

for types = 1:max1+2
    
    input_files_df = [];
    input_files_Y  = '';
    input_files_sd = '';

    ef = dir([root, '/',  hrf(1,:) '/*type*' num2str(types, '%.2d') '*ef.nii']);
    sd = dir([root, '/',  hrf(1,:) '/*type*' num2str(types, '%.2d') '*sd.nii']);   

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
            for j = 1:size(ef,1)
                input_files_Y(j,:)  = [root '/' hrf(i,:) '/' ef(j).name];
                input_files_sd(j,:) = [root '/' hrf(i,:) '/' sd(j).name];
            end   
            output_file_base = [root output_name 'type_' num2str(types, '%.2d') '_' hrf(i,:)];  
            df_mstat         = multistat(input_files_Y, input_files_sd, [], [], X, contrast, output_file_base,which_stats, fwhm_varatio);

        end


    else
        not_done(length(not_done)+1) = types;
    end

end %end for types = 1:max
