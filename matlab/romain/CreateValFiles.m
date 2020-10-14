IOpath='/NAS/tupac/protocoles/BBS_GK/travail/SN/job/';
encodingFile = read_xls_file('VLSM2.xlsx',IOpath);
fid = fopen(strcat(IOpath,'/VLSM_NPM2.val'), 'w');
fprintf(fid,'#Version:0\n');
fprintf(fid,'#Covary Volume	0\n');
fprintf(fid,'#Template	C:\\template.img\n');
fprintf(fid,'#CritPct	6\n');
fprintf(fid,'ImageName\t');
fprintf(fid,'%s\t',encodingFile.Feuil1.cel{1,2});
fprintf(fid,'%s\n',encodingFile.Feuil1.cel{1,3});

for i=2:size(encodingFile.Feuil1.cel)
    strTmp=encodingFile.Feuil1.cel{i,1};
    str4find=['ls *' strTmp(1,5:size(strTmp,2)) '*.nii'];
    [status,cmdout]=unix(str4find);
    if status == 0
        fprintf(fid,'%s\t',cmdout(1,1:size(cmdout,2)-1));
        fprintf(fid,'%g\t',encodingFile.Feuil1.cel{i,2});
        fprintf(fid,'%g\n',encodingFile.Feuil1.cel{i,3});               
    else
        strTmp
    end
end

fclose(fid)
