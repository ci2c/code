
function [ROI] = roicirclecrop(im)

% im - input image

% draw circle on image
% select two point using mouse click
% 1st point would be mid-point of the circle
% 2nd point would be the radius of the circle

% Usage EX-1.  
%image=imread('onion.png');
%ROI = roicirclecrop(image);

% Copyright to V.Sapthagirivasan, Sr.Engineer, IiTechnologies, Chennai,India.
% Mail me @  sapthagiri.ece@gmail.com for clarification

[r c wid] = size(im);

if wid==1
    k(:,:,1)=im;
    k(:,:,2)=im;
    k(:,:,3)=im;
else
    k=im;
end

figure;
imshow(k);

pt = ginput(2)

x1 = pt(1,1);
y1 = pt(1,2);
x2 = pt(2,1);
y2 = pt(2,2);
 x = [x1 x2];
 y = [y1 y2];

r = sqrt((x2-x1)^2 + (y2-y1)^2)

xtl = x1-r;
xtr = x1+r;
xbl = x1-r;
xbr = x1+r;

ytl = y1+r;
ytr = y1+r;
ybl = y1-r;
ybr = y1-r;

for i=1:size(k,1)
    for j=1:size(k,2)
        x2 = j;
        y2 = i;
        val = floor(sqrt((x2-x1)^2 + (y2-y1)^2));
        if(val == floor(r))
            nim(i,j,1) = 255;
            nim(i,j,2) = 0;
            nim(i,j,3) = 0;
            BW(i,j) = 1;

        else
            nim(i,j,1) = k(i,j,1);
            nim(i,j,2) = k(i,j,2);
            nim(i,j,3) = k(i,j,3);
            BW(i,j) = 0;
        end
    end
end

SE = strel('disk',1);
BW3 = imdilate(BW,SE);

I2 = imfill(BW3,'holes');

for i=1:size(k,1)
    for j=1:size(k,2)
        if(I2(i,j)==1)
            ni(i,j,1) = k(i,j,1);
            ni(i,j,2) = k(i,j,2);
            ni(i,j,3) = k(i,j,3);
        else
            ni(i,j,1) = 0;
            ni(i,j,2) = 0;
            ni(i,j,3) = 0;
        end
    end
end

ni = uint8(ni);

X1 = x1-r;
X2 = x1+r;

Y1 = y1-r;
Y2 = y1+r;

ROI = imcrop(ni,[X1,Y1,abs(X2-X1),abs(Y2-Y1)]);
if wid==1
    ROI = ROI(:,:,1);
end
close all;
return;
