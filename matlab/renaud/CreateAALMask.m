function CreateAALMask(epiFile,output)

pathOI = fileparts(which('ned_hier_clustering.m'));
pathCh2 = [pathOI filesep '..' filesep 'aal'];

unix(['cp ', pathCh2 filesep 'struct.* ', output]);
unix(['cp ', pathCh2 filesep 'aal.* ', output]);

Vaal  = spm_vol(fullfile(output,'aal.img'));
Vepi  = spm_vol(epiFile);
Vanat = spm_vol(fullfile(output,'struct.img'));

PP = strvcat(Vepi.fname,Vanat.fname);
flag_reslice.interp = 1;
flag_reslice.wrap = [0 0 0];
flag_reslice.mask = 0;
flag_reslice.mean = 0;
flag_reslice.which = 1;
warning('off')
spm_reslice(PP,flag_reslice);

PP = strvcat(Vepi.fname,Vaal.fname);
flag_reslice.interp = 0;
flag_reslice.wrap = [0 0 0];
flag_reslice.mask = 0;
flag_reslice.mean = 0;
flag_reslice.which = 1;
warning('off')
spm_reslice(PP,flag_reslice);
