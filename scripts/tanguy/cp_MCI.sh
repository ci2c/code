inc=0
sd=/home/tanguy/NAS/tanguy/MCI/New_data_11_2014
old_data=/home/tanguy/NAS/tanguy/MCI/All_Data

while [ $inc -lt 1500 ]
do

	echo ""
	echo ""
	echo "NOM DU PATIENT"

	read name

	echo ""
	echo ""
	echo "DATE D'EXAMEN"

	read date 


	if [ -d $old_data/$name/$date ]
		then
		echo ""
		echo "EXAMEN DEJA PRESENT DANS $old_data"
		echo ""
		echo "	mkdir -p $sd/$name/$date"
		mkdir -p $sd/$name/$date
		echo "cp -Rf $old_data/$name/$exam/* $sd/$name/$date"
		cp -Rf $old_data/$name/$exam/* $sd/$name/$date
	elif [ -d $sd/$name/$date ]
		then
		echo ""
		echo "EXAMEN DEJA IMPORTE DANS $sd"
		echo ""
	else
		echo ""
		echo "EXAMEN NON PRESENT"
		echo ""
		echo "eject"
		eject
		echo ""
		echo "INSERER DISQUE"
		echo ""



		ndisk=`ls /media/tanguy | wc -l`

		while [ ! $ndisk -eq 1 ]
		do
		sleep 5
		echo "waiting for a disk"
		ndisk=`ls /media/tanguy | wc -l`
		done
		mkdir -p $sd/$name/$date
		echo ""
		echo ""
		echo "IMPORTER DONNEES DISQUE"


		disk=`ls /media/tanguy`
		echo "disk name : $disk"		

		echo "cp -Rf $disk/* $sd/$name/$date"
		cp -Rf /media/tanguy/$disk/* $sd/$name/$date
		chmod 775 $sd/$name/$date -R

	fi

	sleep 1

	inc=$((inc + 1))

	echo ""
	echo ""
	echo "__________________________"
	echo "INSERER LE DISQUE SUIVANT"
	echo ""


done
