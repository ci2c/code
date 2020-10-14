function splitMat(filename)
load(filename);
nb_rows=10;
row_start=0;
row_end=0;
resu=[];
for cpt=1:(dim_mat/nb_rows)
    cpt
    row_start=row_end+1;
    row_end=nb_rows*cpt;
    [i,j]=find(Mat_s(row_start:row_end,:)>0);
    Mat_tmp=Mat_s([[row_start:row_end]';unique(j)],[[row_start:row_end]';unique(j)]);    
    s(mod(cpt,101)).f1 = Mat_tmp;
    if mod(cpt,101)==0
        strcat('v',num2str(cpt),'.mat')
        %save(strcat('v',num2str(cpt),'.mat'),s,'-v7.3')       
    end
end