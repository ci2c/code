function DF_array = FMRI_StimMedianAnalysisofEachEvent(epiFile,onsetFile,TR,remFrame,out_path,motionFile)

% Create output folder
if ~isdir(out_path)
    mkdir(out_path)
end

% HRF
hrf_array = [5.4 5.2 10.8 7.35 0.35,  % array of different hrfs
         3 5.2 10.8 7.35 0,
         5 5.2 10.8 7.35 0,
         7 5.2 10.8 7.35 0,
         9 5.2 10.8 7.35 0];

hrf_type = ['glove'; 'peak3'; 'peak5'; 'peak7'; 'peak9'];

% Confounds
if nargin==6
    confounds=load(motionFile);
else
    confounds = [];
end

% Acquisition
NII = nii_read_header(epiFile);
n_slices = NII.Dimensions(3);
n_frames = NII.Dimensions(4);
slicetimes = [0:n_slices-1] * (TR ./ n_slices);
frametimes = [0:n_frames-1] * TR;

% Onsets
load(onsetFile);
% remove timings
ons = ons-remFrame*TR;
ons = ons(:);	
id  = find(ons<0);
if length(id)>0
    disp([num2str(length(id)) ' stimuli to removed'])
    ons = ons(id(end)+1:end);
else
    disp([num2str(0) ' stimulus to removed'])
end
id  = find(ons>(n_frames-remFrame)*TR-8);
if length(id)>0
    disp([num2str(length(id)) ' stimuli to removed'])
    ons = ons(1:id(1)-1);
else
    disp([num2str(0) ' stimulus to removed'])
end
eventimes = ons;
durations = zeros(length(eventimes),1);
eventids  = [1:length(eventimes)]';
% eventids  = ones(length(eventimes),1);

% Default values
which_stats = [1 1 1 0 0 0 0];
fwhm_rho    = 15;
n_poly      = 3;

% Process
for j = 1:length(hrf_array) % loop over the different hrfs
    
    out_dir = fullfile(out_path,hrf_type(j, :));
    if ~isdir(out_dir)
        mkdir(out_dir);
    end
    
    if(length(eventimes)>0)
        
        t = 0;

        eventid = eventids;
        ev = zeros(1, length(eventid));
        output_file_base = '';
        for q = 1:100      
            if ~isempty(find(eventid == q))
                t = t+1;
                ev(find(eventid == q)) = t;
                output_file_base(t, :) = fullfile(out_dir, ['event_', num2str(q, '%.2d')]);
            end
        end

        eventid = ev';
        height  = ones(length(eventimes),1);
        events  = [eventid  eventimes  durations  height];
        S = [];
        exclude = [];
        hrf_parameters = hrf_array(j,:);	% take each line of hrf_array in turn
        X_cache  = fmridesign(frametimes, slicetimes, events, [], hrf_parameters);
        contrast = zeros(t,t+4);

        for ii = 1:t
            contrast(ii,ii) = 1;
        end

        [DF,P] = fmrilm(epiFile, output_file_base, X_cache, contrast, exclude, which_stats, fwhm_rho, n_poly, confounds);

        DF_array(j) = DF;
        
    end
    
end


   