#!/bin/bash

if [ $# -lt 6 ]
then
	echo "Usage: GetHybrideConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -out outfile_name            : Name of the output matlab file stored in SubjDir/SubjName/connectome"
	echo "Usage: GetHybrideConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
	exit 1
fi

#### Inputs ####
index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: GetHybrideConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -out outfile_name            : Name of the output matlab file stored in SubjDir/SubjName/connectome"
		echo ""
		echo "Usage: GetHybrideConnectivityMatrix.sh  -fs <SubjDir>  -subj <SubjName>  -out outfile_name "
		exit 1
		;;
	-fs)
		FS_PATH=`expr $index + 1`
		eval FS_PATH=\${$fsdir}
		echo "FS_PATH='$FS_PATH'"
		index=$[$index+1]
		;;
	-subj)
		SUBJECT_ID=`expr $index + 1`
		eval SUBJECT_ID=\${$SUBJECT_ID}
		echo "SUBJECT_ID='${SUBJECT_ID}'"
		index=$[$index+1]
		;;
	-out)
		out_name=`expr $index + 1`
		eval out_name=\${$out_name}
		echo "out_name='${out_name}'"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################

=$1
=$2
#DATA_PATH=$3

DTI_PATH="${FS_PATH}/${SUBJECT_ID}/dti/"
OUT_PATH="${FS_PATH}/${SUBJECT_ID}/connectome/"
#DATA_PATH="${DATA_PATH}/${SUBJECT_ID}/T1w/"
CORTEX_LOI_and_ROI="/home/romain/cortex_LOI_and_ROI.txt"
LIST_OF_STRUCT="/home/romain/ListOfStruct.txt"

fsdir=$FS_PATH
subj=$SUBJECT_ID


matlab -nodisplay <<EOF

indir = fullfile('${fsdir}','${subj}','connectome');
Surf_cortex = SurfStatReadSurf([{'/home/pierre/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET/lh.white'},{'/home/pierre/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET/rh.white'}]);
SurfStatWriteSurf('cortex_rsl.obj', Surf_cortex);

n_all = length(Surf_cortex.tri);

% Compute filter matrix and get triangle areas on native surface

    % Get surface area A
    X = Surf_cortex.coord(1, :);
    Y = Surf_cortex.coord(2, :);
    Z = Surf_cortex.coord(3, :);
    
    X = X(Surf_cortex.tri);
    Y = Y(Surf_cortex.tri);
    Z = Z(Surf_cortex.tri);
    
    Bary = [mean(X, 2) mean(Y, 2) mean(Z, 2)];
    
    Xab = X(:, 2) - X(:, 1);
    Xac = X(:, 3) - X(:, 1);
    Yab = Y(:, 2) - Y(:, 1);
    Yac = Y(:, 3) - Y(:, 1);
    Zab = Z(:, 2) - Z(:, 1);
    Zac = Z(:, 3) - Z(:, 1);
    N = cross([Xab Yab Zab], [Xac Yac Zac]);
    A = 0.5 .* sqrt( sum(N .* N, 2) );
    
    % Compute filter
    tri_id = (1:n_all)';
    tri1   = double(Surf_cortex.tri(:, 1));
    tri2   = double(Surf_cortex.tri(:, 2));
    tri3   = double(Surf_cortex.tri(:, 3));
    
    tri_vert = sparse(tri_id, tri1, ones(size(tri_id)), n_all, length(Surf_all.coord));
    tri_vert = sparse(tri_id, tri2, ones(size(tri_id)), n_all, length(Surf_all.coord)) + tri_vert;
    tri_vert = sparse(tri_id, tri3, ones(size(tri_id)), n_all, length(Surf_all.coord)) + tri_vert;
    Filter = tri_vert * tri_vert';
    Filter = double(Filter > 1);
    [index_i, index_j] = find(Filter);
    d = sum( (Bary(index_i, :) - Bary(index_j, :)).^2, 2);
    sigma = 2;
    Gaussian = exp(-d./(2.*sigma)) ./ (sigma .* 2 .* pi);
    Filter = sparse(index_i, index_j, Gaussian, n_all, n_all);
    Sum = sum(Filter, 2);
    Filter = sparse(index_i, index_j, Gaussian ./ Sum(index_i), n_all, n_all);

load /home/notorious/NAS/pierre/louise-10/FreeSurfer/Connectomes/cortical_mask_rsl.mat
load(fullfile(indir,'Connectome_rsl.mat'));
Selected = Connectome.selected_rsl;
Selected(:, mask_cortex) = 0;

Selected = Selected';
Selected = Filter * Selected;
Selected = Selected';

%chargement du connectome structurel (voxel) pour les structure sous corticales
load('Connectome_Struc_Voxel_SsCor')

Selected=[Selected ConnectomeVoxSsCor];

connectomeVox=incidenceVox'*incidenceVox;
Mask = logical(connectomeVox);
Mask = triu(Mask, 1);
Mat = Mask .* connectomeVox;
clear Mask;

% Compute connectivity matrices
clear Filter;
disp(['Process']);
disp('Load data...');
disp('Compute connectivity matrix');
Mat = Selected' * Selected;
clear Selected;
disp('Mask upper matrix');
Mask = logical(Mat);
Mask = triu(Mask, 1);
Mat = Mask .* Mat;
clear Mask;
disp('Get sqrt');
Mat = sqrt(Mat);
disp('Get indices');
[index_i, index_j, index_k] = find(Mat);
clear Mat;
disp('Correct for areas');
disp('Step 1.');
Ai = A(index_i);
disp('Step 2.');
Ai = Ai + A(index_j);
disp('Step 3.');
index_k = 2 .* index_k ./ Ai;
clear Ai;
disp('Remove NaN areas...');
index_k(~isfinite(index_k)) = 0;
disp('Setting Mat...');
Mat = sparse(index_i, index_j, index_k, n_all, n_all);
clear index_i index_j index_k;

disp('Save data...');
save(fullfile(indir,'${out_name}'), 'Mat', '-v7.3');
clear Mat;

EOF
