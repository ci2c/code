#!/bin/bash

if [ -z "$1" ]; then
cat <<EOU
Create an HTML page to quickly inspect the surfaces of many
subjects, using the "shots" produced by the 'takeshots' command.

Usage: makehtml [options]

The options are:
-s <subjid>    : Specify one subject ID
-l <listid>    : Specify a file list with the subject IDs, one per line
-m <mesh>      : Specify a surface file (pial, white, inflated, sphere, etc.)
-p <parc>      : Specify a parcellation to load (aparc, a2009s, a2005s)
-d <directory> : Specify the directory to save the resulting HTML page

* Important: This script requires ImageMagick (command 'convert'), and
  that the FreeSurfer variable SUBJECTS_DIR	has been set.

_____________________________________
Anderson M. Winkler
Yale University / Institute of Living
Jan/2010
http://brainder.org
EOU
exit 1
fi

# Check and accept the arguments
while getopts 's:l:m:p:d:' OPTION
do
   case ${OPTION} in
      s) SUBJ_LIST="${SUBJ_LIST} ${OPTARG}" ;;
      l) SUBJ_LIST="${SUBJ_LIST} $(cat ${OPTARG})" ;;
      m) MESH_LIST="${MESH_LIST} ${OPTARG}" ;;
      p) PARC_LIST="${PARC_LIST} ${OPTARG}" ;;
      d) HTML_DIR="${OPTARG}" ;;
   esac
done
if [ "x${HTML_DIR}" == "x" ] ; then
   echo "Output directory not specified"
   exit 1 ;
fi

# Cropping, format conversion and thumbnail generation
for m in ${MESH_LIST} ; do
   echo "Preparing ${m} images"
   mkdir -p ${HTML_DIR}/${m}/images ${HTML_DIR}/${m}/thumbnails
   [ "${m}" == "pial" ] || [ "${m}" == "white" ] && sizimg="410x300" && sizthm="205x150"
   [ "${m}" == "inflated" ]                      && sizimg="610x400" && sizthm="305x200"
   [ "${m}" == "sphere" ]                        && sizimg="440x440" && sizthm="220x220"
   for s in ${SUBJ_LIST} ; do
      echo ${s}
      for p in ${PARC_LIST} ; do
         for img in ${SUBJECTS_DIR}/${s}/shots/${s}_*h_${m}_${p}_*.tif ; do
            bimg=$(basename ${img} .tif)
            convert ${img} -trim -background black -gravity center -extent ${sizimg} -format png ${HTML_DIR}/${m}/images/${bimg}.png
            convert ${HTML_DIR}/${m}/images/${bimg}.png -resize ${sizthm} -depth 8 -colors 256 ${HTML_DIR}/${m}/thumbnails/${bimg}.png
         done
      done
   done
done

# Create the HTML file
echo "Creating HTML pages"
for m in ${MESH_LIST} ; do
   for p in ${PARC_LIST} ; do
      htmlfile=${HTML_DIR}/${m}/${m}_${p}.html
      echo "<html><title>Surface Results (${m}, ${p})</title><body><table>"  > ${htmlfile}
      for s in ${SUBJ_LIST} ; do
         echo "<tr>" >> ${htmlfile}
         for h in lh rh ; do for view in lat med sup inf ; do 
            echo "<td><a href=\"images/${s}_${h}_${m}_${p}_${view}.png\"><img src=\"thumbnails/${s}_${h}_${m}_${p}_${view}.png\" border=0 title=\"${s}, ${h}, ${m}, ${p}, ${view}\"></a></td>" >> ${htmlfile}
         done ; done
         echo "</tr>" >> ${htmlfile}
      done
      echo "</table></body></html>" >> ${htmlfile}
   done
done

# Create the index.html
echo "<html><title>Inspect results</title><body><h1>Inspect results</h1><hr>"  > ${HTML_DIR}/index.html
for m in ${MESH_LIST} ; do
   for p in ${PARC_LIST} ; do
      echo "<p><a href=\"${m}/${m}_${p}.html\">${m}, ${p}</a></p>" >> ${HTML_DIR}/index.html
   done
done
echo "</table></body></html>" >> ${HTML_DIR}/index.html
echo "Done!"