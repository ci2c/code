function fuse_manualmarkers_to_trig(markers_file, trigger_file, outfile)
% usage : fuse_manualmarkers_to_trig(MARKERS_FILE, TRIGGER_FILE, OUTFILE)
%
% Include manual marking into triggering file info
%
% Inputs :
%    MARKERS_FILE        : File containing manual markers .markers
%    TRIGGER_FILE        : File containing scans triggering as provided by
%                           ANALYZE
%    OUTFILE             : Name of the output file
%
% Pierre Besson @ CHRU Lille, 2011

if nargin ~= 3
    error('invalid usage');
end

% Load manual markers
fid = fopen(markers_file, 'r');
line = fgetl(fid);
SamplingRate = regexpi(line,'(\d*)Hz', 'tokens');
SamplingRate = str2num(char(SamplingRate{1}));
SamplingInterval = 1000 / SamplingRate;
fclose(fid);

[Type, Description, Position, Length, Channel] = textread(markers_file, '%s %s %d %d %s', 'delimiter', ',', 'headerlines', 2);

% Load scan triggers
[Time, Sample, Value] = textread(trigger_file, '%s %d %d', 'headerlines', 2, 'delimiter', ' ');

% Set markers sampling rate to triggers sampling rate
C1 = char(Time(1));
C1 = C1(end-5:end);
C2 = char(Time(2));
C2 = C2(end-5:end);
T1 = str2num(C1(1:2)) + str2num(C1(3:end)) / 1000;
T2 = str2num(C2(1:2)) + str2num(C2(3:end)) / 1000;
TR_fmri = T2-T1;
SamplingRateTrigger = round( (Sample(2) - Sample(1)) / TR_fmri );
SamplingIntervalTrigger = 100 ./ SamplingRateTrigger;

SamplingRateRatio = SamplingRateTrigger / SamplingRate;
Position = SamplingRateRatio .* Position;


% Reorder events
TT = [Position; Sample];
[S, I] = sort(TT);
N_markers = length(Position);

% Print the output
fid = fopen(outfile, 'w');
fprintf(fid, 'Sampling rate: %dHz, SamplingInterval: %.2fms\n', SamplingRateTrigger, SamplingIntervalTrigger);
fprintf(fid, 'Type, Description, Position, Length, Channel\n');
for i = 1 : length(I)
    if I(i) > N_markers
        fprintf(fid, 'Scanner, Scan Start, %d, 1, All\n', S(i));
    else
        fprintf(fid, 'Comment, %s, %d, 1, %s\n', char(Description(I(i))), S(i), char(Channel(I(i))));
    end
end
fclose(fid);
