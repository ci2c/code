function sot = build_design_matrix(subj,matFile,xlsFile,rem_beg)

% rembeg = nombre de scans à supprimer au début
dataroot = '/home/fatmike/renaud/alexis/data_ju';
fsdir    = '/home/fatmike/renaud/alexis/FS50_ju';

filepath = fullfile(dataroot,[subj '/']);

TR       = 2400;
nbdyn    = 190;

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
true_words          = [];
false_words         = [];
true_nowords        = [];
false_nowords       = [];
true_words_right    = [];
true_words_left     = [];
true_nowords_right  = [];
true_nowords_left   = [];
false_words_right   = [];
false_words_left    = [];
false_nowords_right = [];
false_nowords_left  = [];
damier_left         = [];
damier_right        = [];
time_true_w_left    = [];
time_true_w_right   = [];
time_false_w_left   = [];
time_false_w_right  = [];
time_true_nw_left   = [];
time_true_nw_right  = [];
time_false_nw_left  = [];
time_false_nw_right = [];

for k = beg_line:2:end_line
    
    cp    = cp+1;
    timg  = info(k,3);
    timg  = timg{1}-rem_beg*TR;
    resp  = info(k+1,5);
    resp  = resp{1};
    tresp = info(k+1,6);
    tresp = tresp{1};
    if(tir_cat(run,cp)==1)
        cp_words = cp_words+1;
        if(resp==tir_cat(run,cp))
            if(x_mots(run,cp_words) <= 40)
                true_words_left  = [true_words_left timg/1000];
                time_true_w_left = [time_true_w_left tresp];
            else
                true_words_right  = [true_words_right timg/1000];
                time_true_w_right = [time_true_w_right tresp];
            end
            true_words  = [true_words timg/1000];  
        else
            if(x_mots(run,cp_words) <= 40)
                false_words_left  = [false_words_left timg/1000];
                time_false_w_left = [time_false_w_left tresp];
            else
                false_words_right  = [false_words_right timg/1000];
                time_false_w_right = [time_false_w_right tresp];
            end
            false_words = [false_words timg/1000];
        end
    end
    if(tir_cat(run,cp)==2)
        cp_nowords = cp_nowords+1;
        if(resp==tir_cat(run,cp))
            if(x_nonmots(run,cp_nowords) <= 40)
                true_nowords_left = [true_nowords_left timg/1000]; 
                time_true_nw_left = [time_true_nw_left tresp];
            else
                true_nowords_right = [true_nowords_right timg/1000];
                time_true_nw_right = [time_true_nw_right tresp];
            end
            true_nowords  = [true_nowords timg/1000];  
        else
            if(x_nonmots(run,cp_nowords) <= 40)
                false_nowords_left = [false_nowords_left timg/1000]; 
                time_false_nw_left = [time_false_nw_left tresp];
            else
                false_nowords_right = [false_nowords_right timg/1000];
                time_false_nw_right = [time_false_nw_right tresp];
            end
            false_nowords = [false_nowords timg/1000];
        end
    end 
    if(tir_cat(run,cp)==3)
        cp_damier = cp_damier+1;
        if(x_dam(run,cp_damier)==1)
            damier_left = [damier_left timg/1000];
        else
            damier_right = [damier_right timg/1000];
        end
    end
    
end
sot{run,1}  = true_words;
sot{run,2}  = false_words;
sot{run,3}  = true_nowords;
sot{run,4}  = false_nowords;
sot{run,5}  = true_words_left;
sot{run,6}  = true_words_right;
sot{run,7}  = false_words_left;
sot{run,8}  = false_words_right;
sot{run,9}  = true_nowords_left;
sot{run,10} = true_nowords_right;
sot{run,11} = false_nowords_left;
sot{run,12} = false_nowords_right;
sot{run,13} = [true_words_left true_nowords_left];
sot{run,14} = [true_words_right true_nowords_right];
sot{run,15} = damier_left;
sot{run,16} = damier_right;
sot{run,17} = time_true_w_left;
sot{run,18} = time_true_w_right;
sot{run,19} = time_false_w_left;
sot{run,20} = time_false_w_right;
sot{run,21} = time_true_nw_left;
sot{run,22} = time_true_nw_right;
sot{run,23} = time_false_nw_left;
sot{run,24} = time_false_nw_right;

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
true_words          = [];
false_words         = [];
true_nowords        = [];
false_nowords       = [];
true_words_right    = [];
true_words_left     = [];
true_nowords_right  = [];
true_nowords_left   = [];
false_words_right   = [];
false_words_left    = [];
false_nowords_right = [];
false_nowords_left  = [];
damier_left         = [];
damier_right        = [];
time_true_w_left    = [];
time_true_w_right   = [];
time_false_w_left   = [];
time_false_w_right  = [];
time_true_nw_left   = [];
time_true_nw_right  = [];
time_false_nw_left  = [];
time_false_nw_right = [];

