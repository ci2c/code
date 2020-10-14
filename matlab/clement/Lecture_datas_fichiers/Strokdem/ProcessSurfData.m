clear all; close all;

% Get defformation field

indir = '/NAS/dumbo/gadeline/memoire/shape';
struc = {'output_caudate_l','output_caudate_r','output_pallidum_l','output_pallidum_r','output_putamen_l','output_putamen_r'};

for k = 1:length(struc)
    
    tmpdir = fullfile(indir,struc{k});
    
    filenames = conn_dir(fullfile(tmpdir,'*.obj'));
    SurfFile  = fullfile(tmpdir,'template','template_SPHARM.meta');
    if exist(SurfFile,'file')
        
        [p,n,e] = fileparts(SurfFile);
        nameR   = fullfile(p,[n '.obj']);
        
        if ~exist(nameR,'file')
            Meta2Obj(SurfFile,nameR);
        end
        SurfFile = nameR;
        
    else
        
        disp([struc{k} ': no template file']);
        
    end

    SurfRef = SurfStatReadSurf(SurfFile);
    v       = size(SurfRef.coord,2);

    u1 = SurfRef.coord(:,SurfRef.tri(:,1));
    d1 = SurfRef.coord(:,SurfRef.tri(:,2))-u1;
    d2 = SurfRef.coord(:,SurfRef.tri(:,3))-u1;
    c  = cross(d1,d2,1);
    SurfRef.normal = zeros(3,v);
    for j=1:3
        for k=1:3
            AAA = accumarray(SurfRef.tri(:,j),c(k,:)')';
            try
                SurfRef.normal(k,:)=SurfRef.normal(k,:) + AAA;
            catch
                SurfRef.normal(k,:)=SurfRef.normal(k,:) + [AAA, zeros(1, length(SurfRef.normal)-length(AAA))];
            end
        end
    end
    SurfRef.normal=SurfRef.normal./(ones(3,1)*sqrt(sum(SurfRef.normal.^2,1)));

    N = size(filenames,1);
    cmd = sprintf('Number of files : %d',N);
    disp(cmd);

    for i = 1 : N
        Temp = deblank(filenames(i,:));
        if ~exist([Temp(1:end-4), '_disp.txt'],'file') || ~exist([Temp(1:end-4), '_disp_norm.txt'],'file')
            Surf = SurfStatReadSurf(Temp);
            Disp = Surf.coord - SurfRef.coord;
            DispNorm = dot(Disp, SurfRef.normal, 1);
            SurfStatWriteData([Temp(1:end-4), '_disp.txt'], Disp);
            SurfStatWriteData([Temp(1:end-4), '_disp_norm.txt'], DispNorm);
        end
    end
    
end
