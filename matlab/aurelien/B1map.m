sinalpha1=0.3908;
tanalpha1=0.4246;
sinalpha2=0.848;
tanalpha2=-1.6;
TR=0.5

[fid,chemin]=uigetfile('');
disp([chemin fid])
[fid2,chemin2]=uigetfile('');
disp([chemin2 fid2]);

ima1=dicomread([chemin fid]);
size(ima1)
ima1=double(ima1);

ima2=dicomread([chemin2 fid2]);
size(ima2)
ima2=double(ima2);

ima1=ima1./0.0022235;
ima2=ima2./0.00157987;

rap=ima2./(2*ima1);

test=rap;
tic
for j = 1:60,
    for i = 1:96
        for k = 1:96
        pix=rap(i,k,1,j);
        if (pix < 1);
            rap(i,k,1,j)=pix;
        else
            rap(i,k,1,j)=NaN;
        end
        end
    end
end
toc     

imagesc(rap(:,:,1,10));

B1map=acos(rap);
B1mapdegre=180.*(B1map./pi);

imagesc(B1mapdegre(:,:,1,40),[40 60]);