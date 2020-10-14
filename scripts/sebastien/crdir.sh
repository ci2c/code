#!/bin/bash

Dicom=$1

mkdir -p $Dicom/mri/orig
mkdir $Dicom/pcasl_32
mkdir $Dicom/pcasl_8
mkdir $Dicom/despot
mkdir $Dicom/star
mkdir $Dicom/raw

mkdir -p ${Dicom}_8c/mri/orig

echo "Mettre tous les rec et par dans le dossier $Dicom/raw"
