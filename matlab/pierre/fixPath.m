% Add the local SVN to matlab's path
%
% This way you will be running the most recent version of the noel tools!
% Of course, this means that you do an svn checkout first...
% 
% You only need to have one directory saved into your matlab's path, which
% is where this file is saved. Typically it's just:
% >> addpath('${NOELSOFT_DIR}/MatlabTools/')
% >> savepath
%
% Now all you have to do every time you enter matlab is run:
% >> fixPath
%
% The new path is not saved on purpose. This way, the SVN might change, but
% your matlab's path will be up-to-date every time.
%
% Luis Concha. Noel lab. BIC, MNI. September, 2008.



% Find all subdirectories in noelsoft's directory that are not hidden
!find $NOELSOFT_DIR -type d -iregex "[^\.]**" > ~/fixPath.txt
% Also add those subdirectories in LOCALSOFT
!find ${LOCALSOFT}/imaging/install/matlab -type d -iregex "[^\.]**" >> ~/fixPath.txt

% And for each subdirectory, add it to path
fid = fopen('~/fixPath.txt','r');
while 1
   tline = fgetl(fid);
   if ~ischar(tline),break,end
  fprintf(1,'Adding to path: %s\n',tline);
  addpath(tline);
end
fclose(fid);
clear fid tline




