#!/usr/bin/env python

"""

Complete json files for topup

Usage:
  FMRI_CompleteJsonFile.py <filepath> <filepath> <filepath> <value> <value> <value> <value> <value> <filepath> 

Arguments:
    <filepath>       : Path to PA file (.json)
    <filepath>       : Path to AP file (.json)
    <filepath>       : Path to FUNC file (.json)
    <value>          : WFS
    <value>          : ETL
    <value>          : Effective echo spacing of func file
    <value>          : Tr in sec
    <value>          : Nb slices of func files
	<filepath>       : Path to func file (func/*.nii.gz)

Written by Renaud LOPES @ CHRU Lille, Sept 2018
Modified by Romain VIARD @ CHRU Lille, Nov 2018
"""

# coding: utf-8

# ====================================================================
#                             LIBRARIES
# ====================================================================

# Import libraries
import sys
import os
import json
import glob
import numpy as np


# ====================================================================
#                              INIT
# ====================================================================

print('')
print('init...')
print('')

print("This is the name of the script: ", sys.argv[0])
print("Number of arguments: ", len(sys.argv))

#print(sys.argv)
argvs = list(sys.argv)
PAjson = argvs[1]
print("PA file: ", PAjson)
APjson = argvs[2]
print("AP file: ", APjson)
FUNCjson = argvs[3]
print("FUNC file: ", FUNCjson)
wfs = float(argvs[4])
print("WFS: ", wfs)
etl = float(argvs[5])
print("ETL: ", etl)
TRsec = float(argvs[6])
print("TRsec: ", TRsec)
Nslices = float(argvs[7])
print("Nb slices: ", Nslices)
funcfile = argvs[8]
print("FMRI file: ", funcfile)

# ====================================================================
#                              PROCESS
# ====================================================================


# total readout time
print('compute total readout time...')
echospacing=(1000*wfs)/(434.215*(etl+1))
trt=echospacing*(etl-1)/1000

# PA
print('import PA data...')

with open(PAjson,'r') as f:
    json_data = f.read()
    f.close()
data = json.loads(json_data)

data['PhaseEncodingDirection']="j"
data['TotalReadoutTime']=trt
data['IntendedFor']=funcfile
with open(PAjson, 'w') as outfile:
    json.dump(data, outfile,sort_keys=True,indent=4,separators=(',', ': '))


# AP
print('import AP data...')

with open(APjson,'r') as f:
    json_data = f.read()
    f.close()
data = json.loads(json_data)

data['PhaseEncodingDirection']="j-"
data['TotalReadoutTime']=trt
#print("Total ReadOut Time")
#funcfile=FUNCjson[FUNCjson.find('func'):]
#funcfile=funcfile.replace('json','nii.gz')
data['IntendedFor']=funcfile
with open(APjson, 'w') as outfile:
    json.dump(data, outfile,sort_keys=True,indent=4,separators=(',', ': '))


# FUNC
print('import FUNC data...')

with open(FUNCjson,'r') as f:
    json_data = f.read()
    f.close()
data = json.loads(json_data)

data['PhaseEncodingDirection']="j"
data['EffectiveEchoSpacing']=echospacing/1000

sliceorder = np.array([]);
space = round(np.sqrt(Nslices));
for k in np.arange(1,space+1):
    tmp=np.arange(k,Nslices+1,space)
    sliceorder=np.concatenate([sliceorder,tmp])
TA = TRsec / Nslices
slicetiming = np.arange(0,2.4,TA)
stc=[]
#ATTENTION ICI le nombre de slice est en dur 40 ...alors que 48 pour Thamamotomy par exemple
for k in np.arange(1,40+1):
    stc.append(round(slicetiming[np.where(sliceorder==k)][0],10))

data['SliceTiming']=list(stc)

with open(FUNCjson, 'w') as outfile:
    json.dump(data, outfile,sort_keys=True,indent=4,separators=(',', ': '))


print('END')

