sd=/home/tanguy/dumbo/tanguy/ictus/TBSS
mkdir -p /home/tanguy/Logdir/ictus
for pop in PATIENTS TEMOINS
do
	for subj in `ls $sd/$pop`
	do
		subj=`basename $subj`
		echo "qbatch -N FA_$subj -q fs_q -oe /home/tanguy/Logdir/ictus DTI_FA_ictus.sh -sd $sd/$pop -subj $subj"
		qbatch -N FA_$subj -q fs_q -oe /home/tanguy/Logdir/ictus DTI_FA_ictus.sh -sd $sd/$pop -subj $subj
		sleep 1
	done
done
  