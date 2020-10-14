if [ -d "/home/tanguy" ]
then
	path="/media/tanguy"
else
	path="/media/"
fi


n=$(ls $path | wc -l)

copy_path="/home/tanguy/Temp_MCI/data"
file_path="/home/tanguy/NAS/tanguy/MCI/Data/"

if [ $n -eq 1 ]
then
	
	disk_name=$(ls $path)
	echo "disk name : $disk_name"

	disk_path="$path/$disk_name"
	echo "disk path : $disk_path"

	n_file=$(ls $disk_path | wc -l)
	if [ $n_file -eq 0 ]
	then
		echo ""
		echo ""
		echo "introduire un disque"
		echo "et relancer le script"
		echo ""
		exit
	fi
	

	echo "rm -Rf /home/tanguy/Temp_MCI"
	rm -Rf /home/tanguy/Temp_MCI
	mkdir /home/tanguy/Temp_MCI

	p=$(ls /home/tanguy/Temp_MCI | wc -l)
	mkdir $copy_path
	echo "nombre de dossier dans Temp_MCI = $p"	

	echo "cp -f $disk_path/data/*[!jpg] $copy_path"
	cp -f $disk_path/data/*[!jpg] $copy_path

	p=$(ls $copy_path | wc -l)
	echo "copie de $p fichiers"
	
	echo ""
	echo "eject"
	eject
	echo ""
	echo ""
	echo ""
	echo "nom du patient :"
	echo "(de la forme NOM_PRENOM)"
	echo "(si prénom composé : NOM_INITIALEPRENOM1-PRENOM2)"
	echo ""
	read SUBJ
	echo ""
	echo ""
	echo "date d'examen : "
	echo ""
	read "date"

	
	if [ -d "${file_path}/$SUBJ" ]
	then
		echo ""
		echo ""
		echo "ajout d'un examen pour $SUBJ"
	else
		echo ""
		echo ""
		echo "création du dossier $SUBJ"
		echo ""
		mkdir $file_path/$SUBJ
	fi

	echo "création du dossier examen"
	echo ""
	echo "mkdir $file_path/$SUBJ/$date"
	mkdir $file_path/$SUBJ/$date

	echo ""
	echo ""
	echo "conversion des fichiers DICOM"
	echo ""
	echo "dcm2nii -o $file_path/$SUBJ/$date $copy_path"
	dcm2nii -o $file_path/$SUBJ/$date $copy_path

else
	echo "un autre média est sur le compte Tanguy"
	echo "débrancher les périphériques de stockage ou indiquer manuellement le nom du disque"
fi
