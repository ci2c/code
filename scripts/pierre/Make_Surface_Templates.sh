#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Make_Surface_Templates.sh  -fs <FS_dir>  -fwhm <FWHM>  -subj <subj1> <subj2> ... <subjN>"
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj <subj_ID>                    : Subjects ID"
	echo "  -fwhm <FWHM>                       : Set FWHM of surface kernel blur"
	echo ""
	echo "Usage: Make_Surface_Templates.sh  -fs <FS_dir>  -fwhm <FWHM>  -subj <subj1> <subj2> ... <subjN>"
	echo ""
	exit 1
fi


index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Make_Surface_Templates.sh  -fs <FS_dir>  -fwhm <FWHM>  -subj <subj1> <subj2> ... <subjN>"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj <subj_ID>                    : Subjects ID"
		echo "  -fwhm <FWHM>                       : Set FWHM of surface kernel blur"
		echo ""
		echo "Usage: Make_Surface_Templates.sh  -fs <FS_dir>  -fwhm <FWHM>  -subj <subj1> <subj2> ... <subjN>"
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "FS_dir : $fs"
		;;
	-fwhm)
		fwhm=`expr $index + 1`
		eval fwhm=\${$fwhm}
		echo "FWHM : $fwhm"
		;;
	-subj)
		i=$[$index+1]
		eval infile=\${$i}
		subj=""
		while [ "$infile" != "-fs" -a "$infile" != "-fwhm" -a $i -le $# ]
		do
		 	subj="${subj} ${infile}"
		 	i=$[$i+1]
		 	eval infile=\${$i}
		done
		index=$[$i-1]
		echo "subj : $subj"
		;;
	esac
	index=$[$index+1]
done

SUBJECTS_DIR=${fs}

# Create template directory if needed
if [ ! -d ${fs}/template ]
then
	mkdir ${fs}/template
fi

TDIR="${fs}/template/"
# Loop the stuffs
for Subject in ${subj}
do	
	if [ -d ${fs}/${Subject}/epilepsy/ ]
	then
		EDIR="${fs}/${Subject}/epilepsy/"
		for FEAT in `ls ${EDIR} | grep fwhm${fwhm}.fsaverage`
		do
			echo ${Subject}_${FEAT}
			cp -f ${EDIR}/${FEAT} ${TDIR}/${Subject}_${FEAT}
		done

		for FEAT in `ls ${EDIR} | grep h.fsaverage`
		do
			echo ${Subject}_${FEAT}
			cp -f ${EDIR}/${FEAT} ${TDIR}/${Subject}_${FEAT}
		done
	else
		echo "******************************************************************"
		echo "NO EPILEPSY DATA IN ${fs}/${Subject}"
		echo "******************************************************************"
		exit 1
	fi
done


# Launch matlab
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${TDIR}

for Feature = {'curv', 'depth', 'dxyz', 'intensity', 'thickness', 'complexity'}
	% Load template if exists
	if exist(char(strcat('${TDIR}', '/lh.fsaverage.mean.', Feature)))~=0
		[templatelh, fnum] = read_curv(char(strcat('${TDIR}', '/lh.fsaverage.mean.', Feature)));
		[templaterh, fnum] = read_curv(char(strcat('${TDIR}', '/rh.fsaverage.mean.', Feature)));
	else
		templatelh = [];
		templaterh = [];
	end
	
	if exist(char(strcat('${TDIR}', '/lh.fwhm${fwhm}.fsaverage.mean.', Feature)))~=0
		[templatelhfwhm, fnum] = read_curv(char(strcat('${TDIR}', '/lh.fwhm${fwhm}.fsaverage.mean.', Feature)));
		[templaterhfwhm, fnum] = read_curv(char(strcat('${TDIR}', '/rh.fwhm${fwhm}.fsaverage.mean.', Feature)));
	else
		templatelhfwhm = [];
		templaterhfwhm = [];
	end
	
	% Load Feature
	list_lhFeature = SurfStatListDir(char(strcat('*lh.fsaverage.', Feature, '.mgh')));
	list_rhFeature = SurfStatListDir(char(strcat('*rh.fsaverage.', Feature, '.mgh')));

	lhFeature = [];
	rhFeature = [];
	for i = 1 : length(list_lhFeature)
		[curv, fnum] = read_curv(char(list_lhFeature(i)));
		if isempty(curv)
			curv = (SurfStatReadData(char(list_lhFeature(i))))';
			fnum = 327680;
		end
		if length(templatelh)~=0
			curv = (curv - median(curv)) ./ (prctile(curv, 70) - prctile(curv, 30));
			curv = curv .* (prctile(templatelh, 70) - prctile(templatelh, 30)) + median(templatelh);
		end
		lhFeature = [lhFeature curv];
		
		[curv, fnum] = read_curv(char(list_rhFeature(i)));
		if isempty(curv)
			curv = (SurfStatReadData(char(list_rhFeature(i))))';
			fnum = 327680;
		end
		if length(templaterh)~=0
			curv = (curv - median(curv)) ./ (prctile(curv, 70) - prctile(curv, 30));
			curv = curv .* (prctile(templaterh, 70) - prctile(templaterh, 30)) + median(templaterh);
		end
		rhFeature = [rhFeature curv];
	end

	Mean = (mean(lhFeature'))';
	Std  = (std(lhFeature'))';

	write_curv_properly(Mean, char(strcat('${TDIR}', '/lh.fsaverage.mean.', Feature)));
	write_curv_properly(Std, char(strcat('${TDIR}', '/lh.fsaverage.std.', Feature)));

	Mean = (mean(rhFeature'))';
	Std  = (std(rhFeature'))';

	write_curv_properly(Mean, char(strcat('${TDIR}', '/rh.fsaverage.mean.', Feature)));
	write_curv_properly(Std, char(strcat('${TDIR}', '/rh.fsaverage.std.', Feature)));

	%  Load FWHM Feature
	list_lhFeature = SurfStatListDir(char(strcat('*lh.fwhm${fwhm}.fsaverage.', Feature, '.mgh')));
	list_rhFeature = SurfStatListDir(char(strcat('*rh.fwhm${fwhm}.fsaverage.', Feature, '.mgh')));

	lhFeature = [];
	rhFeature = [];
	for i = 1 : length(list_lhFeature)
		[curv, fnum] = read_curv(char(list_lhFeature(i)));
		if isempty(curv)
			curv = (SurfStatReadData(char(list_lhFeature(i))))';
			fnum = 327680;
		end
		if length(templatelhfwhm)~=0
			curv = (curv - median(curv)) ./ (prctile(curv, 70) - prctile(curv, 30));
			curv = curv .* (prctile(templatelhfwhm, 70) - prctile(templatelhfwhm, 30)) + median(templatelhfwhm);
		end
		lhFeature = [lhFeature curv];
		
		[curv, fnum] = read_curv(char(list_rhFeature(i)));
		if isempty(curv)
			curv = (SurfStatReadData(char(list_rhFeature(i))))';
			fnum = 327680;
		end
		if length(templaterhfwhm)~=0
			curv = (curv - median(curv)) ./ (prctile(curv, 70) - prctile(curv, 30));
			curv = curv .* (prctile(templaterhfwhm, 70) - prctile(templaterhfwhm, 30)) + median(templaterhfwhm);
		end
		rhFeature = [rhFeature curv];
	end

	Mean = (mean(lhFeature'))';
	Std  = (std(lhFeature'))';

	write_curv_properly(Mean, char(strcat('${TDIR}', '/lh.fwhm${fwhm}.fsaverage.mean.', Feature)));
	write_curv_properly(Std, char(strcat('${TDIR}', '/lh.fwhm${fwhm}.fsaverage.std.', Feature)));

	Mean = (mean(rhFeature'))';
	Std  = (std(rhFeature'))';

	write_curv_properly(Mean, char(strcat('${TDIR}', '/rh.fwhm${fwhm}.fsaverage.mean.', Feature)));
	write_curv_properly(Std, char(strcat('${TDIR}', '/rh.fwhm${fwhm}.fsaverage.std.', Feature)));
end

EOF

for Subject in ${subj}
do	
	for FEAT in `ls ${TDIR} | grep ${Subject}`
	do
		echo "rm -f ${TDIR}/${FEAT}"
		rm -f ${TDIR}/${FEAT}
	done
done
