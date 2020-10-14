#!/bin/bash


# Pierre Besson @ CHRU Lille, Mar. 2011
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: Undirect_tracking.sh  -seed <path_to_seed>  -is <seg1> <seg2> ... <segN>  -bpx <bedpostx_dir>  -o <outdir>"
	echo ""
	echo "  -seed <path_to_seed>              : Seed mask"
	echo "  -is <segN>                        : Intermediate segmentations"
	echo "  -bpx <bedpostx_dir>               : Path to the .bedpostX directory"
	echo "  -o <outdir>                       : Output directory"
	echo ""
	echo "Usage: Undirect_tracking.sh  -seed <path_to_seed>  -is <seg1> <seg2> ... <segN>  -bpx <bedpostx_dir>  -o <outdir>"
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
		echo "Usage: Undirect_tracking.sh  -seed <path_to_seed>  -is <seg1> <seg2> ... <segN>  -bpx <bedpostx_dir>  -o <outdir>"
		echo ""
		echo "  -seed <path_to_seed>              : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -is <segN>                        : Intermediate segmentations"
		echo "  -bpx <bedpostx_dir>               : Path to the .bedpostX directory"
		echo "  -o <outdir>                       : Output directory"
		echo ""
		echo "Usage: Undirect_tracking.sh  -seed <path_to_seed>  -is <seg1> <seg2> ... <segN>  -bpx <bedpostx_dir>  -o <outdir>"
		echo ""
		exit 1
		;;
	-seed)
		seed=`expr $index + 1`
		eval seed=\${$seed}
		echo " |--> Seed : $seed"
		;;
	-o)
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo " |--> Output directory : $outdir"
		;;
	-bpx)
		bpx=`expr $index + 1`
		eval bpx=\${$bpx}
		echo " |--> bedpostX directory : $bpx"
		;;
	-is)
		i=$[$index+1]
		eval infile=\${$i}
		iseg=""
		while [ "$infile" != "-seed" -a "$infile" != "-o" -a "$infile" != "-bpx" -a $i -le $# ]
		do
		 	iseg="${iseg} ${infile}"
		 	i=$[$i+1]
		 	eval infile=\${$i}
		done
		index=$[$i-1]
		echo " |--> Intermediate segmentations : $iseg"
		;;
	esac
	index=$[$index+1]
done

current_dir=`pwd`

# Get seed coordinates
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${current_dir}

% Load label
Nii = load_nifti('${seed}');
[X, Y, Z] = ndgrid(0 : size(Nii.vol, 1)-1, 0 : size(Nii.vol, 2)-1, 0 : size(Nii.vol, 3)-1);
dlmwrite('${outdir}/seed_coordinates.txt', [X(Nii.vol(:)~=0) Y(Nii.vol(:)~=0) Z(Nii.vol(:)~=0)], 'delimiter', ' ');
EOF

# Tract all seed voxels
Nlines=`cat ${outdir}/seed_coordinates.txt | wc -l`

i=1
while [ ${i}  -le ${Nlines} ]
do
	Line=`sed -n "${i},${i}p;${i}q" ${outdir}/seed_coordinates.txt`
	X=`echo ${Line} | awk '{print $1}'`
	Y=`echo ${Line} | awk '{print $2}'`
	Z=`echo ${Line} | awk '{print $3}'`
	rm -rf ${outdir}/Seed_${X}_${Y}_${Z}
	mkdir ${outdir}/Seed_${X}_${Y}_${Z}
	echo "${Line}" > ${outdir}/Seed_${X}_${Y}_${Z}/fdt_coordinates.txt
	echo "probtrackx --mode=simple --seedref=${bpx}/nodif_brain_mask -o Seed -x ${outdir}/Seed_${X}_${Y}_${Z}/fdt_coordinates.txt  -l -c 0.2 -S 2000 --steplength=0.5 -P 5000 --forcedir --opd -s ${bpx}/merged -m ${bpx}/nodif_brain_mask  --dir=${outdir}/Seed_${X}_${Y}_${Z}"
	probtrackx --mode=simple --seedref=${bpx}/nodif_brain_mask -o Seed -x ${outdir}/Seed_${X}_${Y}_${Z}/fdt_coordinates.txt  -l -c 0.2 -S 2000 --steplength=0.5 -P 5000 --forcedir --opd -s ${bpx}/merged -m ${bpx}/nodif_brain_mask  --dir=${outdir}/Seed_${X}_${Y}_${Z}
	i=$[${i}+1]
done

# Copy all fiber paths in a directory
mkdir ${outdir}/fibers
cp ${outdir}/Seed_*_*_*/*nii.gz ${outdir}/fibers/
rm -rf ${outdir}/Seed_*_*_*

# Get connectivity maps
i=1
for seg in `echo ${iseg}`
do
	if [ ${i} -lt 10 ]
	then
		fslmaths ${seg} -mul 1 ${outdir}/seg_00${i} -odt float
	else
		fslmaths ${seg} -mul 1 ${outdir}/seg_0${i} -odt float
	fi
	i=$[${i}+1]
done

matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${outdir}
 
ImageList = SurfStatListDir('${outdir}/seg_*nii.gz');
SeedCoord = textread('${outdir}/seed_coordinates.txt');

for i = 1 : length(ImageList)
	Nii = load_nifti(char(ImageList(i)));
	if i > 1
		SumVol = Nii.vol + SumVol;
	else
		SumVol = Nii.vol;
	end
end

for i = 1 : length(ImageList)
	Nii = load_nifti(char(ImageList(i)));
	Vol{i} = zeros(size(Nii.vol));
	for j = 1 : length(SeedCoord)
		Fib_name = strcat('${outdir}/fibers/Seed_', num2str(SeedCoord(j, 1)), '_', num2str(SeedCoord(j, 2)), '_', num2str(SeedCoord(j, 3)), '.nii.gz');
		Fib = load_nifti(Fib_name);
		FibersWeighted = Fib.vol .* Nii.vol ./ SumVol;
		Vol{i}(SeedCoord(j, 1)+1, SeedCoord(j, 2)+1, SeedCoord(j, 3)+1) = sum(FibersWeighted(Nii.vol(:)~=0));
	end
	Vol{i}(isnan(Vol{i}(:))) = 0;
end

SumVol = zeros(size(SumVol));
for i = 1 : length(ImageList)
	SumVol = SumVol + Vol{i};
end

for i = 1 : length(ImageList)
	Vol{i} = 1000 * Vol{i} ./ SumVol;
	Nii.vol = Vol{i};
	if i < 10
		save_nifti(Nii, strcat('${outdir}/undirect_seed_through_seg_00', num2str(i), '.nii.gz'));
	else
		save_nifti(Nii, strcat('${outdir}/undirect_seed_through_seg_0', num2str(i), '.nii.gz'));
	end
end

EOF
