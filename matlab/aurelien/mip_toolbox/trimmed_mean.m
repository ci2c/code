

function imgo = trimmed_mean(img,ksize,alpha)

M = ksize*ksize;
N = floor(alpha*M);
W = 1/(M-2*N);
nimg = ref_bound(img,ksize);
ss = 0.5*(ksize-1);
[row col] = size(img);
rown = row+2*ss;
coln = col+2*ss;

m =-ss:ss;
n =-ss:ss;

for i=ss+1:rown-ss
for j=ss+1:coln-ss    
    simg = nimg(i+m,j+n); 
    x = sort(simg(:));
    imgo(i,j) = W*sum(x(N+1:M-N));   
end;
end;
imgo = imgo(ss+1:rown-ss,ss+1:coln-ss);


% fun = inline('trimmed_mean_subfun(x,ksize,alpha)','x','ksize','alpha');
% imgo = colfilt(img,[ksize ksize],'sliding',fun,ksize,alpha);


