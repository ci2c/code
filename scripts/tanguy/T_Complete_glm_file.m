function T_Complete_glm_file(glm_file,cov)

[A,B,C]=xlsread(cov);
[path,~,~]=fileparts(glm_file);

if isnan(A(1,2))
    niv=0;
else
    niv=-1;
end

resFile = [path '/glm_cov.txt'];
if exist(resFile,'file')
    cmd = sprintf('rm -f %s',resFile);
    unix(cmd);
end

[path '/glm_cov.txt','w']
fid2 = fopen([path '/glm_cov.txt'],'w');
fid = fopen(glm_file, 'rt');

count=0;

while feof(fid) == 0
    
    count = count+1;
    disp(count)
    
    tline = fgetl(fid);
    
    [~,file,~]=fileparts(tline);
    pt=find(file=='.');
    name=file(pt(1)+1:pt(2)-1)
    
    rg=find(strcmp(C,name));
    sex=round(C{rg,2});
    age=round(C{rg,3});
    ICV=round(C{rg,4});
    if length(ICV)>1
        ICV = round(str2num(C{rg,4}));
    end
    
%     rg=find(strcmp(B,name));
%     
%     sex=round(A(rg+niv,2));
%     
%     age=round(A(rg+niv,3));
%     
%     if isnan(A(rg,4))
%         ICV=str2num(B{rg,4});
%     else
%         ICV=A(rg+niv,4);
%     end
    
    if isnan(ICV)+isnan(sex)+isnan(age)
        warning(['problème avec l ecriture du sujet' name])
    end
    
    
    [tline(1) ' ' num2str(sex) ' ' num2str(ICV) ' ' tline(5:end) ' ' num2str(age)]
    fprintf(fid2,'%s\n',[tline(1) ' ' num2str(sex) ' ' num2str(ICV) ' ' tline(5:end) ' ' num2str(age)]);
    
end
fclose(fid);
fclose(fid2);
