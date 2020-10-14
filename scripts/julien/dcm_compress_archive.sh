#!/bin/bash

#  dcm_compress_archive.sh
#  


output=$1

cd ${output}

for date in $(ls -d *)
do

cd ${output}${date}/

for patient in $(ls -d *)
do
echo "
-------------- compression de ${patient}"
#if
#	[ -d ${patient} ]
#then

cd ${output}${date}/${patient}/

for study in $(ls -d *)
do



cd ${output}${date}/${patient}/${study}/

for serie in $(ls -d *)
do

if
[ -d ${serie} ]
then
# compte le nombre de fichier DICOM
# on retire les dicom commençant par phMR, qui sont des fichiers non images sur ETIAM
cd ${output}${date}/${patient}/${study}/${serie}/
nb=$(ls | wc -l)
echo "${nb}" >> ${output}${date}/${patient}/${study}/${serie}.log
cd ${output}${date}/${patient}/${study}/
#create tar
tar -cvf ${serie}.tar  ${serie}/
#test du .tar
echo "Testing tar archive ..."
if ! tar tf ${serie}.tar  &> /dev/null; then
echo "Error when creating tar archive ${patient}/${study}->${serie}" >> error.log
else
echo "tar ok"
echo "Compressing with pbzip2"
#create bz2
lbzip2 -f --best -v -n 6 ${serie}.tar
#pbzip2 -f ${serie}.tar
#testing bz archive
echo "Testing bzip2 archive ..."
bzip2 -vt  ${serie}.tar.bz2 2> test_${serie}.txt
result=$(sed -n 1p test_${serie}.txt | sed 's/.*\(..\)$/\1/')

if  [ "${result}" == "ok" ]
then
echo "bzip2 ok"
rm test_${serie}.txt
rm -rf ${serie}/
md5sum ${serie}.tar.bz2 > ${serie}.checksum
else
echo "Error when creating bz2 archive ${patient}/${study}->${serie}" >> error.log
fi


fi

fi
done #serie

done #study
#fi
done  # patient

done # date
