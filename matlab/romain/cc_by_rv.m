clear all;
cd /home/romain/Downloads/BCT/
2017_01_15_BCT/

Threshold= 0.8;
dim_mat=10000;

Mat=rand(dim_mat,dim_mat);
Mat(1:dim_mat+1:dim_mat*dim_mat)=0;
%Mat(:,1:dim_mat)=Mat(1:dim_mat,:);
Mat_d=triu(Mat)+triu(Mat)';
clear Mat;
Mat_s=Mat_d.*(Mat_d>Threshold);
clear Mat_d;
Mat_s = sparse(Mat_s);

tic
resu_gs=clustering_coef_wu_sign(Mat_s);
toc

%gold_std=clustering_coef_wu(Mat_s);

%gretna_node_clustcoeff_weight(Mat_s,'1')
%gretna_node_clustcoeff_weight(Mat_s,'2')
%gretna_node_clustcoeff_weight(Mat_tmp,'1')
%/home/romain/Downloads/SBEToolbox-1.3.3 clustercoeffs

tic
nb_rows=1;
row_start=0;
row_end=0;
resu=[];
% for cpt=1:(dim_mat/nb_rows)
%     cpt
%     row_start=row_end+1
%     row_end=nb_rows*cpt
%     [i,j]=find(Mat_s(row_start:row_end,:)>0);
%     Mat_tmp=Mat_s([[row_start:row_end]';unique(j)],[[row_start:row_end]';unique(j)]);    
%     s(mod(cpt,101)).f1 = Mat_tmp;
%     
%     if mod(cpt,101)==0
%         [flag] = arrayfun(@(x) clustering_coef_wu_sign(x.f1),s,'UniformOutput', false); 
%         for cpt=1:100
%             two_sec=cell2mat(flag(cpt));
%             resu=[resu;two_sec(1:10)];
%         end
%     end
%    
% end
cpt2=1;
for cpt=1:9%(dim_mat/nb_rows)
    cpt
    row_start=row_end+1;
    row_end=nb_rows*cpt;
    [i,j]=find(Mat_s(row_start:row_end,:)>0);
    Mat_tmp=Mat_s([[row_start:row_end]' unique(j)],[[row_start:row_end]' unique(j)]);    
    s(cpt2).f1 = Mat_tmp;
    if cpt2==10
        [flag] = arrayfun(@(x) clustering_coef_wu_sign(x.f1),s,'UniformOutput', false); 
        for cpt3=1:100
            two_sec=cell2mat(flag(cpt3));
            resu=[resu;two_sec(1:10)];
        end
        cpt2=1;
    else
        cpt2=cpt2+1;
    end
end
x2 = gpu2nndata(y,q)

%clustering_coef_wu_sign(Mat_tmp)
%system('ls')
%[y,q] = nndata2gpu(Mat_tmp)


toc

mean(resu)
mean(resu_gs)



%comment passer la matrice en argument utiliser python pour créer
%Mat_s Mat_tmp...