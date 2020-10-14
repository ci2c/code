#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: FMRI_ICAOnVolume.sh -epi <fmri_file>  -o <path>  -ncomp <value>  -mask <file>  -tr <value>  -transf <file> "
	echo ""
	echo "  -epi                         : fmri file "
	echo "  -o                           : output path "
	echo "  -ncomp                       : number of components "
	echo "  -mask                        : fmri mask file "
	echo "  -tr                          : TR value "
	echo "  -transf                      : common space registration transform "
	echo ""
	echo "Usage: FMRI_ICAOnVolume.sh -epi <fmri_file>  -o <path>  -ncomp <value>  -mask <file>  -tr <value>  -transf <file> "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ICAOnVolume.sh -epi <fmri_file>  -o <path>  -ncomp <value>  -mask <file>  -tr <value>  -transf <file> "
		echo ""
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -ncomp                       : number of components "
		echo "  -mask                        : fmri mask file "
		echo "  -tr                          : TR value "
		echo "  -transf                      : common space registration transform "
		echo ""
		echo "Usage: FMRI_ICAOnVolume.sh -epi <fmri_file>  -o <path>  -ncomp <value>  -mask <file>  -tr <value>  -transf <file> "
		echo ""
		exit 1
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "fMRI file : $epi"
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
	-mask)
		index=$[$index+1]
		eval mask=\${$index}
		echo "mask file : ${mask}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-transf)
		index=$[$index+1]
		eval transf=\${$index}
		echo "transformation : ${transf}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ICAOnVolume.sh -epi <fmri_file>  -o <path>  -ncomp <value>  -mask <file>  -tr <value>  -transf <file> "
		echo ""
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -ncomp                       : number of components "
		echo "  -mask                        : fmri mask file "
		echo "  -tr                          : TR value "
		echo "  -transf                      : common space registration transform "
		echo ""
		echo "Usage: FMRI_ICAOnVolume.sh -epi <fmri_file>  -o <path>  -ncomp <value>  -mask <file>  -tr <value>  -transf <file> "
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

#=========================================================================================
#                              ICA Decomposition
#=========================================================================================


## ICA Decomposition
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

	ind  = find(sica.mask(:)>0);

	mapFiles = {};
	for j = 1:sica.nbcomp
		sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,0);

		map      = zeros(dim(1)*dim(2)*dim(3),1);
		map(ind) = sig_c;
		map      = reshape(map,dim(1),dim(2),dim(3));

		mapFiles{j} = fullfile('${output}',['ica_map_' num2str(j) '.nii']);
	 	hdr(1).fname = mapFiles{j};
		spm_write_vol(hdr(1),map);
	end

	mapFiles{end+1} = '${mask}';

	if strcmp(spm('ver'),'SPM8')

		% Template Normalization
		spm('Defaults','fMRI');
		spm_jobman('initcfg'); % SPM8 and SPM12
	
		matlabbatch = {};
		    
		matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${transf}');
	        matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = mapFiles;
	        matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
	        matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
	        matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
	        matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
	        matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
	        matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';

		spm_jobman('run',matlabbatch);

	else

		% Template Normalization
		spm('Defaults','fMRI');
		spm_jobman('initcfg'); % SPM8 and SPM12
	
		matlabbatch = {};

		matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${transf}');
		matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = mapFiles;
		matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;

		spm_jobman('run',matlabbatch);

	end

EOF



