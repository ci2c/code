function Complete_glm_file(glm_file,cov)


%% init 
[A,B,C]=xlsread(cov);
[path,~,~]=fileparts(glm_file);

if isnan(A(1,1))
    niv=0;
else
    niv=-1
end

resFile = [path '/glm_cov.txt'];
if exist(resFile,'file')
    cmd = sprintf('rm -f %s',resFile);
    unix(cmd);
end

fid2 = fopen([path '/glm_cov.txt'],'w');
fid = fopen(glm_file, 'rt');

%%

count=0;
ncov=size(A,2)-1;

while feof(fid) == 0
    
    count = count+1;
    disp(count)
    
    tline = fgetl(fid);
    
    [~,file,~]=fileparts(tline);
    pt=find(file=='.');
    name=file(pt(1)+1:pt(2)-1)
    
    rg=find(strcmp(C,name));
    
    %sexe
    col=A(2-niv:end,1);
    col(isnan(col))=[];
    if all(col==0)
        sex=1;
    else
        sex=round(A(rg+niv,1));
    end
    clear col
    
    
    %Covariables
    
    for i = 1 : ncov
        if ischar(C{rg,2+i})
            cov_value(i)=str2num(C{rg,2+i});
        else
            cov_value(i)=C{rg,2+i};
        end
    end
    
    
    
    % resume
    txtcov=[];
    for i = 1 : ncov
        txtcov=[txtcov ' ' num2str(cov_value(i))];
    end
    
    fprintf(fid2,'%s\n',[tline(1) ' ' num2str(sex) ' ' tline(5:end) txtcov])

  
end
fclose(fid);
fclose(fid2);
