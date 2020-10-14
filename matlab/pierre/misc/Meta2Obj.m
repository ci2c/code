function Meta2Obj(infilename,outfilename)
%meta2obj(infilename, outfilename)
% function converts an inputfile in META format (SPHARM)
% into Minc Obj format (for Surfstat)

% author: boris@bic.mni.mcgill.ca
% created: September 15th

    % open file
    fid = fopen(infilename);
    % skip lines until NPoints tag
    while 1
        tline = fgetl(fid);
        disp(tline);
        if ~isempty(findstr(tline, 'NPoints'))
            break;
        end
    end
    
    numvert = sscanf(tline, 'NPoints = %f');
    
    % discard lines until 'Points =' tag
    while 1
        tline = fgetl(fid);
        disp(tline);
        if ~isempty(findstr(tline, 'Points ='))
            break;
        end
    end
    
    % read points
    surf.coord=fscanf(fid,'%f',[4,numvert]);
    
    tline = fgetl(fid); 
    tline = fgetl(fid); 
    tline = fgetl(fid); 
    tline = fgetl(fid); 
    
    numtri = numvert*2 - 4;
    surf.tri=fscanf(fid,'%f',[4,numtri]);
    fclose(fid);

    % discard index lines
    surf.tri(1,:) = [];
    surf.coord(1,:) = [];

    surf.tri = surf.tri + 1;
    % surf.coord
    
    % compute normals
%     u1=surf.coord(:,surf.tri(1,:));
%     d1=surf.coord(:,surf.tri(2,:))-u1;
%     d2=surf.coord(:,surf.tri(3,:))-u1;
%     c=cross(d1,d2,1);
%     surf.normal=zeros(3,numvert);
%     for j=1:3
%         for k=1:3
%            surf.normal(k,:)=surf.normal(k,:)+accumarray(surf.tri(j,:)',c(k,:)')';
%         end
%     end
%     surf.normal=surf.normal./(ones(3,1)*sqrt(sum(surf.normal.^2,1)));

    surf.normal = getSurfNormals(surf);

    
    % add color (no color)
    surf.colr=[1 1 1 1]';
    
     % write obj file
     fid=fopen(outfilename,'w');
         fprintf(fid,'P 0.3 0.3 0.4 10 1 %d \n',numvert);
         fprintf(fid,'%f %f %f \n',surf.coord);
         fprintf(fid,'  \n');
         fprintf(fid,'%f %f %f \n',surf.normal);
         fprintf(fid,'  \n');
         fprintf(fid,'%d %d \n',numtri,(size(surf.colr,2)>1)*2);
         fprintf(fid,'%f %f %f %f \n',surf.colr);
         fprintf(fid,'  \n');
         fprintf(fid,'%d %d %d %d %d %d %d %d \n',(1:numtri)*3);
         fprintf(fid,'  \n');
         fprintf(fid,'%d %d %d %d %d %d %d %d \n',surf.tri-1);
     fclose(fid);
