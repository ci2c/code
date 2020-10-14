function WOI = NRJ_WindowsOfInterest(epiFiles,markerFile,TR,window_size,types)

% usage : WOI = NRJ_WindowsOfInterest(epiFiles,markerFile,TR,window_size,types,step_after)
%
% Inputs:
%    epiFiles      : nii files of each run 
%    markerFile    : marker file
%    TR            : time of repetition
%
% Options:
%   window_size    : size of windows (Default: 8)
%   types          : types of events ("[]" means all events) (Default: [])
%
% Output:
%    WOI           : windows of interest ("before events" - "during events"
%                       - "after events" - "without events")
%
% Renaud Lopes @ CHRU Lille, Dec 2013

if ~exist('window_size','var')
    window_size = 8;
end

if ~exist('types','var')
    types = [];
end

% Load marker file
load(markerFile);

% Check dimension
if size(eventimes_array,1) ~= size(epiFiles,1)
    disp('dimension mismatch between epiFiles and markerFile')
    return;
end

eventimes = [];
eventids  = [];
nframes   = 0;

runs  = 1:size(eventimes_array,1);

for k = 1:length(runs)
    
    run = runs(k);
    V   = spm_vol(deblank(epiFiles(run,:)));
    rmframe = length(find(frametimes_array(k,:)>0))+1 - length(V);
    nframes = nframes + length(V);
    
    if isempty(types)
        id = find(eventids_array(k,:)>0);
    else
        id = [];
        for i = 1:length(types)
            id = [id find(eventids_array(k,:)==types(i))];
        end
        id = sort(id);
    end
    if ~isempty(id)
        events    = eventimes_array(k,id)-TR*rmframe;
        durations = durations_array(k,id);
        eveids    = eventids_array(k,id);
        id        = find(events>0);
        events    = events(id);
        durations = durations(id);
        eveids    = eveids(id);
        events    = round(events/TR);
        eventimes = [eventimes events+(run-1)*length(V)];
        eventids  = [eventids eveids];
    end
    
end

idx       = find(eventimes>window_size & eventimes<nframes-window_size);
eventimes = eventimes(idx);
eventids  = eventids(idx);

% Before and after events...
tmp_spike = [1 eventimes];
id_bef = find(diff(tmp_spike)>3*window_size);
id_aft = find(diff(eventimes)>3*window_size); %+step_after);
bef_spike = eventimes(id_bef)-round(window_size/2);
aft_spike = eventimes(id_aft)+window_size+round(window_size/2);
bef_ids   = eventids(id_bef);
aft_ids   = eventids(id_aft);

% During events...
id_dur = find(diff(eventimes)>window_size);
id_dur = [id_dur id_dur+1];
id_dur = sort(unique(id_dur));
dur_spike = eventimes(id_dur)+round(window_size/2);
dur_ids   = eventids(id_dur);

% Intersection
id_befIdur    = intersect(id_bef,id_dur);
id_aftIdur    = intersect(id_aft,id_dur);
id_befIaft    = intersect(id_bef,id_aft);
befIdur_spike = eventimes(id_befIdur)-round(window_size/2);
durIbef_spike = eventimes(id_befIdur)+round(window_size/2);
aftIdur_spike = eventimes(id_aftIdur)+window_size+round(window_size/2);
durIaft_spike = eventimes(id_aftIdur)+round(window_size/2);
befIaft_spike = eventimes(id_befIaft)-round(window_size/2);
aftIbef_spike = eventimes(id_befIaft)+window_size+round(window_size/2);
befIdur_ids   = eventids(id_befIdur);
durIbef_ids   = eventids(id_befIdur);
aftIdur_ids   = eventids(id_aftIdur);
durIaft_ids   = eventids(id_aftIdur);
befIaft_ids   = eventids(id_befIaft);
aftIbef_ids   = eventids(id_befIaft);

id_durIbefUaft    = union(id_befIdur,id_aftIdur);
durIbefUaft_spike = eventimes(id_durIbefUaft)+round(window_size/2);
durIbefUaft_ids   = eventids(id_durIbefUaft);

