
dire='/NAS/tupac/protocoles/Strokdem/PLS-PLR'
dire2='/NAS/tupac/protocoles/Strokdem/test/test_reg'
dire3='/NAS/tupac/protocoles/Strokdem/T1_strokdem'
dire4='/NAS/tupac/protocoles/Strokdem/FS5.1'
subjid='231029JC'

for f in $dire/*
do
	subjid=`basename $f`
	echo $subjid

### Variables
W=$dire2/test_sssmooth_fat_3d_learning25.nii  #Images to place in the FS5.1 ref
source=$dire/$subjid/M6/w_$subjid\_M6.nii #Lesions image in the middle ref
rW2=$dire2/r`basename $W` #Reslice image
mat=$dire3/$subjid\_M6/$subjid\_M6_sn.mat #Transfo
orig=$dire3/$subjid\_M6/$subjid\_M6.nii #Lesions image in the orig ref

rW=$dire/$subjid/M6/`basename $rW2` #Reslice image in the good directory
wrW=$dire/$subjid/M6/w`basename $rW` #Warped image in the original ref
conf=$dire4/$subjid\_M6/mri/orig.mgz
conf2=$dire/$subjid/M6/orig.nii
cwrW=$dire/$subjid/M6/c`basename $wrW` #Warped image in the FS5.1 ref



##### First step : Reslice the weights of the regression
if [ ! -e $rW ]
then
  echo First step
  ## Create the script file
  echo "% List of open inputs" > tmp_reslice.m
  echo "nrun = 1; % enter the number of runs here" >> tmp_reslice.m
  echo "jobfile = {'tmp_reslice_job.m'};" >> tmp_reslice.m
  echo "jobs = repmat(jobfile, 1, nrun);" >> tmp_reslice.m
  echo "inputs = cell(0, nrun);" >> tmp_reslice.m
  echo "for crun = 1:nrun" >> tmp_reslice.m
  echo "end" >> tmp_reslice.m
  echo "spm('defaults', 'FMRI');" >> tmp_reslice.m
  echo "spm_jobman('serial', jobs, '', inputs{:});" >> tmp_reslice.m

  ## Create the job file
  echo "%-----------------------------------------------------------------------" > tmp_reslice_job.m
  echo "% Job configuration created by cfg_util (rev $Rev: 4252 $)" >> tmp_reslice_job.m
  echo "%-----------------------------------------------------------------------" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.ref = {'$source,1'};" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.source = {'$W,1'};" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';" >> tmp_reslice_job.m

  `matlab <tmp_reslice.m> error1.log -nosplash`
  rm -f tmp_reslice_job.m tmp_reslice.m

  mv $rW2 $dire/$subjid/M6/
fi

##### Second step : Inverse transformation
if [ ! -e $wrW ]
then
  echo Second step

  ## Create the matlab file tmp_inv_transfo
  echo "% List of open inputs" >tmp_inv_transfo.m
  echo "nrun = 1; % enter the number of runs here" >>tmp_inv_transfo.m
  echo "jobfile = {'/NAS/tupac/protocoles/Strokdem/test/test_reg/script/tmp_inv_transfo_job.m'};" >>tmp_inv_transfo.m
  echo "jobs = repmat(jobfile, 1, nrun);" >>tmp_inv_transfo.m
  echo "inputs = cell(0, nrun);" >>tmp_inv_transfo.m
  echo "for crun = 1:nrun" >>tmp_inv_transfo.m
  echo "end" >>tmp_inv_transfo.m
  echo "spm('defaults', 'FMRI');" >>tmp_inv_transfo.m
  echo "spm_jobman('serial', jobs, '', inputs{:});" >>tmp_inv_transfo.m


  ##Create the 
  echo "%-----------------------------------------------------------------------" > tmp_inv_transfo_job.m
  echo "% Job configuration created by cfg_util (rev $Rev: 4252 $)" >> tmp_inv_transfo_job.m
  echo "%-----------------------------------------------------------------------" >> tmp_inv_transfo_job.m
  echo "matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = {'"$mat"'};" >> tmp_inv_transfo_job.m
  echo "matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox = [NaN NaN NaN];" >> tmp_inv_transfo_job.m
  echo "matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb = [NaN NaN NaN
							      NaN NaN NaN];" >> tmp_inv_transfo_job.m
  echo "matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {'"$orig",1'};" >> tmp_inv_transfo_job.m
  echo "matlabbatch{1}.spm.util.defs.ofname = '';" >> tmp_inv_transfo_job.m
  echo "matlabbatch{1}.spm.util.defs.fnames = {'"$rW",1'};" >> tmp_inv_transfo_job.m
  echo "matlabbatch{1}.spm.util.defs.savedir.savesrc = 1;" >> tmp_inv_transfo_job.m
  echo "matlabbatch{1}.spm.util.defs.interp = 0;" >> tmp_inv_transfo_job.m

  `matlab <tmp_inv_transfo.m> error2.log -nosplash`
  
  rm tmp_inv_transfo.m tmp_inv_transfo_job.m
fi

#### Third step : Reslice
if [ ! -e $cwrW ]
then
  echo Third step
  mri_convert $conf $conf2 >error3.log

  # Create the script file
  echo "% List of open inputs" > tmp_reslice.m
  echo "nrun = 1; % enter the number of runs here" >> tmp_reslice.m
  echo "jobfile = {'tmp_reslice_job.m'};" >> tmp_reslice.m
  echo "jobs = repmat(jobfile, 1, nrun);" >> tmp_reslice.m
  echo "inputs = cell(0, nrun);" >> tmp_reslice.m
  echo "for crun = 1:nrun" >> tmp_reslice.m
  echo "end" >> tmp_reslice.m
  echo "spm('defaults', 'FMRI');" >> tmp_reslice.m
  echo "spm_jobman('serial', jobs, '', inputs{:});" >> tmp_reslice.m

  # Create the job file
  echo "%-----------------------------------------------------------------------" > tmp_reslice_job.m
  echo "% Job configuration created by cfg_util (rev $Rev: 4252 $)" >> tmp_reslice_job.m
  echo "%-----------------------------------------------------------------------" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.ref = {'$conf2,1'};" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.source = {'$wrW,1'};" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;" >> tmp_reslice_job.m
  echo "matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'c';" >> tmp_reslice_job.m

  `matlab <tmp_reslice.m> error4.log -nosplash`
  rm -f tmp_reslice_job.m tmp_reslice.m $conf2

fi

done

##### Four step : Compute the mask
echo Fourth step
