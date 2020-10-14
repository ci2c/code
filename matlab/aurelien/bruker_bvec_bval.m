function bruker_bvec_bval(method_file,outname)

% Parse bruker method file and save outname.bvec and outname.bval
% file : path to 'method' file
% outname : basename for created bvec and bval files (mandatory)

if nargin == 1
    error('Invalid usage, you must set an outname');
end

fid = fopen(method_file);

while ( ~feof( fid ) )
    str = fgetl(fid);
        if regexpi( str, 'PVM_DwNDiffDir=')
            ndiffdir=str2num(str(findstr(str,'=')+1:end));
        elseif regexpi( str, 'PVM_DwDir=')
            [matrix count] = fscanf( fid, '%f', ndiffdir*3 );
        elseif regexpi( str, 'PVM_DwAoImages=')
            nbdoimage=str2num(str(findstr(str,'=')+1:end));
        elseif regexpi( str, 'PVM_DwBvalEach=')  
            bval=fscanf( fid, '%f', 1 );
        end
end
doimage=zeros(3,nbdoimage)';
bvec=reshape(matrix,3,ndiffdir)';
bvec=[doimage;bvec];
bval=[zeros(1,nbdoimage) repmat(bval,1,ndiffdir)]';
dlmwrite([outname '.bvec'],bvec,'delimiter',' ');
dlmwrite([outname '.bval'],bval,'delimiter',' ');
fclose(fid);