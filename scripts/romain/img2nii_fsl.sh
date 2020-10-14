#!/bin/sh

#Image file type converter using fslchfiletype
#This script converts various image files into NIFTI format (.nii) files.
#K. Nemoto 19 Jan 2013

if [ $# -lt 1 ] ; then
	echo "Please specify the files you want to convert!"
	echo "Usage: $0 filename"
	exit 1
fi

for file in "$@" ; do
	if [ -f $file ] ; then
		fslchfiletype NIFTI $file
	else
		echo "$file: No such file"
	fi
done

