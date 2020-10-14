#!/bin/bash

dir=$1

echo
echo "Warning : Coupes acquises en séquentiel f->h de préférence"
echo "Rentrer le TR (s)"
read TR
echo "Nombre de coupes ?"
read slice
echo "Acquisition "
echo "Nombre de blocs ?"
read bloc
echo "Nombre de dynamiques par bloc ?"
read dyn

ARRAY=(run1 run2 run4)
count=0
while [ $count -le 2 ]
do
echo
echo "Traitement stats du ${ARRAY[$count]}"
echo
matlab -nodisplay <<EOF > ${dir}/surfstats.log

%Definition des parametres des fonctions HRF

hrf_array=[5.4 5.2 10.8 7.35 0.35;
		3 5.2 10.8 7.35 0;
             	5 5.2 10.8 7.35 0;
             	7 5.2 10.8 7.35 0;
             	9 5.2 10.8 7.35 0];

for nhrf=1:length(hrf_array)
	
	%On verifie le dimensions de la fonc

	V=spm_vol('${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth.nii');


	hrf_parameters=hrf_array(nhrf,:);

	frametimes=(0:55)*${TR}; 
	slicetimes=[1:${slice}]/${slice}*${TR};
	S=[zeros(8,1);ones(8,1);zeros(8,1);ones(8,1);zeros(8,1);ones(8,1);zeros(8,1)];
	X_cache=fmridesign(frametimes,slicetimes, [] , S,hrf_parameters); 

	contrast=[1 0;0 1];

	which_stats='_mag_t _mag_sd _mag_ef _mag_F _cor _fwhm'; 
	input_file='${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth.nii';
	output_file_base=['${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_' num2str(nhrf); '${dir}/${ARRAY[$count]}/${ARRAY[$count]}_contr_' num2str(nhrf)];
	fmrilm(input_file, output_file_base, X_cache, contrast, [], which_stats);
	mask_file='${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth.nii'; 
	[search_volume, num_voxels]=mask_vol(mask_file); 

	X=[1]';
	contrast2=[1]; 
	which_stats='_mag_t _mag_ef _mag_sd';
	input_files_ef=['${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_mag_ef.nii'];
	input_files_sd=['${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_mag_sd.nii'];
	output_file_base='${dir}/${ARRAY[$count]}/${ARRAY[$count]}_multi';
	DF=multistat(input_files_ef,input_files_sd,[],[],X,contrast2,output_file_base,which_stats,Inf)
	stat_threshold(search_volume,num_voxels,6,DF.fixed)
end
EOF

count=$[$count+1]
done

ARRAY=(run3)
count=0
while [ $count -le 0 ]
do
echo
echo "Traitement stats du ${ARRAY[$count]}"
echo
matlab -nodisplay <<EOF >> ${dir}/surfstats.log

hrf_array=[5.4 5.2 10.8 7.35 0.35;
		3 5.2 10.8 7.35 0;
             	5 5.2 10.8 7.35 0;
             	7 5.2 10.8 7.35 0;
             	9 5.2 10.8 7.35 0];

for nhrf=1:length(hrf_array)

	hrf_parameters=hrf_array(nhrf,:);

	frametimes=(0:83)*3; 
	slicetimes=[1:34]/34*3;
	S=[zeros(12,1);ones(12,1);zeros(12,1);ones(12,1);zeros(12,1);ones(12,1);zeros(12,1)];
	X_cache=fmridesign(frametimes,slicetimes, [] , S,hrf_parameters); 
	contrast=[1 0;0 1];
	which_stats='_mag_t _mag_sd _mag_ef _mag_F _cor _fwhm'; 
	input_file='${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth.nii';
	output_file_base=['${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_' num2str(nhrf); '${dir}/${ARRAY[$count]}/${ARRAY[$count]}_contr_' num2str(nhrf)];
	fmrilm(input_file, output_file_base, X_cache, contrast, [], which_stats);
	mask_file='${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth.nii'; 
	[search_volume, num_voxels]=mask_vol(mask_file); 
	X=[1]';
	contrast2=[1]; 
	which_stats='_mag_t _mag_ef _mag_sd';
	input_files_ef=['${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_mag_ef.nii'];
	input_files_sd=['${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_mag_sd.nii'];
	output_file_base='${dir}/${ARRAY[$count]}/${ARRAY[$count]}_multi';
	DF=multistat(input_files_ef,input_files_sd,[],[],X,contrast2,output_file_base,which_stats,Inf)
	stat_threshold(search_volume,num_voxels,6,DF.fixed)
end
EOF
count=$[$count+1]
done

ARRAY=(run1 run2 run3 run4)
hrf=(1 2 3 4)
count=0
while [ $count -le 3 ]
do
echo
echo
echo "Repositionnement des images du ${ARRAY[$count]}"
echo
echo
mri_convert ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth.nii ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth.mnc
mri_convert ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_${hrf[$count]}_mag_t.nii ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_${hrf[$count]}_mag_t.mnc
mincreshape ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth.mnc ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth_temp.mnc -dimrange time=0 -clobber
mritoself -close ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_smooth_temp.mnc ${dir}/t1.mnc ${dir}/${ARRAY[$count]}/${ARRAY[$count]}tot1.xfm -clobber
mincresample -nelements 128 128 68 -transformation ${dir}/${ARRAY[$count]}/${ARRAY[$count]}tot1.xfm -use_input_sampling -step 2 2 2 ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_${hrf[$count]}_mag_t.mnc ${dir}/${ARRAY[$count]}/${ARRAY[$count]}_activ_${hrf[$count]}_mag_tres.mnc -clobber
count=$[$count+1]
done
echo
echo "c'est fini"


