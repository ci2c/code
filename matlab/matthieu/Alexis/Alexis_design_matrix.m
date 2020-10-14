function Alexis_design_matrix(outdir,subj,matFile,xlsFile)

dataroot = '/home/fatmike/renaud/alexis/data_ju';

filepath = fullfile(dataroot,[subj '/'])

load([filepath matFile],'x_mots','x_nonmots','x_dam','tir_cat');

% 1=mots; 2=non mots; 3=damier
xls = read_xls_file(xlsFile,filepath);

% run 1:
run        = 1;
cp_words   = 0;
cp_nowords = 0;
cp_damier  = 0;
cp         = 0;
info       = xls.run1.cel;
beg_line   = 4;
end_line   = size(info,1);
nb_stim    = (end_line-beg_line+1)/2;
words_right    = [];
words_left     = [];
nowords_right  = [];
nowords_left   = [];
damier         = [];

for k = beg_line:2:end_line
    cp    = cp+1;
    timg  = info(k,3);
    timg  = timg{1};
    if(tir_cat(run,cp)==1)
        cp_words = cp_words+1;
            if(x_mots(run,cp_words) <= 40)
                words_left  = [words_left timg/1000];
            else
                words_right  = [words_right timg/1000];
            end
    end
    if(tir_cat(run,cp)==2)
        cp_nowords = cp_nowords+1;
        if(x_nonmots(run,cp_nowords) <= 40)
            nowords_left = [nowords_left timg/1000]; 
        else
            nowords_right = [nowords_right timg/1000];
        end 
    end 
    if(tir_cat(run,cp)==3)
        cp_damier = cp_damier+1;
        damier = [damier timg/1000];
    end
end
sot{run,1}  = words_left;
sot{run,2}  = words_right;
sot{run,3}  = nowords_left;
sot{run,4}  = nowords_right;
sot{run,5}  = damier;

% run 2:
run        = 2;
cp_words   = 0;
cp_nowords = 0;
cp_damier  = 0;
cp         = 0;
info       = xls.run2.cel;
beg_line   = 4;
end_line   = size(info,1);
nb_stim    = (end_line-beg_line+1)/2;
words_right    = [];
words_left     = [];
nowords_right  = [];
nowords_left   = [];
damier         = [];

for k = beg_line:2:end_line
    cp    = cp+1;
    timg  = info(k,3);
    timg  = timg{1};
    if(tir_cat(run,cp)==1)
        cp_words = cp_words+1;
            if(x_mots(run,cp_words) <= 40)
                words_left  = [words_left timg/1000];
            else
                words_right  = [words_right timg/1000];
            end
    end
    if(tir_cat(run,cp)==2)
        cp_nowords = cp_nowords+1;
        if(x_nonmots(run,cp_nowords) <= 40)
            nowords_left = [nowords_left timg/1000]; 
        else
            nowords_right = [nowords_right timg/1000];
        end 
    end 
    if(tir_cat(run,cp)==3)
        cp_damier = cp_damier+1;
        damier = [damier timg/1000];
    end
end
sot{run,1}  = words_left;
sot{run,2}  = words_right;
sot{run,3}  = nowords_left;
sot{run,4}  = nowords_right;
sot{run,5}  = damier;

% last_dyn = max([max(sot{1,1}) max(sot{1,2}) max(sot{1,3}) max(sot{1,4}) max(sot{2,1}) max(sot{2,2}) max(sot{2,3}) max(sot{2,4})])
% 
% leave_dyn = nbdyn-ceil(last_dyn);
% if(leave_dyn > 4)
%     last_dyn = ceil(last_dyn+4);
% else
%     last_dyn = nbdyn;
% end
% last_dyn

save(fullfile(outdir,subj,['sots_' subj '.mat']),'sot');  
