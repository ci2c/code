function split_fibers(Fib, outdir, outpref)
% usage : split_fibers(fib_path, outdir, outpref)
%
% Inputs :
%       fib_path           : Path to the .tck fiber file
%                            or fiber structure as provided by f_readFiber_tck
%       outdir             : Path to the output directory to store the
%                            split fiber file
%       outpref            : Prefix of the output files
%
% Open the fibers and save it into small files (max. 10'000 fibers each)
% They will be stored in OUTDIR and named : 
% OUTPREF_part00001.tck
% OUTPREF_part00002.tck
% And so on...
%
% Pierre Besson @ CHRU Lille, July 2013

if nargin ~= 3
    error('invalid usage');
end

if ischar(Fib)
    Fib = f_readFiber_tck(Fib);
end

low_bound = 1 : 10000 : Fib.nFiberNr;
high_bound = [low_bound(2:end) - 1, Fib.nFiberNr];

for i = 1 : length(low_bound)
    fibers.fiber = Fib.fiber(low_bound(i) : high_bound(i));
    fibers.nFiberNr = length(fibers.fiber);
    save_tract_tck(fibers, fullfile(outdir, [outpref '_part' num2str(i, '%.6d') '.tck']));
    clear fibers;
end