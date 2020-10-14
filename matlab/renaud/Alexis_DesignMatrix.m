function [sot,rem_beg,last_dyn] = Alexis_DesignMatrix(matfile,xlsfile,TR,nbdyn)

load(matfile,'x_mots','x_nonmots','x_dam','tir_cat');

% 1=mots; 2=non mots; 3=damier
xls = ReadXlsFile(xlsfile);

% nombre de scans à supprimer au début et fin:
rem_beg  = 0;

last_dyn = 0;

% run 1:
for run = 1:2
    
    cp_words   = 0;
    cp_nowords = 0;
    cp_damier  = 0;
    cp         = 0;
    if(run==1)
        info   = xls.run1.cel;
    else
        info   = xls.run2.cel;
    end
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
    time_damier_left    = [];
    time_damier_right   = [];
    resp_damier_left    = [];
    resp_damier_right   = [];

    for k = beg_line:2:end_line

        cp    = cp+1;
        timg  = info(k,3);
        timg  = timg{1}-rem_beg*(TR*1000);
        resp  = info(k+1,5);
        resp  = resp{1};
        tresp = info(k+1,6);
        tresp = tresp{1};
        
        timg  = timg/1000;
        %timg  = timg/TR;
        if(timg>last_dyn)
            last_dyn=timg;
        end
        
        if(tir_cat(run,cp)==1)
            cp_words = cp_words+1;
            if(resp==tir_cat(run,cp))
                if(x_mots(run,cp_words) <= 40)
                    true_words_left  = [true_words_left timg];
                    time_true_w_left = [time_true_w_left tresp];
                else
                    true_words_right  = [true_words_right timg];
                    time_true_w_right = [time_true_w_right tresp];
                end
            else
                if(x_mots(run,cp_words) <= 40)
                    false_words_left  = [false_words_left timg];
                    time_false_w_left = [time_false_w_left tresp];
                else
                    false_words_right  = [false_words_right timg];
                    time_false_w_right = [time_false_w_right tresp];
                end
            end
        end
        if(tir_cat(run,cp)==2)
            cp_nowords = cp_nowords+1;
            if(resp==tir_cat(run,cp))
                if(x_nonmots(run,cp_nowords) <= 40)
                    true_nowords_left = [true_nowords_left timg];
                    time_true_nw_left = [time_true_nw_left tresp];
                else
                    true_nowords_right = [true_nowords_right timg];
                    time_true_nw_right = [time_true_nw_right tresp];
                end 
            else
                if(x_nonmots(run,cp_nowords) <= 40) 
                    false_nowords_left = [false_nowords_left timg];
                    time_false_nw_left = [time_false_nw_left tresp];
                else
                    false_nowords_right = [false_nowords_right timg];
                    time_false_nw_right = [time_false_nw_right tresp];
                end
            end
        end 
        if(tir_cat(run,cp)==3)
            cp_damier = cp_damier+1;
            if(x_dam(run,cp_damier)==1)
                damier_left      = [damier_left timg];
                time_damier_left = [time_damier_left tresp];
                resp_damier_left = [resp_damier_left resp];
            else
                damier_right = [damier_right timg];
                time_damier_right = [time_damier_right tresp];
                resp_damier_right = [resp_damier_right resp];
            end
        end

    end

    sot{run,1}.name  = 'TWL';
    sot{run,1}.vect  = true_words_left;
    sot{run,2}.name  = 'TWR';
    sot{run,2}.vect  = true_words_right;
    sot{run,3}.name  = 'FWL';
    sot{run,3}.vect  = false_words_left;
    sot{run,4}.name  = 'FWR';
    sot{run,4}.vect  = false_words_right;
    sot{run,5}.name  = 'TNWL';
    sot{run,5}.vect  = true_nowords_left;
    sot{run,6}.name  = 'TNWR';
    sot{run,6}.vect  = true_nowords_right;
    sot{run,7}.name  = 'FNWL';
    sot{run,7}.vect  = false_nowords_left;
    sot{run,8}.name  = 'FNWR';
    sot{run,8}.vect  = false_nowords_right;
    sot{run,9}.name  = 'DL';
    sot{run,9}.vect  = damier_left;
    sot{run,10}.name = 'DR';
    sot{run,10}.vect = damier_right;
    sot{run,11}.name = 'time_true_w_left';
    sot{run,11}.vect = time_true_w_left;
    sot{run,12}.name = 'time_true_w_right';
    sot{run,12}.vect = time_true_w_right;
    sot{run,13}.name = 'time_false_w_left';
    sot{run,13}.vect = time_false_w_left;
    sot{run,14}.name = 'time_false_w_right';
    sot{run,14}.vect = time_false_w_right;
    sot{run,15}.name = 'time_true_nw_left';
    sot{run,15}.vect = time_true_nw_left;
    sot{run,16}.name = 'time_true_nw_right';
    sot{run,16}.vect = time_true_nw_right;
    sot{run,17}.name = 'time_false_nw_left';
    sot{run,17}.vect = time_false_nw_left;
    sot{run,18}.name = 'time_false_nw_right';
    sot{run,18}.vect = time_false_nw_right;
    sot{run,19}.name = 'time_damier_left';
    sot{run,19}.vect = time_damier_left;
    sot{run,20}.name = 'time_damier_right';
    sot{run,20}.vect = time_damier_right;
    sot{run,21}.name = 'resp_damier_left';
    sot{run,21}.vect = resp_damier_left;
    sot{run,22}.name = 'resp_damier_right';
    sot{run,22}.vect = resp_damier_right;
    
end

last_dyn  = last_dyn/TR;
leave_dyn = nbdyn-ceil(last_dyn);
if(leave_dyn > 4)
    last_dyn = ceil(last_dyn+4);
else
    last_dyn = nbdyn;
end
last_dyn