#!/bin/bash

file=$1

#(0018,1030) LO [3DT1]                                   #   4, 1 ProtocolName
PROT=`dcmdump +P "0018,1030" ${file} | cut -d '[' -f2 | cut -d ']' -f1`

#(0018,9008) CS [GRADIENT]                               #   8, 1 EchoPulseSequence
TYPE=`dcmdump +P "0018,9008" ${file} | cut -d '[' -f2 | cut -d ']' -f1`

#TR (0018,0080) DS [7.19999980926513]                       #  16, 1 RepetitionTime
val=`dcmdump +P "0018,0080" ${file} | cut -d '[' -f2 | cut -d ']' -f1`
TR=`python -c "print (round(${val},2))"`

#TE (0018,0081) DS [3.301]                                  #   6, 1 EchoTime
val=`dcmdump +P "0018,0081" ${file} | cut -d '[' -f2 | cut -d ']' -f1`
TE=`python -c "print (round(${val},2))"`

#NSA (0018,0083) DS [1]                                      #   2, 1 NumberOfAverages
val=`dcmdump +P "0018,0083" ${file} | cut -d '[' -f2 | cut -d ']' -f1`
NSA=`python -c "print (round(${val}))"`

#(2001,1023) DS [9]                                      #   2, 1 FlipAnglePhilips
val=`dcmdump +P "2001,1023" ${file} | cut -d '[' -f2 | cut -d "]" -f1`
FA=`python -c "print (round(${val}))"`

#ST(0018,0050) DS [1]                                      #   2, 1 SliceThickness
Zsize=`dcmdump +P "0018,0050" ${file} | cut -d '[' -f2 | cut -d ']' -f1`

#(0028,0030) DS [1\1]                                    #   4, 2 PixelSpacing
val=`dcmdump +P "0028,0030" ${file} | cut -d '[' -f2 | cut -d '\' -f1`
Xsize=`python -c "print (round(${val},2))"`

val=`dcmdump +P "0028,0030" ${file} | cut -d '\' -f2 | cut -d ']' -f1`
Ysize=`python -c "print (round(${val},2))"`

#(0018,0088) DS [1]                                      #   2, 1 SpacingBetweenSlices
SBS=`dcmdump +P "0018,0088" ${file} | cut -d '[' -f2 | cut -d "]" -f1`

#(0018,1310) US 0\256\256\0                              #   8, 4 AcquisitionMatrix
nbX=`dcmdump +P "0018,1310" ${file} | cut -d '\' -f2`
nbY=`dcmdump +P "0018,1310" ${file} | cut -d '\' -f3`

#(0028,0010) US 128                                      #   2, 1 Rows
nbX=`dcmdump +P "0028,0010" ${file} | cut -d ' ' -f3`
##(0028,0011) US 128                                      #   2, 1 Columns
nbY=`dcmdump +P "0028,0011" ${file} | cut -d ' ' -f3`

#(2001,1018) SL 176                                      #   4, 1 NumberOfSlicesMR
nbZ=`dcmdump +P "2001,1018" ${file} | cut -d ' ' -f3`

echo "${PROT} ${TYPE} (voxel size:${Xsize}x${Ysize}x${Zsize} mm3; TR:${TR}ms; TE:${TE}ms; matrix size:${nbX}x${nbY}x${nbZ} voxels; flip angle:${FA}° ; NSA:${NSA} ; Spacing Between Slices:${SBS} )"
