#!/bin/bash

study=$1
subj=$2
Dicom="$study/$subj"

echo "Assurez vous que vos données sont rangées comme il faut...

	Dossier Patient
		|
freesurfer	PET	ASL

"

test="$study $subj"
echo $test
