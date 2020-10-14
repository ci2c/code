fid=fopen('410710AD100810_T2_MAP_FFE_CL-2stacks_CLEAR_6_1.REC','r');
ima=fread(fid,'uint16');
ima2=reshape(ima,288,288,34,16);
header=textread('410710AD100810_T2_MAP_FFE_CL-2stacks_CLEAR_6_1.PAR','%s');

t2starmap=zeros(288,288,34);

X=[3.7 7.1 10.5 13.9 17.3 20.7 24.1 27.5 30.9 34.3 37.7 41.1 44.5 47.9 51.3 57.7]';
progressbar
for j = 25:25
    [maskx masky] = find(ima2(:,:,j,1) >= 100);
    nm = length(maskx);
   
    for i=1:nm
        progressbar(i/nm)
        Y=squeeze(ima2(maskx(i),masky(i),j,:));
        X0=[1000 10]';
        % Set an options file for LSQNONLIN to use the
        % medium-scale algorithm 
        options = optimset('MaxFunEvals', 1000);
        x=lsqnonlin(@t2star,X0,[],[],options,X,Y);
        t2starmap(maskx(i),masky(i),j)=x(2);
    end
end

%         t = linspace(min(X),max(X),100);
%         s_fit = x(1).*exp(-t/x(2));
%         figure(1)
%         hold on
%         plot(X,Y,'o')
%         plot(t,s_fit,'r')
%         figure(2)
%         hold on
%         plot(X,Y2,'o')