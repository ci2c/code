import socket
import logging
import sys,re
import mechanize
import time
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import re

myDict = {"romain_viard@yahoo.fr":"xIO52ts0UWm5","renaud.lopes@gmail.com":"CI2C@chu","juliette.mitjans@yahoo.fr":"mdpvolbrain"}
#par defaut '''55''','''Male'''
myList=[{'''58''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01022FZ/M00/NIFTI/3DT1_S002/01022FZ20160323M003DT1_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01020VM/M00/NIFTI/3DT1_S002/01020VM20160120M003DT1_S002.nii.gz'''},
{'''45''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01008GM/M00/NIFTI/3DT1_noCLEAR_GEO_S002/01008GM20141022M003DT1_noCLEAR_GEO_S002.nii.gz'''},
{'''67''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01007HC/M00/NIFTI/3DT1_noCLEAR_GEO_S002/01007HC20140917M003DT1_noCLEAR_GEO_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01004DJ/M00/NIFTI/3DT1_noCLEAR_GEO_S001/01004DJ20140514M003DT1_noCLEAR_GEO_S001.nii.gz'''},
{'''56''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01017TA/M00/NIFTI/3DT1_S002/01017TA20150923M003DT1_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01010VD/M00/NIFTI/3DT1_S003/01010VD20150311M003DT1_S003.nii.gz'''},
{'''54''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/001_031FB/M00/NIFTI/3DT1_S002/01031FB20170118M003DT1_S002.nii.gz'''},
{'''53''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01011BB/M00/NIFTI/3DT1_S002/01011BB20150506M003DT1_S002.nii.gz'''},
{'''53''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01011BB/M00/NIFTI/3DT1_rescan_S002/01011BB20150909M003DT1_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01028SA/M00/NIFTI/3DT1_noCLEAR_GEO_S002/01028SA20160525M003DT1_noCLEAR_GEO_S002.nii.gz'''},
{'''64''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01025AF/M00/NIFTI/3DT1_S002/01025AF20160420M003DT1_S002.nii.gz'''},
{'''50''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01018MT/20151125_103646WIP3DT1ipatSENSEs201a1002.nii.gz'''},
{'''58''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01014DE/M00/NIFTI/3DT1_S002/01014DE20151001M003DT1_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01002TM/M00/NIFTI/3DT1_noCLEAR_GEO_S002/01002TM20140115M003DT1_noCLEAR_GEO_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01005LB/M00/NIFTI/3DT1_noCLEAR_GEO_S002/01005LB20140618M003DT1_noCLEAR_GEO_S002.nii.gz'''},
{'''59''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01023CF/M00/NIFTI/3DT1_S002/01023CF20160330M003DT1_S002.nii.gz'''},
{'''58''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01012BB/M00/NIFTI/3DT1_S002/01012BB20150506M003DT1_S002.nii.gz'''},
{'''66''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/001_030DM/NIFTI/3DT1_S002/01030DM20170104M003DT1_S002.nii.gz'''},
{'''64''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01009WF/M00/NIFTI/3DT1_noCLEAR_GEO_S002/01009WF20141105M003DT1_noCLEAR_GEO_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01013RP/M00/NIFTI/3DT1_S002/01013RP20150520M003DT1_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01029LL/M00/NIFTI/3DT1_S002/01029LL20160706M003DT1_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01021CT/M00/NIFTI/3DT1_S002/01021CT20160203M003DT1_S002.nii.gz'''},
{'''61''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01003SJ/M00/NIFTI/3DT1_noCLEAR_GEO_S002/01003SJ20140304M003DT1_noCLEAR_GEO_S002.nii.gz'''},
{'''53''','''Feale''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01016BP/M00/NIFTI/3DT1_S002/01016BP20150916M003DT1_S002.nii.gz'''},
{'''46''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01019LJ/M00/NIFTI/3DT1_S002/01019LJ20151209M003DT1_S002.nii.gz'''},
{'''53''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01015HC/M00/NIFTI/3DT1_S002/01015HC20150902M003DT1_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01006DF/M00/NIFTI/3DT1_noCLEAR_GEO_S002/01006DF20140827M003DT1_noCLEAR_GEO_S002.nii.gz'''},
{'''59''','''Female''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01024DC/M00/NIFTI/3DT1_S002/01024DC20160406M003DT1_S002.nii.gz'''},
{'''55''','''Male''','''/NAS/tupac/protocoles//NAS/tupac/protocoles/predistim/CATI_data/Lille/convertData/01001SR/M00/NIFTI/3DT1_S002/01001SR20131120M003DT1_S002.nii.gz'''}]


j=1
for cle,valeur in myDict.items() :
    for i in range(10) :
            item=myList[j]
            driver = webdriver.Firefox()
            driver.get("http://volbrain.upv.es/index.php")
            elem = driver.find_element_by_name("email")
            elem.send_keys(cle)
            elem = driver.find_element_by_name("password")
            elem.send_keys(valeur)
            elem = driver.find_element_by_name("sub")
            elem.click()
            elem = driver.find_element_by_id("pipeline1")
            elem.click()
            elem = driver.find_element_by_name("volbrain_patientsage")
            elem.send_keys(item.pop())
            elem = driver.find_element_by_name("volbrain_patientssex")
            elem.send_keys(item.pop())
            elem = driver.find_element_by_name("volbrain_t1_file")
            elem.send_keys(item.pop())
            elem = driver.find_element_by_name("button_volbrain")
            elem.click()
            print j
            if j>=(len(myList)-1) :
                break
            else :
                j=j+1
                time.sleep(5)
