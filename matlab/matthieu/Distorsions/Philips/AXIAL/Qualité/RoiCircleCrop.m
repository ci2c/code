function ROI = RoiCircleCrop(im,xcenter,ycenter,r)

%% Détermination du contour binaire de la ROI
for i=1:size(im,1)
    for j=1:size(im,2)
        x2 = j;
        y2 = i;
        val = floor(sqrt((x2-xcenter)^2 + (y2-ycenter)^2));
        if(val == floor(r))
            BW(i,j) = 1;
        else
            BW(i,j) = 0;
        end
    end
end

%% Dilatation par un élément de type disque
SE = strel('disk',1);
BW2 = imdilate(BW,SE);

%% Remplissage de la ROI et multiplication de l'image par le masque de la ROI
BW3 = imfill(BW2,'holes');
BW3=uint16(BW3);
ROIbc = im.*BW3;

%% Extraction de la ROI à partir de l'image masquée
X1 = xcenter-r;
X2 = xcenter+r;

Y1 = ycenter-r;
Y2 = ycenter+r;

ROI = imcrop(ROIbc,[X1,Y1,abs(X2-X1),abs(Y2-Y1)]);