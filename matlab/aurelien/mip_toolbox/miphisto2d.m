function H = miphisto2d(Img,D)
% MIPHISTO2D  % Calculates the co-occurence matrix at different degrees(D)
%
%   H = MIPHISTO2D(IMG,D)
% 
%   IMG is the input iamge. The output is the two-dimensional histogram H.
% 
% 
%   See also MIPIMHIST

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06 
%   The Medical Image Processing Toolbox

maxI = max(Img(:));
minI = min(Img(:));
levels = maxI+1;
H = zeros(levels,levels);
[r c] = size(Img);
Img = padarray(Img,[1 1],'replicate','both');
% 0 degrees
switch D
    case 0
        for i=2:r
            for j=2:c 
                m=Img(i,j)+1;
                n=Img(i,j-1)+1;
                H(m,n)=H(m,n)+1;
                n=Img(i,j+1)+1;
                H(m,n)=H(m,n)+1;
            end
        end
    case 90
        % 90 degrees
        for i=2:r
            for j=2:c 
                m=Img(i,j)+1;
                n=Img(i-1,j)+1;
                H(m,n)=H(m,n)+1;
                n=Img(i+1,j)+1;
                H(m,n)=H(m,n)+1;
            end
        end
    case 45
        % 45 degrees
        for i=2:r
            for j=2:c 
                m=Img(i,j)+1;
                n=Img(i-1,j+1)+1;
                H(m,n)=H(m,n)+1;
                n=Img(i+1,j-1)+1;
                H(m,n)=H(m,n)+1;
            end
        end
        
    case 135    
        % 135 degrees
        for i=2:r
            for j=2:c 
                m=Img(i,j)+1;
                n=Img(i-1,j-1)+1;
                H(m,n)=H(m,n)+1;
                n=Img(i+1,j+1)+1;
                H(m,n)=H(m,n)+1;
            end
        end
    otherwise 
        disp('unknown degree');
end