function [frametimes, eventimes,eventids,durations,ids_return] = event_times(filename,ids,event_names, event_id)
%calculates events and frame times for one run. 
% the first 2 frames and any spikes before are not marked as they are not recorded by the scanner

[type, description, time, lengths, channel] = textread(filename,'%s%s%s%s%s','delimiter',',');

t = regexpi(type(1), '(\w*)Hz', 'tokens');
sampling_rate = str2num(char(t{1}{1}));

%finds the line that represents frame 3
f = strcmp(type,{'Scanner'});
f = find(f ==1);
frame1 = f(1);
% frame3 = f(5);    %For exams with Zshim. 

% removes every line before frame 3
type = type(frame1:end);
description = description(frame1:end);
time = time(frame1:end);
lengths = lengths(frame1:end);
channel = channel(frame1:end);

time = str2num(char(time)); % Convert time to double

time = (time-time(1))/sampling_rate;       %sets all time relative to first frame

%%%calculate frame times and event times, and construct mat file
frames = strcmp(type,{'Scanner'});
mark = strcmp(type,{'Comment'});

frametimes = time(frames==1);

% remove any events after that last frame,  as these are comment by eliane
frames(find(frames==1, 1, 'last')+1:end) = [];

f = find(mark == 1);
used = zeros(size(f));
if ~isempty(f)
    eventids = [];
    eventimes = [];
    durations = [];
    % Go through all event names
    for i=1:size(event_names,1)
        index_start = find(strcmp(event_names{i,1},description(f)));
        if isempty(event_names{i,2})
            index_end = index_start;
        else
            index_end = find(strcmp(event_names{i,2},description(f)));
        end
        
        if length(index_start) ~= length(index_end)
            error(sprintf('Number of events %s (%d) not equal to number of events %s (%d)',event_names{i,1},length(index_start),event_names{i,2},length(index_end)));
        end
        
        if ~isempty(find(index_end<index_start))
            temp = find(index_end<index_start,1);
            error(sprintf('Event %s at time %f occurs before event %s at time %f',event_names{i,2},time(f(index_end(temp))),event_names{i,1},time(f(index_start(temp)))));
        end
        
        eventids = [eventids repmat(event_id(i),1,length(index_start))];
        eventimes = [eventimes time(f(index_start))'];
        durations = [durations (time(f(index_end))-time(f(index_start)))'];
        
        if ~isempty(index_start)
            used(index_start) = 1;
            used(index_end) = 1;
            ids(i) = 1;
        end
    end
    
    [eventimes,index] = sort(eventimes);
    eventids = eventids(index);
    durations = durations(index);
else
    eventids = 0;
    eventimes = 0;
    durations = 0;
end

f = f(used==0);
temp = unique(description(f));
for i=1:length(temp)
    warning(sprintf('Ignored event %s',temp{i}));
end

ids_return = ids;