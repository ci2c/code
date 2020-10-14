#!/bin/bash

if [ $# -lt 6 ]
then
	echo "Usage: local-recon-all arguments"
	echo ""
	echo "Arguments following local-recon-all are exactly those that might follow the classical recon-all"
	echo ""
	echo "qcache step is automatically processed"
	echo ""
	echo "Usage: local-recon-all arguments"
	exit 1
fi

I=""
S=""
B=""
T=""
L=""
CL=""
index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-all|-autore*)
		eval ACTION=\${$index}
		;;
	-sd)
		SD=`expr $index + 1`
		eval SD=\${$SD}
		index=$[$index+1]
		;;
	-subjid|-sid)
		SID=`expr $index + 1`
		eval SID=\${$SID}
		S="-subjid ${SID}"
		index=$[$index+1]
		;;
	-i)
		INPUT=`expr $index + 1`
		eval INPUT=\${$INPUT}
		I="-i ${INPUT}"
		index=$[$index+1]
		;;
	-base)
		template=`expr $index + 1`
		eval template=\${$template}
		B="-base ${template}"
		index=$[$index+1]
		;;
	-tp)
		tip=`expr $index + 1`
		eval tip=\${$tip}
		T="${T} -tp ${tip}"
		index=$[$index+1]
		;;
	-long)
		template=`expr $index + 2`
		tip=`expr $index + 1`
		eval template=\${$template}
		eval tip=\${$tip}
		L="-long ${tip} ${template}"
		index=$[$index+2]
		;;
	*)
		T=`expr $index`
		eval T=\${$T}
		CL="${CL} ${T}"
		;;
	esac
	index=$[$index+1]
done

# Launch recon-all locally
# echo cmdsup = ${CL}
# echo action = ${ACTION}
# echo subjid = ${S}
# echo sd     = ${SD}
# echo input  = ${I}
# echo base = ${B}
# echo timepoint = ${T}
# echo long = ${L}

# Copy of sources directories on /tmp
if [ -n "${B}" ]
then
	for tp in ${SD}/*_T[0-9]
	do
		echo "cp -R -u $tp /tmp"
		cp -R -f $tp /tmp
	done
fi 
if [ -n "${L}" ]
then
	#for rep in ${SD}/*
	#do
		echo "cp -R -u ${SD}/$tip /tmp"
		cp -R -f ${SD}/$tip /tmp
		echo "cp -R -u ${SD}/$template /tmp"
		cp -R -f ${SD}/$template /tmp
	#done
fi

# Initialisation before recon-all cmd
# init_fs5.1
export FREESURFER_HOME=/home/global/freesurfer5.1/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
recon-all ${ACTION} ${B} ${T} ${L} -sd /tmp ${S} ${CL} -no-isrunning ${I}
recon-all -qcache ${B} ${T} ${L} -sd /tmp ${S} ${CL} -no-isrunning

if [ -n "${S}" ]
then
	echo "cp -R /tmp/${SID}/* ${SD}/"
	cp -R /tmp/${SID}/* ${SD}/
elif [ -n "${B}" ]
then
	echo "cp -R /tmp/${template} ${SD}/"	
	cp -R /tmp/${template} ${SD}/
elif [ -n "${L}" ]
then
	echo "cp -R /tmp/${tip}.long.${template} ${SD}/"
	cp -R /tmp/${tip}.long.${template} ${SD}/
fi
