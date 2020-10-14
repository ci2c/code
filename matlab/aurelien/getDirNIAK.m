function [files_in,mainpath] = getDirNIAK(pathname)
%% retrieve the anatomical directory and functional directory for NIAK.
%
%   Input: pathname
%
%   Output: files_in 
%   ----------------------------------------------------------------------
%   You need to stucture the file in th efalowing way: 
%   /groupstudy/ --- /patientname1_ss/ --- /anat/ the anatomical files
%                                                  are in this dir.
%                                           /fmri/ the fmri files are in
%                                                  this dir.
%                                        
%                     /patientname2_ss/ --- /anat/ the anatomical files
%                                                  are in this dir.
%                                           /fmri/ the fmri files are in
%                       .                          this dir.
%                       .
%                       .
%
%   *ss is the session number
%   ----------------------------------------------------------------------
%
%   Autor: Christian L Dansereau McGill 2010
%

basepath = '';
files_in=[];

pathname2 = strrep(pathname, filesep, '/');
pathname2 = cat(2, pathname2, '/');

mainpath = pathname2;

files=sub_getDir(cat(2,pathname2,'/*'));

% Check if its a group or a single subject

%% Single Subject
if ~isempty(sub_getDir([pathname2 '/anat']))
    
    files_in = sub_add2Struct(files_in,pathname2(1:end-1));
    
else

    %% Group
    for i=1:size(files,1)
        if files(i).isdir && ~strncmp('fmri_preprocess', files(i).name,15) && ~strncmp('basc', files(i).name,4)
            files_in = sub_add2Struct(files_in,[pathname2 files(i).name]);  
        end  
    end
    
end
    
    sep=filesep;
    [pathstr pname] = fileparts(pathname);
    ind = exist(cat(2,pathname,'/mri/transforms/talairach.xfm'),'file');
    if ind==2
        eval(['files_in.' pname '.transformation = cat(2,pathname,''/mri/transforms/talairach.xfm'');' ]);
    end

end

%% sub-function return the list of Directories
function out=sub_getDir(path)

    namelist =dir(path);
    
    if size(namelist,1)==0
        out =[];
    else
        out=namelist(3:end);
    end

end

%% sub-function add the anat and the fmri files
function [struct]=sub_add2Struct(struct,path)

    % Add all the anatomical files
    anatF=sub_getDir(cat(2,path,'/anat/*'));
    if ~isempty(anatF)
        for n=1:size(anatF,1)     
            [pathstr, nameDir]=fileparts(path);
            name=nameDir(1:findstr(nameDir,'_')-1);
            tmppath = cat(2,path, '/anat/');
            eval(['struct.' name '.anat = cat(2,tmppath,anatF(n).name);' ]);
        end
    end

    % Add all the fMRI files
    fmriF=sub_getDir(cat(2,path,'/fmri/*'));
    if ~isempty(fmriF)
        for n=1:size(fmriF,1)     
            [pathstr, nameDir]=fileparts(path);
            name=nameDir(1:findstr(nameDir,'_')-1);
            session=nameDir(findstr(nameDir,'_')+1:end);
            tmppath = cat(2,path, '/fmri/');
%             eval(['struct.' name '.fmri.session' session(1) '{n} = cat(2,tmppath,fmriF(n).name);' ]);
            eval(['struct.' name '.fmri{n} = cat(2,tmppath,fmriF(n).name);' ]);
        end
    end
    
%     ind = exist(cat(2,path,'mri/transforms/talairach.xfm'),'file');
%     if ind==2
%     eval(['files_in.' name '.transformation = cat(2,path,transF);' ]);
%     end
end