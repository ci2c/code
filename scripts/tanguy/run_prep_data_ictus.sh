sd=/NAS/dumbo/protocoles/ictus/data/2014_05_19_ETUDE_ICTUS/patients_ictus_2_temp
inc=1;
for dicomdir in DICOM  DICOMA  DICOMB  DICOMC
do
	echo "run for dicomdir = $dicomdir"
	for padir in `ls $sd/$dicomdir`
	do
		padir=`basename $padir`
		if [ "$padir" != "@eaDir" ]
		then
			
			echo "run for padir = $padir"
			mkdir $sd/$dicomdir/$padir/mcverter
			echo "qbatch -N prep_$inc -q fs_q -oe /home/tanguy/Logdir/ictus mcverter -o $sd/$dicomdir/$padir/mcverter -f fsl $sd/$dicomdir/$padir/*/*"
			qbatch -N prep_$inc -q fs_q -oe /home/tanguy/Logdir/ictus mcverter -o $sd/$dicomdir/$padir/mcverter -f fsl $sd/$dicomdir/$padir/*/*
			inc=$((inc+1))
		fi

	done

done




JOBS=`qstat |grep prep |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "mcverter pas encore fini"
sleep 20
JOBS=`qstat | grep prep | wc -l`
done


for dicomdir in DICOMB  DICOMC  DICOMD  DICOME  DICOMF
do

	for padir in `ls $sd/$dicomdir/PA*`
	do
		padir=`basename $padir`
		for stdir in `ls $sd/$dicomdir/$padir/S*`
		do
			mv $sd/$dicomdir/$padir/$stdir/mcverter $sd/${padir}_${stdir}
		done

	done

done


