#!/bin/bash
#
# name: spip-crop.sh
# 05.17.06 - Thomas - First version of the script
#
#
# Crop the input volume along the z-axis (axial)
#
# Summary of the options
# ----------------------
#   -zmin I : crop the input volume from slice z=I
#   -zmax J : crop the input volume till slice z=J
#   -fake   : Do a dry run (echo cmds only)
#   -nobkp  : Don't back up of the input volume
	

# ----------------------------
# Load the configuration file
# ----------------------------

if [ -z $SPIP_DIR ]; then
		echo "ERROR: $SPIP_DIR variable undefined, execution aborted"
		exit 1
fi
config_dir=$SPIP_DIR

cfg_successfully_loaded=0
source ${config_dir}/cfg

if [ ${cfg_successfully_loaded} -ne 1 ]
then
	echo "ERROR: Configuration failed"
	exit 1
fi


# ------------------------
# Setting useful variables
# ------------------------


last=$#
log_header="[spip-crop]"
tmp_dir="/tmp/spip-crop_$$/"

fake=0         # Do a dry run, echo cmds only
nobkp=0        # Do not back up the input volume
zmin="null"    # Slice from which the MRI will be cropped
zmax="null"    # Slice to which the MRI will be cropped


# ---------------------
# Some useful functions
# ---------------------


print_usage() {
	echo
	echo "Usage: spip-crop.sh <input_volume> [options]"
	echo "       spip-crop.sh [-help]"
}

print_help() {
	echo
	echo "| Crop the input volume along the z-axis (axial)"
	echo
	echo "Summary of the options"
	echo "----------------------"
	echo "  -zmin I : crop the input volume from slice z=I"
	echo "  -zmax J : crop the input volume till slice z=J"
	echo
	echo "  -fake   : Do a dry run (echo cmds only)"
	echo "  -nobkp  : Don't back up of the input volume"
	echo
	echo "Example"
	echo "-------"
	echo "  spip-crop.sh volume.mnc.gz -zmin 10 -zmax 250"
	print_usage
}

do_cmd() {
	local l_command=""
	local l_sep=""
	local l_index=1
	while [ ${l_index} -le $# ]
	do
		eval arg=\${$l_index}
		l_command="${l_command}${l_sep}${arg}"
		l_sep=" "
		l_index=$[${l_index}+1]
	done
	echo
	echo "-------------------------------------------------------------------------------"
	echo "${log_header} ${l_command}"
	echo "-------------------------------------------------------------------------------"
	if [ "$fake" -eq "0" ]
	then
		$l_command
	fi
}

is_integer() {
	if [ -z "`echo $1 | egrep '^-*[0-9]+$'`" ]
	then
		echo "ERROR: Invalid parameters for -zmin/-zmax option"
		print_usage
		exit 1
	fi
}


# -------------------
# Check the arguments
# -------------------


index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		print_help;
		exit 1
		;;
	-zmin)
		index=$[$index+1]
		eval zmin=\${$index}
		is_integer $zmin
		if [ "$last" -eq "$#" ]
		then
			last=$[$index-2]
		fi
		;;
	-zmax)
		index=$[$index+1]
		eval zmax=\${$index}
		is_integer $zmax
		if [ "$last" -eq "$#" ]
		then
			last=$[$index-2]
		fi
		;;
	-fake)
		fake=1
		if [ $last -eq $# ]
		then
			last=$[$index-1]
		fi
		;;
	-nobkp)
		nobkp=1
		if [ $last -eq $# ]
		then
			last=$[$index-1]
		fi
		;;
	-*)
		echo "ERROR: Unknown option"
		print_usage;
		exit 1
		;;
	esac
	index=$[$index+1]
done

if [ $# -lt 3 ] 
then
	echo "ERROR: Not enough arguments"
	print_usage
	exit 1
fi

if [ "$last" -eq "0" ]
then
	echo "ERROR: Options must be specified at the end of the command line"
	print_usage;
	exit 1
fi


# ---------------------------------------
# Setting the filenames and directories
# ---------------------------------------


mri=${1%.gz}

zipped=".gz" # The file is zipped
if [ "$mri" == "$1" ]
then
	zipped=""
fi

mri=${mri%.mnc}

inname=`basename ${mri}`
indir=`dirname ${mri}`

bkpname="${inname}_ncrop"
tmpname=$inname

if [ ! -e ${tmp_dir} ]
then
	mkdir ${tmp_dir}
fi

echo $inname


# --------
# Cropping
# --------


if [ "$zmin" != "null" ]
then
	if [  "$zmax" != "null" ]
	then
		# We have the two boundaries
		do_cmd "mincreshape" "-clobber" \
							 "-dimrange zspace=$zmin,$zmax" \
							 "$1" \
							 "${tmp_dir}/${tmpname}.mnc"
	else
		# We only have zmin
		zlength=`mincinfo -dimlength zspace $1`
		do_cmd "mincreshape" "-clobber" \
							 "-dimrange zspace=$zmin,$[$zlength-$zmin]" \
							 "$1" \
							 "${tmp_dir}/${tmpname}.mnc"
	fi
else
	if [ "$zmax" != "null" ]
	then
		# We only have zmax
		do_cmd "mincreshape" "-clobber" \
							 "-dimrange zspace=0,$zmax" \
							 "$1" \
							 "${tmp_dir}/${tmpname}.mnc"
	else
		# This case should never arise
		echo "${log_header} Nothing to do"
		rm -rf ${tmp_dir}
		exit 0
	fi
fi


# ------------------
# Saving the result
# ------------------


if [ $nobkp -ne 1 ]
then
	do_cmd "cp" "-f" "$1" "${indir}/${bkpname}.mnc${zipped}"
fi

do_cmd "cp" "-f" "${tmp_dir}/${tmpname}.mnc" "${mri}.mnc"

gzip -f "${mri}.mnc"


# ---------------------
# Remove the temp files
# ---------------------

rm -rf ${tmp_dir}