id_durIbefIaft    = intersect(id_befIaft,id_dur);
if length(id_durIbefIaft)>0
    durIbefIaft_spike = eventimes(id_durIbefIaft)+round(window_size/2);
    durIbefIaft_ids   = eventids(id_durIbefIaft);
    befIdurIaft_spike = eventimes(id_durIbefIaft)-round(window_size/2);
    befIdurIaft_ids   = eventids(id_durIbefIaft);
    aftIdurIbef_spike = eventimes(id_durIbefIaft)+window_size+round(window_size/2);
    aftIdurIbef_ids   = eventids(id_durIbefIaft);
else
    durIbefIaft_spike = [];
    durIbefIaft_ids   = [];
    befIdurIaft_spike = [];
    befIdurIaft_ids   = [];
    aftIdurIbef_spike = [];
    aftIdurIbef_ids   = [];
end

% During no events...
tmp_spike   = [1 eventimes nframes];
dur_nospike = [];
id_nos = find(diff(tmp_spike)>4*window_size);
durWcell_nospike = {};
durW_nospike = [];
count_nospike = 0;
if ~isempty(id_nos)
    for k = 1:length(id_nos)
        if id_nos(k)==1
            idtmp = tmp_spike(id_nos(k))+window_size:tmp_spike(id_nos(k)+1)-window_size-round(window_size/2);
            dur_nospike = [dur_nospike idtmp];
            
            idtmp = tmp_spike(id_nos(k)):tmp_spike(id_nos(k)+1)-window_size;
            n = length(idtmp);
            nw = floor(n/window_size);
            step = floor(rem(n,window_size)/2);
            idtmp = idtmp(1+step:window_size:end-step);
            idtmp = idtmp(1:nw);
            durWcell_nospike{k} = idtmp+round(window_size/2);
            durW_nospike = [durW_nospike idtmp+round(window_size/2)];
            
            count_nospike = count_nospike+nw;
        else
            idtmp = tmp_spike(id_nos(k))+2*window_size+round(window_size/2):tmp_spike(id_nos(k)+1)-window_size-round(window_size/2);
            dur_nospike = [dur_nospike idtmp];
            
            idtmp = tmp_spike(id_nos(k))+2*window_size:tmp_spike(id_nos(k)+1)-window_size;
            n = length(idtmp);
            nw = floor(n/window_size);
            step = floor(rem(n,window_size)/2);
            idtmp = idtmp(1+step:window_size:end-step);
            idtmp = idtmp(1:nw);
            durWcell_nospike{k} = idtmp+round(window_size/2);
            durW_nospike = [durW_nospike idtmp+round(window_size/2)];
            
            count_nospike = count_nospike+nw;
        end
    end
end

% Results
WOI = struct('beforeEvents_timing',bef_spike,'beforeEvents_type',bef_ids,'duringEvents_timing',dur_spike,'duringEvents_type',dur_ids,'afterEvents_timing',aft_spike,'afterEvents_type',aft_ids,'noEvents_timing',dur_nospike,...
             'befIdur_timing',befIdur_spike,'befIdur_type',befIdur_ids,'durIbef_timing',durIbef_spike,'durIbef_type',durIbef_ids,'aftIdur_timing',aftIdur_spike,'aftIdur_type',aftIdur_ids,...
             'durIaft_timing',durIaft_spike,'durIaft_type',durIaft_ids,'befIaft_timing',befIaft_spike,'befIaft_type',befIaft_ids,'aftIbef_timing',aftIbef_spike,'aftIbef_type',aftIbef_ids,...
             'durIbefUaft_timing',durIbefUaft_spike,'durIbefUaft_type',durIbefUaft_ids,'durIbefIaft_timing',durIbefIaft_spike,'durIbefIaft_type',durIbefIaft_ids,...
             'befIdurIaft_timing',befIdurIaft_spike,'befIdurIaft_type',befIdurIaft_ids,'aftIdurIbef_timing',aftIdurIbef_spike,'aftIdurIbef_type',aftIdurIbef_ids,...
             'noEventsW_timing',durW_nospike);
