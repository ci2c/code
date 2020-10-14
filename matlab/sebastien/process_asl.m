function process_asl(path)

if ~isdir([path,'/asl/RawEPI'])
    mkdir([path,'/asl/RawEPI']);
end

cmdline1=['dcm2nii -o',' ',path,'/asl',' ',path,'/asl/*rec'];
cmdline2=['fslmerge -t',' ',path,'/asl/raw_asl',' ',path,'/asl/*gz'];
cmdline3=['fslsplit',' ',path,'/asl/raw_asl',' ',path,'/asl/RawEPI/epi_',' ','-t'];
cmdline4=['gunzip -f',' ', path,'/asl/RawEPI/*gz'];
cmdline5=['mri_convert',' ',path,'/mri/T1.mgz',' ',path,'/mri/T1.nii'];

disp(cmdline2);
result1=system(cmdline1);
result2=system(cmdline2);
result3=system(cmdline3);
result4=system(cmdline4);
result5=system(cmdline5);

if ~isdir([path,'/asl/Structural'])
    mkdir([path,'/asl/Structural']);
end

cmd=sprintf('cp -f %s %s',[path,'/mri/T1.nii'],[path,'/asl/Structural/brain.nii']);
unix(cmd);

ASL_PreprocessSPM8([path '/asl'])

cmdline6=['fslmerge -t',' ',path,'/asl/label',' ',path,'/asl/RawEPI/repi_00{30..59}*'];
cmdline7=['fslmerge -t',' ',path,'/asl/control',' ',path,'/asl/RawEPI/repi_00{00..29}*'];
cmdline9=['fslmaths',' ',path,'/asl/label',' ','-Tmean',' ',path,'/asl/label_mean'];
cmdline10=['fslmaths',' ',path,'/asl/control',' ','-Tmean',' ',path,'/asl/control_mean'];
cmdline11=['fslmaths',' ',path,'/asl/label_mean',' ','-sub',' ',path,'/asl/control_mean',' ',path,'/asl/asl_map'];
cmdline12=['gunzip -f',' ', path,'/asl/*gz'];

disp('fslmerge');
result6=system(cmdline6);
result7=system(cmdline7);
disp('fslmaths');
result9=system(cmdline9);
result10=system(cmdline10);
result11=system(cmdline11);
disp('gunzip');
result12=system(cmdline12);

disp('calcul carto CBF');
aslmap_new([path,'/asl/control_mean.nii'],[path,'/asl/asl_map.nii'],[path,'/asl/CBF.nii']);

disp('reslice CBF.nii');
reslice_asl(path);

disp('correction volume partiel');

t1_path=[path,'/mri/T1.nii'];
asl_path=[path,'/asl/rCBF.nii'];
outdir=[path,'/asl/pve_out'];

run_pve_sebastien(t1_path,asl_path,outdir);

file_to_copy = [path,'/asl/pve_out/rpet.hdr'];
file_out = [path,'/asl/pve_out/t1_MGRousset.hdr'];
copyfile(file_to_copy,file_out,'f');

