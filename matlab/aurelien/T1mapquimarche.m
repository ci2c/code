clear all;

% format long;

[fid,chemin]=uigetfile('','MultiSelect', 'on');
% [fid,chemin]=uigetfile('');


if ~ischar(fid)
    nbfile=size(fid, 2);
else
    nbfile=1;
end
Volumemag = [];
% Volumereal=[];
 FA=[];
for n = 1:nbfile,
    if nbfile > 1,
        file=strcat(chemin, char(fid(n)));   
    else
        file=strcat(chemin, char(fid));
    end
    
        eval(['header' num2str(n) '=dicominfo(file)']);
        h = 1:nbfile;
            slopemag=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.Private_2005_100e']);
            slopereal=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_2.Private_2005_140f.Item_1.Private_2005_100e']);
            interceptreal=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_2.Private_2005_140f.Item_1.Private_2005_100d']);
%             eval(['TI' num2str(n) '=header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.InversionTime']);
FA(n)=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.FlipAngle']);
FA=FA';
TR=eval('header1.Private_2005_1030');
%             file=strcat(chemin, char(fid(n)));
            dicomfile=dicomread(file);
            dicomfile=squeeze(dicomfile);
            Magpart=double(dicomfile);
%             Realpart=double(dicomfile(:,:,:,2));
            Magpart=Magpart./slopemag;
%             Magpart=squeeze(Magpart); 
%             Realpart=(Realpart-interceptreal)./slopereal;
            Volumemag = cat(3, Volumemag, Magpart);
%             Volumereal=cat(4, Volumereal, Realpart);

end

     tailleVol=size(Volumemag);
NBcoupe = eval('header1.NumberOfFrames');
   Volumemag=double(Volumemag);
%   Volumereal=double(squeeze(Volumereal));
%      VolumeImag=double(Volume(:,:,3,:));
% tresh=mean(mean(Volumereal));
% treshSI=size(tresh);

% for k=1:treshSI(3),
%     if tresh(:,:,k) < 0;
%         Volumemag(:,:,k)=-Volumemag(:,:,k);
%     else
%         Volumemag(:,:,k)=Volumemag(:,:,k);
%     end
%    
% end
FA=[5 14];
FArad=FA.*pi./180; %normaliser en radian
t1map=[128,128];
M0map=[128,128];
tic
 for i = 1:tailleVol(1),
     for j = 1:tailleVol(2),
%      for   k = 1:NBcoupe,
        row=(squeeze(Volumemag(i,j,30:60:end)));
        row=row./1e+6;
        X=row./tan(FArad);
        Y=row./sin(FArad);
           
        % Initialize the coefficients of the function.
        X0=[4 1]';


        % Set an options file for LSQNONLIN to use the
        % medium-scale algorithm 
        options = optimset('MaxFunEvals', 5000);


        % Calculate the new coefficients using LSQNONLIN.
%         x=lsqnonlin(@EvalError,X0,[],[],options,X,Y);
        [p,ErrorEst] = polyfit(X,Y,1);
%         Sfitted = polyval(p,X,ErrorEst);
         t1map(i,j)=-(TR./1000)./log(p(1));
         M0map(i,j)=p(2).*1e+6;
        
%         if (i==58) && (j==58)
%             dbquit
%         end
    end
end
toc
% Plot the original and experimental data.
% Y_new = x(1).*(1-2.*exp(-X./x(2)));
% plot(X,Y,'+r',X,Y_new,'b')


subplot(1,2,1);imagesc(t1map,[0 1]);
subplot(1,2,2);imagesc(M0map);