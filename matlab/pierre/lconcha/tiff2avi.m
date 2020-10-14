% create an .avi file from a bunch of tiffs

filename = input('Enter file name:  ','s');
fps      = input('Enter frames per second:  ');
avi = avifile(filename,'fps',fps,'compression','indeo5');

D = dir;
nF = 0;
h = waitbar(0,'Converting to AVI');
numFiles = length(D);

fh = figure;
set(fh,'Position',[353 240 560 420]);

for f = 3 : numFiles
   if regexp(D(f).name,'\.tif')
       disp(D(f).name)
       frame   = imread(D(f).name);
       nF = nF+1;
       imagesc(frame);axis image;colormap(gray);
       
       hold on
       plot([0 256],[30,30],'LineWidth',2,'Color',[0.5,0.5,0.5])
       progress = nF./60
       ht = text(115,20,'Time');set(ht,'Color','w');set(ht,'FontSize',14)
       plot([0 progress*256],[30 30],'LineWidth',3,'Color','w')
       hold off
       
       fname=D(f).name;
       if regexpi(D(f).name,'.*\.tif')
            frNum = regexpi(fname,'(\d*)\.tif','tokens');
            frNum = cell2mat(frNum{:});
            fr = getframe;
            im = frame2im(fr);
            nfn = [num2str(frNum) '.jpg']
            imwrite(im,nfn)
       end
       
       avi = addframe(avi,fr);
       %avi = addframe(avi,im2frame(frame));
       waitbar(f./numFiles,h);
   end
end
close(h);
avi = close(avi);
disp([num2str(nF) ' included in file ' filename])