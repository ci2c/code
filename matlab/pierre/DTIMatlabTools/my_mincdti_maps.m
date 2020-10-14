function msg = my_mincdti_maps(inputImages,outputImages)



try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in the input images                          @
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle = openimage(inputImages.xx);
    info.DimSizes       = getimageinfo(handle,'DimSizes');
    xx = getimages(handle,1:info.DimSizes(2));
    xx = reshape(xx,numel(xx),1);
    closeimage(handle);
    
handle = openimage(inputImages.xy);
    info.DimSizes       = getimageinfo(handle,'DimSizes');
    xy = getimages(handle,1:info.DimSizes(2));
    xy = reshape(xy,numel(xy),1);
    closeimage(handle);
    
handle = openimage(inputImages.xz);
    info.DimSizes       = getimageinfo(handle,'DimSizes');
    xz = getimages(handle,1:info.DimSizes(2));
    xz = reshape(xz,numel(xz),1);
    closeimage(handle);
    
handle = openimage(inputImages.yy);
    info.DimSizes       = getimageinfo(handle,'DimSizes');
    yy = getimages(handle,1:info.DimSizes(2));
    yy = reshape(yy,numel(yy),1);
    closeimage(handle);
    
handle = openimage(inputImages.yz);
    info.DimSizes       = getimageinfo(handle,'DimSizes');
    yz = getimages(handle,1:info.DimSizes(2));
    yz = reshape(yz,numel(yz),1);
    closeimage(handle);
    
handle = openimage(inputImages.zz);
    info.DimSizes       = getimageinfo(handle,'DimSizes');
    zz = getimages(handle,1:info.DimSizes(2));
    zz = reshape(zz,numel(zz),1);
    closeimage(handle);

matrixDim = [info.DimSizes(4) info.DimSizes(3) info.DimSizes(2)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a mask if possible                           @
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xyz     = [xx yy zz];
full    = find(any(xyz,2));
notfull = find(~any(xyz,2));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allocate memory                                   @
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda1 = nan(size(xx));
lambda2 = nan(size(xx));
lambda3 = nan(size(xx));
red     = nan(size(xx));
green   = nan(size(xx));
blue    = nan(size(xx));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diagonalize tensor per pixel                      @
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'\nDiagonalizing tensor...');
for elem = 1 : numel(full)
    r = full(elem);
    
    if mod(r,numel(xx)./info.DimSizes(2)) == 0
        fprintf(1,'.');
    end
    
    % Set up the tensor elements
    ten = [xx(r) xy(r) xz(r);...
           xy(r) yy(r) yz(r);...
           xz(r) yz(r) zz(r)];             
    
    % Use matlab's function to diagonalize
    [V,D] = eig(ten);

    % Obtain eigenvalues and eigenvectors
    D           = eig(ten);                    
    D           = abs(D);
    D           = sort(D);                      %sort the eigenvalues (upwards)
    e1          = D(3,1);e1 = e1*2;
    e2          = D(2,1);e2 = e2*2;
    e3          = D(1,1);e3 = e3*2;
    lambda1(r)  = e1;
    lambda2(r)  = e2;
    lambda3(r)  = e3;
    V           = abs(V);                       %get the x,y,z components of e3   
    
    % Get the first eigenvector's components.
    red(r)      = V(1,3);
    green(r)    = V(2,3);
    blue(r)     = V(3,3);
    
end
fprintf(1,' Done. \n\n');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second order parameters                           @
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
adc       = (lambda1 + lambda2 + lambda3) ./3;
numerator = sqrt( (lambda1-adc).^2 + (lambda2-adc).^2 + (lambda3-adc).^2 );
denom     = sqrt( lambda1.^2 + lambda2.^2 + lambda3.^2);
fa        = (sqrt(3) ./ sqrt(2)) .* (numerator ./ denom);

% Mask the data
lambda1(notfull) = zeros(size(notfull));
lambda2(notfull) = zeros(size(notfull));
lambda3(notfull) = zeros(size(notfull));
red(notfull)     = zeros(size(notfull));
green(notfull)   = zeros(size(notfull));
blue(notfull)    = zeros(size(notfull));
fa(notfull)      = zeros(size(notfull));
adc(notfull)     = zeros(size(notfull));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write output files                                @
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'Writing images... ');
fprintf(1,'red... ');
handle = newimage(outputImages.red,info.DimSizes,inputImages.xx,'float');
    red = reshape(red,numel(red)./info.DimSizes(2),info.DimSizes(2));
    putimages(handle,red,1:info.DimSizes(2));
    closeimage(handle);
fprintf(1,'green... ');
handle = newimage(outputImages.green,info.DimSizes,inputImages.xx,'float');
    green = reshape(green,numel(red)./info.DimSizes(2),info.DimSizes(2));   
    putimages(handle,green,1:info.DimSizes(2));
    closeimage(handle);
fprintf(1,'blue... ');
handle = newimage(outputImages.blue,info.DimSizes,inputImages.xx,'float');
    blue = reshape(blue,numel(red)./info.DimSizes(2),info.DimSizes(2));
    putimages(handle,blue,1:info.DimSizes(2));
    closeimage(handle);
fprintf(1,'fa... ');    
handle = newimage(outputImages.fa,info.DimSizes,inputImages.xx,'float');
    fa = reshape(fa,numel(red)./info.DimSizes(2),info.DimSizes(2));
    putimages(handle,fa,1:info.DimSizes(2));
    closeimage(handle);
fprintf(1,'adc... ');    
handle = newimage(outputImages.adc,info.DimSizes,inputImages.xx,'float');
    adc = reshape(adc,numel(red)./info.DimSizes(2),info.DimSizes(2));
    putimages(handle,adc,1:info.DimSizes(2));
    closeimage(handle);
fprintf(1,' Done.\n\n');    
catch
   msg = lasterr; 
   return;
end

msg = 'OK';

