


for name in `ls /home/fatmike/renaud/tep_fog/freesurfer/g1/ --hide ALIB --hide BISI --hide fsaverage --hide lh.EC_average --hide PETI --hide rh.EC_average  `
do
cd /home/fatmike/renaud/tep_fog/freesurfer/g1/$name
prep_tracto_on_roi.sh -sd /home/fatmike/renaud/tep_fog/freesurfer/g1/ -subj $name -roidir  /home/tanguy/NAS/tanguy/tep_fog/ROI/
qbatch -N tr_$name -q heavy_q -oe /home/tanguy/Logdir run_tracto_on_roi.sh -sd /home/fatmike/renaud/tep_fog/freesurfer/g1/ -subj $name
done

