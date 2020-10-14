function M3 = extraction(M1,orientation,epaisseur,dimpix)

switch orientation
    
    case 'sag'

% Extraction d'une coupe sagittale à partir de coupes axiales

M2 = reshape(M1,[256 35]); size(M2);
T0 = maketform('affine',[0 -epaisseur/dimpix; 1 0; 0 0]);
R2 = makeresampler({'cubic','nearest'},'fill');
M3 = imtransform(M2,T0,R2);

    case 'cor'

% Extraction d'une coupe coronale à partir de coupes axiales

M2 = reshape(M1,[256 35]); size(M2);
T0 = maketform('affine',[0 -epaisseur/dimpix; 1 0; 0 0]);
R2 = makeresampler({'cubic','nearest'},'fill');
M3 = imtransform(M2,T0,R2);

end