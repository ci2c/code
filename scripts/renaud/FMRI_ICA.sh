#! /bin/bash

if [ $# -lt 14 ]
then
	echo ""
	echo "Usage: FMRI_ICA.sh  -anat <anat_file>  -mask <mask_file>  -epi <fmri_file>  -mean <mean_file>  -o <folder>  -ncomp <value>  -TR <value>  -norm <value> "
	echo ""
	echo "  -anat                        : t1 file"
	echo "  -mask                        : mask file "
	echo "  -epi                         : fmri file "
	echo "  -mean                        : mean fmri file "
	echo "  -o                           : output folder "
	echo "  -ncomp                       : number of components "
	echo "  -TR                          : TR "
	echo "  -norm                        : Do normalization (Option) "
	echo ""
	echo "Usage: FMRI_ICA.sh  -anat <anat_file>  -mask <mask_file>  -epi <fmri_file>  -mean <mean_file>  -o <folder>  -ncomp <value>  -TR <value>  -norm <value> "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
ncomps=40
doNorm=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ICA.sh  -anat <anat_file>  -mask <mask_file>  -epi <fmri_file>  -mean <mean_file>  -o <folder>  -ncomp <value>  -TR <value>  -norm <value> "
		echo ""
		echo "  -anat                        : t1 file"
		echo "  -mask                        : mask file "
		echo "  -epi                         : fmri file "
		echo "  -mean                        : mean fmri file "
		echo "  -o                           : output folder "
		echo "  -ncomp                       : number of components "
		echo "  -TR                          : TR "
		echo "  -norm                        : Do normalization (Option) "
		echo ""
		echo "Usage: FMRI_ICA.sh  -anat <anat_file>  -mask <mask_file>  -epi <fmri_file>  -mean <mean_file>  -o <folder>  -ncomp <value>  -TR <value>  -norm <value> "
		echo ""
		exit 1
		;;
	-anat)
		index=$[$index+1]
		eval anat=\${$index}
		echo "anat : $anat"
		;;
	-mask)
		index=$[$index+1]
		eval mask=\${$index}
		echo "mask : $mask"
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "fMRI file : $epi"
		;;
	-mean)
		index=$[$index+1]
		eval mepi=\${$index}
		echo "mean fMRI file : $mepi"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : ${output}"
		;;
	-ncomp)
		index=$[$index+1]
		eval ncomps=\${$index}
		echo "number of components : ${ncomps}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR : ${TR}"
		;;
	-norm)
		index=$[$index+1]
		eval doNorm=\${$index}
		echo "Do normalization : ${doNorm}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ICA.sh  -anat <anat_file>  -mask <mask_file>  -epi <fmri_file>  -mean <mean_file>  -o <folder>  -ncomp <value>  -TR <value> "
		echo ""
		echo "  -anat                        : t1 file"
		echo "  -mask                        : mask file "
		echo "  -epi                         : fmri file "
		echo "  -mean                        : mean fmri file "
		echo "  -o                           : output folder "
		echo "  -ncomp                       : number of components "
		echo "  -TR                          : TR "
		echo "  -norm                        : Do normalization (Option) "
		echo ""
		echo "Usage: FMRI_ICA.sh  -anat <anat_file>  -mask <mask_file>  -epi <fmri_file>  -mean <mean_file>  -o <folder>  -ncomp <value>  -TR <value> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


if [ -d ${output} ]
then
	echo "rm -rf ${output}"
	rm -rf ${output}
fi

mkdir ${output}

N=$(mri_info ${epi} | grep dimensions | awk '{print $6}')

echo $TR
echo $N


#=========================================================================================
#                              ICA Decomposition
#=========================================================================================

matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

addpath(genpath('/home/global/matlab_toolbox/nbw_0.1'));

hdr  = spm_vol('${epi}');
vol  = spm_read_vols(hdr);
dim  = size(vol);
sica = FMRI_ICA(vol,'${mask}',${TR},${ncomps});

save(fullfile('${output}','sica.mat'),'sica');

mask = 1:size(sica.S,1);

hdrmap   = hdr(1);
ind      = find(sica.mask(:)>0);

mapFiles = {};
for j = 1:sica.nbcomp
	sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,0);

	map      = zeros(dim(1)*dim(2)*dim(3),1);
	map(ind) = sig_c;
	map      = reshape(map,dim(1),dim(2),dim(3));

	mapFiles{j} = fullfile('${output}',['ica_map_' num2str(j) '.nii']);
 	hdrmap.fname = mapFiles{j};
	spm_write_vol(hdrmap,map);
end

mapFiles{end+1} = '${mask}';

if ${doNorm} == 1

	% Template Normalization
	spm('Defaults','fMRI');
	spm_jobman('initcfg'); % SPM8 only

	clear jobs
	jobs = {};

	a = which('spm_normalise');
	[path] = fileparts(a);
	    
	jobs{1}.spm.spatial.normalise.estwrite.subj.source       = {mepiFile};
	jobs{1}.spm.spatial.normalise.estwrite.subj.wtsrc        = '';
	jobs{1}.spm.spatial.normalise.estwrite.subj.resample     = mapFiles;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.template = {fullfile(path,'templates/EPI.nii')};
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.weight   = '';
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.smosrc   = 8;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.smoref   = 0;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.regtype  = 'mni';
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.cutoff   = 25;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.nits     = 16;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.reg      = 1;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.bb       = [-78 -112 -50
			                                         78 76 85];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.vox      = [3 3 3];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.interp   = 3;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.wrap     = [0 0 0];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.prefix   = 'w';

	spm_jobman('run',jobs);
	
end

EOF


