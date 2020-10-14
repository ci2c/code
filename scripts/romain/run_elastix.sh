
#ATLAS
PATH_EXE="/home/romain/Downloads/elastix_linux64_v4.8/bin"
PATH_ATLAS="/home/romain/Downloads/ct_data"
PATH_MASK="/home/romain/Downloads/atlas"
PATH_MOUSE="/home/romain/Downloads/ct-SOURIS-DCM/1.2.826.0.1.3417726.3.1031400464/1.2.826.0.1.3417726.3.247050.20130906141859515"

##mri_convert -i ${PATH_MASK}/atlas_380x992x208.img -o ${PATH_MASK}/atlas_380x992x208.nii
##mrconvert ${PATH_MASK}/atlas_380x992x208.img ${PATH_MASK}/atlas_380x992x208.nii.gz

mri_extract_label -dilate 1 ${PATH_MASK}/atlas_380x992x208.img 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 ${PATH_MASK}/atlas_mask2.nii.gz

./elastix -m ${PATH_ATLAS}/ct_380x992x208.hdr -mMask ${PATH_MASK}/atlas_mask2.nii -f ${PATH_MOUSE}/test/20130906_120152s000a000.nii -fMask ${PATH_MASK}/maskRV.nii -p ${PATH_EXE}/Parameters.similarity.txt -p ${PATH_EXE}/Parameters.NCC.txt -out ${PATH_MOUSE}/resultDir

./elastix -m ${PATH_ATLAS}/ct_380x992x208.hdr -mMask ${PATH_MASK}/atlas_mask2.nii -f ${PATH_MOUSE}/test/20130906_120152s000a000.hdr -fMask ${PATH_MASK}/maskRV.nii -p /home/romain/Downloads/elastix_example_v4.8/exampleinput/parameters_Rigid.txt -p /home/romain/Downloads/elastix_example_v4.8/exampleinput/parameters_BSpline.txt -out ${PATH_MOUSE}/resultDir

#${PATH_EXE}/elastix -f fixed_image.mhd -m moving_image.mhd -fp fixedPointSet.txt -mp movingPointSet.txt -p parameters.similarity.txt -p parameters.NCC_EDM.txt -out resultDir-p /home/romain/Downloads/elastix_example_v4.8/exampleinput/

freeview ${PATH_ATLAS}/ct_380x992x208.nii ${PATH_MOUSE}/test/20130906_120152s000a000.nii ${PATH_MOUSE}/resultDir/result.0.nii
freeview ${PATH_MOUSE}/resultDir/result.0.nii
