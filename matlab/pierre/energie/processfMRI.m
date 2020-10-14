function processfMRI(image_path, markers_path, t1_path)
% usage : processfMRI(IMAGE_PATH, MARKERS_PATH, T1_PATH)
%
% Performs EEG-fMRI analysis as designed and originally written by P. Levan
%
% Inputs :
%    IMAGE_PATH       : path to the directory containing the images, i.e. '/my/fmri/images/'
%                       Images must be called run1.nii, run2.nii ... runI.nii
%    MARKERS_PATH     : path to the directory containing the marker and
%                       trigger files, i.e. '/path/to/my/files/'
%                       Must contain run1.markers, run2.markers ... runI.markers
%                       and
%                       run1.trigger, run2.trigger ... runI.trigger
%
% Option :
%    T1_PATH          : path to T1 image
%
% Pierre Besson @ CHRU Lille, July 2011

    if nargin ~= 2 && nargin ~=3 && nargin ~= 0
        error('invalid usage');
    end
    
    %% Step 0. If no argument provided, use GUI to pick the files
    if nargin == 0
        PWD = pwd;
        [image_path, markers_path, t1_path] = input_gui(PWD, PWD, '');
        if ~isstr(image_path)
            return;
        end
    end
    
    if nargin == 2
        t1_path='';
    end

    %% Step 1. Check files existence & validity
    try
        image_list = SurfStatListDir([image_path, '/run*.nii']);
    catch
        error(['can not find run volume in ' image_path]);
    end

    try
        marker_list = SurfStatListDir(strcat(markers_path, '/run*.markers'));
    catch
        error(['can not find markers file in ' markers_path]);
    end

    try
        trigger_list = SurfStatListDir(strcat(markers_path, '/run*.trigger'));
    catch
        error(['can not find trigger file in ' image_path]);
    end

    n_image = length(image_list);
    n_marker = length(marker_list);
    n_trigger = length(trigger_list);

    table_image = zeros(n_image, 1);
    for i = 1 : n_image
        Temp = char(image_list{i});
        table_image(i) = str2num(Temp(end-4));
    end

    table_marker = zeros(n_marker, 1);
    for i = 1 : n_marker
        Temp = char(marker_list{i});
        table_marker(i) = str2num(Temp(end-8));
    end

    table_trigger = zeros(n_trigger, 1);
    for i = 1 : n_trigger
        Temp = char(trigger_list{i});
        table_trigger(i) = str2num(Temp(end-8));
    end

    % Choose runs to use
    Temp = ismember(table_image, table_marker);
    table_image = table_image(Temp);
    table_all = ismember(table_image, table_trigger);
    table_all = table_image(table_all);

    [s, v] = listdlg('PromptString', 'run to use', 'SelectionMode', 'multiple', 'ListString', num2str(table_all), 'OKString', 'select', 'CancelString', 'cancel');

    if v == 0
        return;
    end

    run_to_use = table_all(s);


    %% Step 2. Check validity of the markers
    Events = {};
    dat = {};
    which_run = {};
    
    j = 1;
    for i = 1 : length(run_to_use)
        F = textread(strcat(markers_path, '/run', num2str(run_to_use(i)), '.markers'), '%s', 'delimiter', ',', 'headerlines', 2);
        F = reshape(F, 5, length(F) / 5)';
        Temp = unique(F(:, 2));
        for k = 1 : length(Temp)
            if isempty(ismember(Events, Temp(k, :)))
                S = length(Events);
                Events{S+1} = char(Temp(k, :));
            else
                if ~sum(ismember(Events, Temp(k, :)))
                    S = length(Events);
                    Events{S+1} = char(Temp(k, :));
                end
            end
        end
        for k = 1 : size(Temp, 1)
            dat{j, 1} = char(Temp(k, :));
            dat{j, 2} = sum(strcmp(F(:,2), Temp(k, :)));
            which_run{j} = num2str(run_to_use(i));
            j = j + 1;
        end
    end
    
    QUIT = 1;
    colname = {'event', 'occurrence', 'run', 'discard', 'fuse', 'markers_id'};
    to_discard = repmat(false, size(dat, 1), 1);
    fuse = repmat(false, size(dat, 1), 1);
    columnformat = {'bank', 'numeric', 'numeric', 'logical', 'logical', 'numeric'};
    markers_id = getMarkersID(dat(:,1), to_discard, fuse);
    f = figure('Position', [100 100 700 550], 'Name', ['list of markers'], 'CloseRequestFcn', @quitprog);
    t = uitable('Units', 'normalized', 'Position', [0.1 0.5 0.8 0.5], 'Data', cat(2, dat, which_run', num2cell(to_discard), num2cell(fuse), num2cell(markers_id)), 'ColumnName', colname, 'ColumnEditable', [false false false true true false], 'ColumnFormat', columnformat, 'CellEditCallback', @change_table);
    hs = uicontrol(f, 'Style', 'pushbutton', 'String', 'validate', 'Position', [20 20 100 20], 'Callback', @gotoanalysis);
    hs2 = uicontrol(f, 'Style', 'pushbutton', 'String', 'cancel', 'Position', [20 60 100 20], 'Callback', @quitprog);
    while exist('f')
        pause(0.1);
    end
    
    if QUIT == 1
        return
    end
    
    prep_path = [image_path, '/preprocess'];
    
    if ~isdir(prep_path)
        mkdir(prep_path)
    end
    
    log_file = [prep_path, '/study_markers.log'];
    fid = fopen(log_file, 'w');
    for i = 1 : length(colname)
        fprintf(fid, '%s ', colname{i});
    end
    fprintf(fid, '\n');
    
    for i = 1 : size(dat, 1)
        fprintf(fid, '%s %d %s %d %d %d\n', dat{i, 1}, dat{i, 2}, which_run{i}, to_discard(i), fuse(i), markers_id(i));
    end
    
    fclose(fid);
    
    % Discard markers if any to discard
    to_discard = dat(to_discard~=0, :);
    for i = 1 : length(to_discard)
        F = strcmp(Events, to_discard{i});
        Events = Events(~F);
    end
    
    % Reformat Events
    Events_table = {};
    k = 1;
    for i = 1 : length(Events)
        if ~isempty(findstr(Events{i}, 'start'))
            Events_table{k, 1} = Events{i};
            Temp = Events{i};
            Events_table{k, 2} = [Temp(1:end-5), 'end'];
            k = k + 1;
        else
            if length(Events{i}) < 3 || isempty(findstr(Events{i}(end-2:end), 'end'))
                Events_table{k, 1} = Events{i};
                Events_table{k, 2} = '';
                k = k + 1;
            end
        end
    end
    
    % Get Events IDs
    Events_ID = zeros(size(Events_table, 1), 1);
    for i = 1 : size(Events_ID, 1)
        F = find(strcmp(Events_table(i,1), dat(:, 1)), 1, 'first');
        Events_ID(i) = markers_id(F);
    end
    
    
    %% Step 3. convert files and resample all runs to the first one &
    % fmr_preprocess
    
    PWD = pwd; % Directory change needed for SPM
    cd(prep_path);
    for i = 1 : length(run_to_use)
        disp('**********************************************');
        disp(['Convert run', num2str(run_to_use(i)), ' to mnc']);
        command_line = ['rm -f ', prep_path, '/run', num2str(run_to_use(i)), '.mnc'];
        [s, w] = unix(command_line);
        command_line = ['nii2mnc ', image_path, '/run', num2str(run_to_use(i)), '.nii ', prep_path, '/run', num2str(run_to_use(i)), '.mnc'];
        [s, w] = unix(command_line);
        if i == 1
            command_line = ['cp ', prep_path, '/run', num2str(run_to_use(i)), '.mnc ', prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(i)),'.mnc'];
            [s, w] = unix(command_line);
        else
            disp(['realign run ', num2str(run_to_use(i)), ' to run ', num2str(run_to_use(1))]);
            command_line = ['mritoself ', prep_path, '/run', num2str(run_to_use(i)), '.mnc ', prep_path, '/run', num2str(run_to_use(1)), '.mnc ', prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '.xfm'];
            [s, w] = unix(command_line);
            command_line = ['mincresample -like ', prep_path, '/run', num2str(run_to_use(1)), '.mnc ', '-transformation ', prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '.xfm ', prep_path, '/run', num2str(run_to_use(i)), '.mnc ', prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '.mnc'];
            [s, w] = unix(command_line);
        end
        disp(['fmr_preprocess run', num2str(run_to_use(i))]);
        command_line = ['fmr_preprocess ', prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '.mnc -clobber'];
        [s, w] = unix(command_line);
        
        % Import mnc2nii using SPM
        disp('Converting image back to nii');
        command_line = ['mri_convert ', prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '_MC.mnc ', prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '_MC.nii'];
        [s, w] = unix(command_line);
%         matlabbatch{1}.spm.util.minc.data = {[prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '_MC.mnc']};
%         matlabbatch{1}.spm.util.minc.opts.dtype = 4;
%         matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
% 
%         inputs = cell(0, 1);
%         spm('defaults', 'PET');
%         spm_jobman('serial', matlabbatch, '', inputs{:});
    end

    % Concatanate all MC images
    concat_string = '';
    for i = 1 : length(run_to_use)
        concat_string = [concat_string, prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '_MC.mnc '];
    end
    command_line = ['mincconcat ', concat_string, prep_path, '/run_all_MC.mnc '];
    [s, w] = unix(command_line);
    % Import mnc2nii using SPM
    disp('Converting image back to nii');
    command_line = ['mri_convert ', prep_path, '/run_all_MC.mnc ', prep_path, '/run_all_MC.nii'];
    [s, w] = unix(command_line);
%     matlabbatch{1}.spm.util.minc.data = {[prep_path, '/run_all_MC.mnc']};
%     matlabbatch{1}.spm.util.minc.opts.dtype = 4;
%     matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
% 
%     inputs = cell(0, 1);
%     spm('defaults', 'PET');
%     spm_jobman('serial', matlabbatch, '', inputs{:});
    
    cd(PWD);
    
    pause(0.01);
    
    % Print out mouvements fig.
    for i = 1 : length(run_to_use)
        log_string = [prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '_MC.log'];
        fig_string = [prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '_MC_mouvements.png'];
        checkMovementParameters(log_string, fig_string);
    end
    
    %% Step4. fuse markers with triggers
    for i = 1 : length(run_to_use)
        fuse_manualmarkers_to_trig([markers_path, '/run', num2str(run_to_use(i)), '.markers'], [markers_path, '/run', num2str(run_to_use(i)), '.trigger'], [markers_path, '/fused_run', num2str(run_to_use(i)), '.markers'])
    end
    
    %% Step 5. Spike markers (block originally from P. Levan)
    marker_to_use = {};
    for i = 1 : length(run_to_use)
        marker_to_use{i} = [markers_path, '/fused_run', num2str(run_to_use(i)), '.markers'];
    end
    
    [frametimes, eventimes,eventids,durations,ids] = event_times(marker_to_use{1}, zeros(size(Events_table, 1), 1), Events_table, Events_ID);
    
    eventimes_array(1,1:length(eventimes)) = eventimes;
    eventids_array(1,1:length(eventids)) = eventids;
    durations_array(1,1:length(durations)) = durations;
    frametimes_array(1,:) = frametimes;
    
    for i = 2 : length(run_to_use)
        [frametimes, eventimes,eventids,durations,ids] = event_times(marker_to_use{i}, ids, Events_table, Events_ID);
        
        %check to see if the current number of events will fit in the existing arrays, and enlarge the arrays if not
        if length(eventimes) > size(eventimes_array,2) 
            eventimes_array(1:size(eventimes_array,1),1:length(eventimes)) = [eventimes_array zeros(size(eventimes_array,1),(length(eventimes)-size(eventimes_array,2)))];
            eventids_array(1:size(eventids_array,1),1:length(eventids)) = [eventids_array zeros(size(eventids_array,1),(length(eventids)-size(eventids_array,2)))];
            durations_array(1:size(durations_array,1),1:length(durations)) = [durations_array zeros(size(durations_array,1),(length(durations)-size(durations_array,2)))];
        end
        
        % adds the new events and frame time to the arrays
        eventimes_array(i,1:length(eventimes)) = eventimes;
        eventids_array(i,1:length(eventids)) = eventids;
        durations_array(i,1:length(durations)) = durations;
        frametimes_array(i,:) = frametimes;
    end
    
    s1 = 'frametimes_array';
    s2 = 'eventimes_array';
    s3 = 'eventids_array';
    s4 = 'durations_array';
    
    save([markers_path, '/arrays'], s1, s2, s3, s4, '-v6');
    
    %make text file with event times to be transfered to excel sheet
    fid = fopen([markers_path, '/event_times.txt'], 'wt');

    for i = 1 : length(run_to_use)
        fprintf(fid, ['run' num2str(run_to_use(i))]);
        fprintf(fid,'\n');
        for j = 1:length(find(eventimes_array(i,:)>0))
            txt = ['           ' num2str(eventimes_array(i,j)') '     ' num2str(durations_array(i,j)') '     ' num2str(eventids_array(i,j)')];
            fprintf(fid,txt);
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
    
    % Display found events
    if ~isempty(find(~ids))
        warning(sprintf('No events found of type %s\n',Events_table{find(~ids),1}));
    end

    ids = Events_table(find(ids),1);
    
    %% Step 6. patient batch motion (original from P. Levan)
    
    % Get TR
    NII = nii_read_header([image_path, '/run', num2str(run_to_use(1)), '.nii']);
    TR = NII.PixelDimensions(4);
    n_slices = NII.Dimensions(3);
    
    out_path = [image_path, '/output'];
    if ~isdir(out_path)
        mkdir(out_path)
    end
    
    hrf_array = [5.4 5.2 10.8 7.35 0.35,  % array of different hrfs
             3 5.2 10.8 7.35 0,
             5 5.2 10.8 7.35 0,
             7 5.2 10.8 7.35 0,
             9 5.2 10.8 7.35 0];
         
    hrf_type = ['glove'; 'peak3'; 'peak5'; 'peak7'; 'peak9'];
         
    for j = 1:length(hrf_array) % loop over the different hrfs
        out_dir = [out_path, '/', hrf_type(j, :)];
        if ~isdir(out_dir)
            mkdir(out_dir);
        end
        
        for runidx = 1: length(run_to_use)
            frametimes = frametimes_array(runidx,1:max(find(frametimes_array(runidx,:)>0)));
            slicetimes=[0:n_slices-1]* (TR ./ n_slices);
            eventimes = eventimes_array(runidx,1:max(find(eventimes_array(runidx,:)>0)))';	% attention: needs transposing
            if(length(eventimes)>0)
                t = 0;
                eventid = eventids_array(runidx,1:max(find(eventimes_array(runidx,:)>0)))';
                % ev(1,length(eventid)) = 0;
                ev = zeros(1, length(eventid));
                output_file_base = '';
                for q = 1:100      
                    if ~isempty(find(eventid == q))
                        t = t+1;
                        ev(find(eventid == q)) = t;
                        output_file_base(t, :) = [out_dir, '/run', num2str(run_to_use(runidx), '%.2d'), '_type_', num2str(q, '%.2d')];
                    end
                end

                eventid = ev';
                durations = durations_array(runidx,1:max(find(eventimes_array(runidx,:)>0)))';   % attention: needs transposing
                height = ones(length(eventimes),1);
                events = [eventid  eventimes  durations  height];
                S=[];
                exclude = [];
                hrf_parameters=hrf_array(j,:);	% take each line of hrf_array in turn
                X_cache = fmridesign(frametimes, slicetimes, events, [], hrf_parameters);
                input_file= [prep_path, '/run', num2str(run_to_use(runidx)), '_to_', num2str(run_to_use(1)), '_MC.nii'];
                contrast = zeros(t,t+4);

                for ii = 1:t
                    contrast(ii,ii) = 1;
                end

                which_stats=[1 1 1 0 0 0 0];
                fwhm_rho = 15;
                n_poly = 3;

                confounds = readMCMotion([prep_path, '/run', num2str(run_to_use(i)), '_to_', num2str(run_to_use(1)), '_MC.log']);
                confounds = confounds(:,1:6);

                [DF,P] = fmrilm(input_file, output_file_base, X_cache, contrast, exclude, which_stats, fwhm_rho, n_poly, confounds);

                DF_array(runidx)=DF;
            end
        end
    end
    
    %% Step 7. Fuse all runs and hrf (original by P. Levan)
    root = [out_path, '/'];
    hrf = hrf_type;
    output_name = 'multi_motion';
    basedf = 196; % df for no events (df for 1 event type is this -1)
    
    max1 = max(max(eventids_array));
    df(1,1:size(eventids_array,1)) = basedf;
    
    not_done = [];

    %compute df for all runs
    for i = 1:size(eventids_array,1)
        for j = 1:max1
            f = find(eventids_array(i,:) == j);
            if isempty(f) == 0
                df(i) = df(i)-1;
            end

        end
    end

    df(find(df == basedf)) = 0;


    for types = 1:max1
        input_files_df = [];
        input_files_Y = '';
        input_files_sd = '';
        
        ef = dir([root, '/',  hrf(1,:) '/*type*' num2str(types, '%.2d') '*ef.nii']);
        sd = dir([root, '/',  hrf(1,:) '/*type*' num2str(types, '%.2d') '*sd.nii']);   

        if isempty(ef)
            continue;
        end

        if size(ef,1) > 1  % if thee is only 1 run with that event type, multistat doesn't need to run
            %compute df for this type
            for runs = 1:size(eventids_array,1)
                if isempty(find(eventids_array(runs,:)==types)) ==0
                    input_files_df(length(input_files_df)+1)=df(runs);
                end
            end

            %basic multistat variables
            input_files_fwhm = 6;

            X=ones(size(ef,1),1);

            contrast = 1;

            which_stats =ones(1,3);

            fwhm_varatio = Inf;

            % loops  through hrfs and creates input_file_Y and input_file_sd for each hrf and runs multistat
            for i = 1:size(hrf,1)
                for j = 1:size(ef,1)
                    input_files_Y(j,:) = [root '/' hrf(i,:) '/' ef(j).name];
                    input_files_sd(j,:)= [root '/' hrf(i,:) '/' sd(j).name];
                end   
                output_file_base = [root output_name 'type_' num2str(types, '%.2d') '_' hrf(i,:)];  
                df_mstat = multistat(input_files_Y, input_files_sd, input_files_df, input_files_fwhm, X, contrast, output_file_base,which_stats, fwhm_varatio);

            end


        else
            not_done(length(not_done)+1) = types;
        end

        disp(['creating combined map for type' num2str(types)])

        filename ='';

        if size(ef,1) > 1

            fname = dir([root '*type*' num2str(types, '%.2d') '*peak*t.nii']);
            for h = 1:size(fname,1)
                filename(h,:) = [root fname(h).name];  
            end
            combined_name = [root output_name 'type_' num2str(types, '%.2d') '_combined_t.nii']

        else
            for h = 2:size(hrf,1)  % doesn't include hrf(1,:) which is glover
                filename(h-1,:) = [root hrf(h,:) '/' ef(1).name(1:end-6) 't.nii'];  
            end

            combined_name = [root output_name 'type_' num2str(types, '%.2d') '_combined_t.nii'];
            m = findstr(combined_name,'multi');
            if isempty(m) == 0;
                f=find(eventids_array' == types);
                combined_name = [combined_name(1:m-1) 'run' num2str(ceil(f(1)/size(eventids_array,2))) combined_name(m+5:length(combined_name))];
            end



        end
            %%%%% get image info
            ParentFile=filename(1,:);
   
            V = spm_vol(filename(1,:));
            [Y, XYZ] = spm_read_vols(V);


            %%%%% fill image buffer
            % buf=zeros(DimSizes(3)*DimSizes(4),DimSizes(2));
            buf = zeros(size(Y));

            for i = 1:size(filename,1)
                  V = spm_vol(filename(i,:));
                  [Y, XYZ] = spm_read_vols(V);
                  buf(abs(Y) > abs(buf)) = Y(abs(Y) > abs(buf));
            end;

            %%%% save combined image
          V.fname = combined_name;
          spm_write_vol(V, buf);


    end %end for types = 1:max
    % 
    % 
    if length(not_done)>0
        disp(['Types only found in one run and not run with multistat: ' num2str(not_done)])
    end
    
    %% Step 8. Resample T maps to t1
    % Realign first run on T1
    PWD = pwd;
    cd(out_path);
    % if (nargin == 3) || (exist(t1_path, 'var') ~= 0 && eval(['exist(', '''', t1_path, '''', ')']))
    if ~isempty(t1_path)
           disp(['Register run', num2str(run_to_use(1)), ' to T1 image']);
           
           command_line = ['nii2mnc ', t1_path, ' ', out_path, '/t1.mnc'];
           [s, w] = unix(command_line);
           
           command_line = ['mritoself ', prep_path, '/run', num2str(run_to_use(1)), '_to_', num2str(run_to_use(1)), '_MC.mnc ', out_path, '/t1.mnc ', out_path, '/run', num2str(run_to_use(1)), '_to_t1.xfm'];
           disp(command_line);
           [s, w] = unix(command_line);
           List_t_map = SurfStatListDir([out_path, '/*_t.nii']);
           for i = 1 : length(List_t_map)
               image_to_resample = List_t_map{i};
               command_line = ['nii2mnc ', image_to_resample, ' ', image_to_resample(1:end-4), '.mnc'];
               [s, w] = unix(command_line);
               command_line = ['mincresample -like ', out_path, '/t1.mnc -transformation ', out_path, '/run', num2str(run_to_use(1)), '_to_t1.xfm ', image_to_resample(1:end-4), '.mnc ', image_to_resample(1:end-4), '_to_t1.mnc'];
               [s, w] = unix(command_line);
               
               command_line = ['mri_convert ', image_to_resample(1:end-4), '_to_t1.mnc ', image_to_resample(1:end-4), '_to_t1.nii'];
               [s, w] = unix(command_line);
               
%                matlabbatch{1}.spm.util.minc.data = {[image_to_resample(1:end-4), '_to_t1.mnc']};
%                matlabbatch{1}.spm.util.minc.opts.dtype = 4;
%                matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
% 
%                inputs = cell(0, 1);
%                spm('defaults', 'PET');
%                spm_jobman('serial', matlabbatch, '', inputs{:});
           end
    end
    
    cd(PWD);

    
    %% SUB ROUTINES
    function quitprog(h, eventdata)
        delete(f);
        clear f;
        return
    end

    function gotoanalysis(h, eventdata)
        close(f);
        clear f;
        QUIT = 0;
        return
    end

    function change_table(h, eventdata)
        % Change discard button
        if eventdata.Indices(2) == 4
            S_ref = dat{eventdata.Indices(1)};
            if (length(S_ref) > 2) && (~isempty(findstr('end', S_ref(end-2:end))))
                S_comp = strcmp([S_ref(1:end-3), 'start'], dat(:,1)) + strcmp(S_ref, dat(:, 1));
                S_comp(eventdata.Indices(1)) = 1;
            else
                if (length(S_ref)) > 3 && (~isempty(findstr('start', S_ref(end-4:end))))
                    S_comp = strcmp([S_ref(1:end-5), 'end'], dat(:,1)) + strcmp(S_ref, dat(:, 1));
                    S_comp(eventdata.Indices(1)) = 1;
                else
                    S_comp = strcmp(S_ref, dat(:, 1));
                end
            end
            to_discard(S_comp~=0) = eventdata.NewData;
            fuse = fuse .* (double(~to_discard));
        else
            % Change fuse button
            S_ref = dat{eventdata.Indices(1)};
            if (length(S_ref) > 3) && (~isempty(findstr('end', S_ref(end-2:end))))
                S_comp = strcmp([S_ref(1:end-3), 'start'], dat(:,1)) + strcmp(S_ref, dat(:, 1));
                S_comp(eventdata.Indices(1)) = 1;
            else
                if (length(S_ref) > 4) && (~isempty(findstr('start', S_ref(end-4:end))))
                    S_comp = strcmp([S_ref(1:end-5), 'end'], dat(:,1)) + strcmp(S_ref, dat(:, 1));
                    S_comp(eventdata.Indices(1)) = 1;
                else
                    S_comp = strcmp(S_ref, dat(:, 1));
                end
            end
            fuse(S_comp~=0) = eventdata.NewData;
            to_discard = to_discard .* (double(~fuse));
        end
        
        markers_id = getMarkersID(dat(:,1), to_discard, fuse);
        set(t, 'Data', cat(2, dat, which_run', num2cell(to_discard~=0), num2cell(fuse~=0), num2cell(markers_id)));
    end


    function IDS = getMarkersID(Ev, to_discard, fuse)
        IDS = zeros(size(Ev, 1), 1);
        j = 1;
        for i = 1 : size(Ev, 1)
            if (IDS(i) == 0) && (to_discard(i) == 0)
                Ev_ref = Ev{i};
                if length(Ev_ref) > 3 && ~isempty(findstr(Ev_ref(end-2:end), 'end'))
                    F = strcmp(Ev_ref, Ev); % mark all same events
                    F = F + (fuse .* fuse(i));
                    IDS(F~=0) = j;
                    F = strcmp([Ev_ref(1:end-3), 'start'], Ev); % mark all start events
                    F = F + (fuse .* fuse(i));
                    IDS(F~=0) = j;
                    IDS(i) = j;
                    j = j + 1;
                else
                    if length(Ev_ref) > 4 && ~isempty(findstr(Ev_ref(end-4:end), 'start'))
                        F = strcmp(Ev_ref, Ev); % mark all same events
                        F = F + (fuse .* fuse(i));
                        IDS(F~=0) = j;
                        F = strcmp([Ev_ref(1:end-5), 'end'], Ev); % mark all end events
                        F = F + (fuse .* fuse(i));
                        IDS(F~=0) = j;
                        IDS(i) = j;
                        j = j + 1;
                    else
                        F = strcmp(Ev_ref, Ev);
                        F = F + (fuse .* fuse(i));
                        IDS(F~=0) = j;
                        IDS(i) = j;
                        j = j + 1;
                    end
                end
            end
        end
    end
end

%% SUB ROUTINES
function [image_path, markers_path, t1_path] = input_gui(im_path, mark_path, t_path)
    image_path = im_path;
    markers_path = mark_path;
    t1_path = t_path;
    Done = 0;
    f = figure('Position', [0 0 500 200], 'Name', ['choose input files'], 'CloseRequestFcn', @close_function);
    
    % Get image path
    uicontrol(f, 'Position', [5 150 100 20], 'Style', 'text', 'String', 'path to images');
    path1 = uicontrol(f, 'Position', [120 150 260 20], 'Style', 'edit', 'String', image_path);
    browse1 = uicontrol(f, 'Position', [390 150 20 20], 'Style', 'pushbutton', 'String', '...', 'Callback', @set_image_path);
    
    % Get markers path
    uicontrol(f, 'Position', [5 100 100 20], 'Style', 'text', 'String', 'path to markers');
    path2 = uicontrol(f, 'Position', [120 100 260 20], 'Style', 'edit', 'String', markers_path);
    browse2 = uicontrol(f, 'Position', [390 100 20 20], 'Style', 'pushbutton', 'String', '...', 'Callback', @set_markers_path);
    
    % Get T1 path
    uicontrol(f, 'Position', [5 50 100 20], 'Style', 'text', 'String', 'path to T1 (optional)');
    path3 = uicontrol(f, 'Position', [120 50 260 20], 'Style', 'edit', 'String', t1_path);
    browse3 = uicontrol(f, 'Position', [390 50 20 20], 'Style', 'pushbutton', 'String', '...', 'Callback', @set_t1_path);
    
    % Validation button
    Valid = uicontrol(f, 'Position', [300 10 100 20], 'Style', 'pushbutton', 'String', 'validate', 'Callback', @valid_choice);
    
    while exist('f')
        pause(0.1);
    end
    
    if Done == 0
            image_path = 0;
        end
    
    function set_image_path(h, eventdata)
        new_dir = uigetdir(image_path, 'pick an image dir');
        if new_dir ~= 0
            set(path1, 'String', new_dir);
            image_path = new_dir;
        end
    end

    function set_markers_path(h, eventdata)
        new_dir = uigetdir(markers_path, 'pick a markers dir');
        if new_dir ~= 0
            set(path2, 'String', new_dir);
            markers_path = new_dir;
        end
    end

    function set_t1_path(h, eventdata)
        [new_file, new_path] = uigetfile('*.nii', 'pick a T1 file');
        if new_file ~= 0
            t1_path = [new_path, '/', new_file];
            set(path3, 'String', t1_path);
        end
    end

    function valid_choice(h, eventdata)
        close(f);
        clear f;
        Done = 1;
        return;
    end

    function close_function(h, eventdata)
        delete(f);
        clear f;
        return;
    end

end
