import glob,os,wget,re,time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options
from selenium.webdriver import Firefox
import os,sys
import numpy as np
import urllib2

myDict = {"romain_viard@yahoo.fr":"xIO52ts0UWm5","juliette.mitjans@yahoo.fr":"mdpvolbrain","rhumun@gmail.com":"EYyS9kx1UhWo","renaud.lopes@gmail.com":"Ci2c@chru","clement.bne@gmail.com":"ci2clille","quentinvannodmichel@gmail.com":"p53q37rst","gregkuch@msn.com":"greg2004","e_nedeva@hotmail.com":"VolbrainMdp"}

item=sys.argv[1]
#inputFile = open(item)
#idNumber = inputFile.readline()
#print(idNumber)
fullFileName = os.path.basename(item)
wanted_file = fullFileName[:-4]
print(wanted_file)


for key, value in myDict.iteritems():
	options = Options()
	options.add_argument("--headless")
	driver = Firefox(firefox_options=options)
	#driver = webdriver.Firefox()
	driver.get("http://volbrain.upv.es/index.php")
	elem = driver.find_element_by_name("email")
	elem.send_keys(key)
	elem = driver.find_element_by_name("password")
	elem.send_keys(value)
	elem = driver.find_element_by_name("sub")
	elem.click()
	elem = driver.find_element_by_name("job_list")
	html_tab_vol_brain=elem.get_attribute('innerHTML')
	txt_tab_vol_brain=elem.text
	for cpt in range(2,9999) :
		print(cpt)
		mytxtIterator = re.search(" "+str(cpt)+" ",txt_tab_vol_brain,re.MULTILINE)
		if mytxtIterator :
			myvar="loadJobList("+str(cpt)+")"
			driver.execute_script(myvar)
			elem = driver.find_element_by_name("job_list")
			html_tab_vol_brain=html_tab_vol_brain+elem.get_attribute('innerHTML')
			txt_tab_vol_brain=txt_tab_vol_brain+elem.text
		else :
			break

	bol = 0
	myIterator = re.finditer("https:\/\/files.volbrain.upv.es\/native.*?zip",html_tab_vol_brain,re.MULTILINE)
	for it in myIterator :
		mystr=html_tab_vol_brain[it.start():it.end()]
		print(mystr)
#		myfile = re.search(".upv.es/(.*nii.gz)",mystr,re.MULTILINE)
		myfile = re.search("native_(.*nii.gz)",mystr,re.MULTILINE)
#		print("comparaison :")
#		print(myfile)
#		print(wanted_file)
		if bol == 1 :
			break
		if myfile.group(1) == wanted_file :
			#print urllib.urlopen(mystr).read()
			print mystr 
			attempts = 0
			while attempts < 3:
				try:
					print(myfile.group(1))					
					response = urllib2.urlopen(mystr, timeout = 5)
					content = response.read()
					f = open( item[:-11]+'''_native.zip''', 'w' )
					f.write( content )
					f.close()
					bol=1
					break
				except urllib2.URLError as e:
					attempts += 1
					print type(e)

	bol = 0
	myIterator = re.finditer("https:\/\/files.volbrain.upv.es\/sub.*?zip",html_tab_vol_brain,re.MULTILINE)
	for it in myIterator :
		mystr=html_tab_vol_brain[it.start():it.end()]
		print(mystr)
		myfile = re.search(".upv.es/(.*nii.gz)",mystr,re.MULTILINE)
#		myfile = re.search("native_(.*nii.gz)",mystr,re.MULTILINE)
#		print("comparaison :")
#		print(myfile)
#		print(wanted_file)
		if bol == 1 :
			break
		if myfile.group(1) == wanted_file :
			#print urllib.urlopen(mystr).read()
			print mystr 
			attempts = 0
			while attempts < 3:
				try:
					print(myfile.group(1))	
					response = urllib2.urlopen(mystr, timeout = 5)
					content = response.read()
					f = open( item[:-11]+'''_mni.zip''', 'w' )
					f.write( content )
					f.close()
					bol=1
					break
				except urllib2.URLError as e:
					attempts += 1
					print type(e)
			os.system(str('mv ' + item + ' ' + item + '.finished'))


	driver.close()
