function cat_fibers(NbFibres, TailleSplit, outdir, outpref,outsuf)
% usage : split_fibers(fib_path, outdir, outpref)
%
% Inputs :
%       fib_path           : Path to the .tck fiber file
%                            or fiber structure as provided by f_readFiber_tck
%       outdir             : Path to the output directory to store the
%                            split fiber file
%       outpref            : Prefix of the output files
%       outsuf             : Suffix of the output files
% Open the fibers and save it into small files (max. 10'000 fibers each)
% They will be stored in OUTDIR and named : 
% OUTPREF_part00001.tck
% OUTPREF_part00002.tck
% And so on...
%
% Pierre Besson @ CHRU Lille, July 2013

if nargin == 4
    outsuf=[];
end

NbSplit = NbFibres/TailleSplit;

fibers.fiber = [];
fibers.nFiberNr = length(fibers.fiber);

for i = 1 : NbSplit
    file=fullfile(outdir, [outpref '_part' num2str(i, '%.6d') outsuf '.tck'])
    Fib = f_readFiber_tck(file);
    fibers.nFiberNr = fibers.nFiberNr + length(Fib.fiber);
    fibers.fiber = [ fibers.fiber Fib.fiber ];
end
save_tract_tck(fibers, fullfile(outdir, [outpref '.tck']));