for k = beg_line:2:end_line
    
    cp    = cp+1;
    timg  = info(k,3);
    timg  = timg{1}-rem_beg*TR;
    resp  = info(k+1,5);
    resp  = resp{1};
    tresp = info(k+1,6);
    tresp = tresp{1};
    if(tir_cat(run,cp)==1)
        cp_words = cp_words+1;
        if(resp==tir_cat(run,cp))
            if(x_mots(run,cp_words) <= 40)
                true_words_left  = [true_words_left timg/1000];
                time_true_w_left = [time_true_w_left tresp];
            else
                true_words_right  = [true_words_right timg/1000];
                time_true_w_right = [time_true_w_right tresp];
            end
            true_words  = [true_words timg/1000];  
        else
            if(x_mots(run,cp_words) <= 40)
                false_words_left  = [false_words_left timg/1000];
                time_false_w_left = [time_false_w_left tresp];
            else
                false_words_right  = [false_words_right timg/1000];
                time_false_w_right = [time_false_w_right tresp];
            end
            false_words = [false_words timg/1000];
        end
    end
    if(tir_cat(run,cp)==2)
        cp_nowords = cp_nowords+1;
        if(resp==tir_cat(run,cp))
            if(x_nonmots(run,cp_nowords) <= 40)
                true_nowords_left = [true_nowords_left timg/1000]; 
                time_true_nw_left = [time_true_nw_left tresp];
            else
                true_nowords_right = [true_nowords_right timg/1000];
                time_true_nw_right = [time_true_nw_right tresp];
            end
            true_nowords  = [true_nowords timg/1000];  
        else
            if(x_nonmots(run,cp_nowords) <= 40)
                false_nowords_left = [false_nowords_left timg/1000]; 
                time_false_nw_left = [time_false_nw_left tresp];
            else
                false_nowords_right = [false_nowords_right timg/1000];
                time_false_nw_right = [time_false_nw_right tresp];
            end
            false_nowords = [false_nowords timg/1000];
        end
    end 
    if(tir_cat(run,cp)==3)
        cp_damier = cp_damier+1;
        if(x_dam(run,cp_damier)==1)
            damier_left = [damier_left timg/1000];
        else
            damier_right = [damier_right timg/1000];
        end
    end
    
end
sot{run,1}  = true_words;
sot{run,2}  = false_words;
sot{run,3}  = true_nowords;
sot{run,4}  = false_nowords;
sot{run,5}  = true_words_left;
sot{run,6}  = true_words_right;
sot{run,7}  = false_words_left;
sot{run,8}  = false_words_right;
sot{run,9}  = true_nowords_left;
sot{run,10} = true_nowords_right;
sot{run,11} = false_nowords_left;
sot{run,12} = false_nowords_right;
sot{run,13} = [true_words_left true_nowords_left];
sot{run,14} = [true_words_right true_nowords_right];
sot{run,15} = [damier_left];
sot{run,16} = [damier_right];
sot{run,17} = time_true_w_left;
sot{run,18} = time_true_w_right;
sot{run,19} = time_false_w_left;
sot{run,20} = time_false_w_right;
sot{run,21} = time_true_nw_left;
sot{run,22} = time_true_nw_right;
sot{run,23} = time_false_nw_left;
sot{run,24} = time_false_nw_right;

last_dyn = max([max(sot{1,1}) max(sot{1,2}) max(sot{1,3}) max(sot{1,4}) max(sot{2,1}) max(sot{2,2}) max(sot{2,3}) max(sot{2,4})])

leave_dyn = nbdyn-ceil(last_dyn);
if(leave_dyn > 4)
    last_dyn = ceil(last_dyn+4);
else
    last_dyn = nbdyn;
end
last_dyn

save(fullfile(fsdir,subj,'fmri',['sots_' subj '.mat']),'sot','rem_beg','last_dyn');  
