function CompileMEX(Opts)
% function CompileMEX([Opts])
%
% Compile MEX will systematically traverse every subdirectory of the current
% directory and compile every file with extensions ".c", ".cpp" or ".c++".
%
% In:
%    Opts = a string specifying parameters to pass to the MEX command
%
% Dependencies:
%    none
%
% Version History:
%    jcb    02/06/06    initial version
%

if ~exist('Opts')
   Opts = [];
end

% figure out the syntax for calling MEX
if ~isempty(Opts)
   MEXString = ['mex ' Opts];
else
   MEXString = 'mex -O';
end


fprintf('scanning directory %s ... \n', pwd);

% get the directory listing
listing = dir;


% compile each file in the directory
for j = 1:length(listing)

   % look for C files
   name = listing(j).name;
   ext  = getext(name);

   if strcmpi(ext, '.c') | ...
      strcmpi(ext, '.cpp') | ...
      strcmpi(ext, '.c++')

      exestr = sprintf('%s "%s"', MEXString, name);
      fprintf('\texecuting: %s\n', exestr);
      eval(['! ' exestr]);
   end
end

% now recursively enter each directory
for j=1:length(listing)
   % look for C files
   name = listing(j).name;
   ext  = getext(name);

   if ~strcmpi(ext, '.') & ~strcmpi(ext, '..') & ...
      listing(j).isdir

      cd(name);
      feval('CompileMex', Opts);
      cd('..');
   end
end

function ext = getext(filename)
% function ext = getext(filename)
%
% Given a filename, return the extension.

ext = '';   % assume no extension by default
matches = strfind(filename, '.');
if ~isempty(matches)
   lastmatch = matches(length(matches));
   ext = filename(lastmatch:length(filename));
end







