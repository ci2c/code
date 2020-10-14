try
    if (exist('matrix_size','var')==0)
        matrix_size = input('matrix size = ');
    end
    if (exist('voxel_size','var')==0)
        voxel_size = input('voxel size = ');
    end
    matrix_size = matrix_size(1:3);

    fid = fopen('iField.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        A = A(1:2:end) + 1i*A(2:2:end);
        iField = reshape(A, [ numel(A)/prod(matrix_size) matrix_size]);
        iField = permute(iField, [2 3 4 1]);
    end
   
    
    fid = fopen('iMag.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        iMag = reshape(A, matrix_size);
    end
    
    
    fid = fopen('Mask.bin');
    if (fid>0)
        A = fread(fid, inf, 'int32');
        fclose(fid);
        Mask = reshape(A, matrix_size);
    end
    
    fid = fopen('N_std.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        N_std = reshape(A, matrix_size);
    end
    
    fid = fopen('RDF.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        RDF = reshape(A, matrix_size);
    end
    
    fid = fopen('iFreq.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        iFreq = reshape(A, matrix_size );
    end
    
    fid = fopen('iFreq_raw.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        iFreq_raw = reshape(A, matrix_size );
    end
    
    fid = fopen('R2star.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        R2star = reshape(A, matrix_size );
    end
    
    ttrecon = 0;
    fid = fopen('recon_QSM.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        QSM = reshape(A, matrix_size );
        ttrecon = ttrecon+1;
    end
    
    for echo=0:16;
        filename = sprintf('recon_QSM_%02.0f.bin',echo);
        fid = fopen(filename);
        if (fid>0)
            A = fread(fid, inf, 'float');
            fclose(fid);
            cmdln = sprintf('QSM%02.0f = reshape(A, matrix_size );',echo);
            eval(cmdln);
            ttrecon = ttrecon+1;
            if ttrecon==1
                final_echo = echo;
            end
        end
    end
    
    if (ttrecon==1)&&(exist('QSM','var')==0)
        cmdln = sprintf('QSM =  QSM%02.0f;',final_echo);
        eval(cmdln);
        cmdln = sprintf('clear QSM%02.0f;',final_echo);
        eval(cmdln);
    end
    
    fid = fopen('swi.bin');
    if (fid>0)
        A = fread(fid, inf, 'float');
        fclose(fid);
        SWI = reshape(A, matrix_size );
    end
    
    %%%%%%%%%%%%%% run the following only after RDF is generated
    if exist('RDF.bin','file')
        
        if exist('Mask','var')
            d1 = max(max(Mask,[],2),[],3);
            d1first = find(d1,1,'first');
            d1last = find(d1,1,'last');
            
            d2 = max(max(Mask,[],1),[],3);
            d2first = find(d2,1,'first');
            d2last = find(d2,1,'last');
            
            d3 = max(max(Mask,[],1),[],2);
            d3first = find(d3,1,'first');
            d3last = find(d3,1,'last');
            
            matrix_size2 = [floor((d1last - d1first+20)/2)*2,...
                floor((d2last - d2first+20)/2)*2,...
                floor((d3last - d3first+20)/2)*2];
            
        else
            matrix_size2 = input('cropped matrix size = ');
        end
        
        fid = fopen('Gw.bin');
        if (fid>0)
            A = fread(fid, inf, 'int32');
            fclose(fid);
            A = reshape(A, [matrix_size2 3] );
            wG = zeros([matrix_size 3]);
            wG(d1first:d1last, d2first:d2last, d3first:d3last,:) = A(1:d1last - d1first+1, 1:d2last - d2first+1, 1:d3last - d3first+1,:);
        end
        
        fid = fopen('DpK.bin');
        if (fid>0)
            A = fread(fid, inf, 'float');
            fclose(fid);
            A = reshape(A, [matrix_size2] );
            DpK = zeros(matrix_size);
            DpK(d1first:d1last, d2first:d2last, d3first:d3last) = A(1:d1last - d1first+1, 1:d2last - d2first+1, 1:d3last - d3first+1);
        end
        
        fid = fopen('CGb.bin');
        if (fid>0)
            A = fread(fid, inf, 'float');
            fclose(fid);
            A = reshape(A, [matrix_size2] );
            CGb = zeros(matrix_size);
            CGb(d1first:d1last, d2first:d2last, d3first:d3last) = A(1:d1last - d1first+1, 1:d2last - d2first+1, 1:d3last - d3first+1);
        end
        
        fid = fopen('b0.bin');
        if (fid>0)
            A = fread(fid, inf, 'float');
            fclose(fid);
            A = reshape(A, [2 matrix_size2] );
            A = squeeze(A(1,:,:,:) + 1i*A(2,:,:,:));
            b0 = zeros(matrix_size);
            b0(d1first:d1last, d2first:d2last, d3first:d3last) = A(1:d1last - d1first+1, 1:d2last - d2first+1, 1:d3last - d3first+1);
        end
        
        
        fid = fopen('Dw.bin');
        if (fid>0)
            A = fread(fid, inf, 'float');
            fclose(fid);
            A = reshape(A, matrix_size2 );
            w = zeros(matrix_size);
            w(d1first:d1last, d2first:d2last, d3first:d3last) = A(1:d1last - d1first+1, 1:d2last - d2first+1, 1:d3last - d3first+1);
        end
        
        fid = fopen('b_est.bin');
        if (fid>0)
            A = fread(fid, inf, 'float');
            fclose(fid);
            A = reshape(A, matrix_size2 );
            iFreq_prime = zeros(matrix_size);
            iFreq_prime(d1first:d1last, d2first:d2last, d3first:d3last) = A(1:d1last - d1first+1, 1:d2last - d2first+1, 1:d3last - d3first+1);
        end
        
        fid = fopen('corrupted_points.bin');
        if (fid>0)
            A = fread(fid, inf, 'int32');
            fclose(fid);
            A = reshape(A, matrix_size2 );
            bad_points = zeros(matrix_size);
            bad_points(d1first:d1last, d2first:d2last, d3first:d3last) = A(1:d1last - d1first+1, 1:d2last - d2first+1, 1:d3last - d3first+1);
        end
        
    end
    
catch err
    disp(['Matrix size may be wrong.']);
end
clear err A fid ans d1 d1first d1last d2 d2first d2last d3 d3first d3last matrix_size2 filename cmdln ttrecon final_echo echo
