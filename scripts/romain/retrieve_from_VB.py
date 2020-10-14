import glob,os,wget,re,time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options
from selenium.webdriver import Firefox

myDict = {"romain_viard@yahoo.fr":"xIO52ts0UWm5","juliette.mitjans@yahoo.fr":"mdpvolbrain","rhumun@gmail.com":"EYyS9kx1UhWo","renaud.lopes@gmail.com":"Ci2c@chru"}

while True :
	Fileliste = glob.glob("/mnt/vout/*.nii.gz.txt")
	Fileliste.sort(key=os.path.getmtime)

	if len(Fileliste) < 1:
		break
		
	print "Nombre de fichiers dans le repertoire :"
	print len(Fileliste)
	print("\n".join(Fileliste))

	for item in Fileliste :
		inputFile = open(item)
		idNumber = inputFile.readline()
		fullFileName = os.path.basename(item)
		wanted_file = fullFileName[:-4]
		cle = myDict.items()[int(idNumber)][0]
		valeur = myDict.items()[int(idNumber)][1]
		options = Options()
		options.add_argument("--headless")
		driver = Firefox(firefox_options=options)
		#driver = webdriver.Firefox()                
		driver.get("http://volbrain.upv.es/index.php")
		elem = driver.find_element_by_name("email")
		elem.send_keys(cle)
		elem = driver.find_element_by_name("password")
		elem.send_keys(valeur)
		elem = driver.find_element_by_name("sub")
		elem.click()
		elem = driver.find_element_by_name("job_list")
		html_tab_vol_brain=elem.get_attribute('innerHTML')
		txt_tab_vol_brain=elem.text
		for cpt in range(2,9999) :
			mytxtIterator = re.search(" "+str(cpt)+" ",txt_tab_vol_brain,re.MULTILINE)
			if mytxtIterator :
				myvar="loadJobList("+str(cpt)+")"
				driver.execute_script(myvar)
				elem = driver.find_element_by_name("job_list")
				html_tab_vol_brain=html_tab_vol_brain+elem.get_attribute('innerHTML')
				txt_tab_vol_brain=txt_tab_vol_brain+elem.text
			else :
				break
		myIterator = re.finditer("http:\/\/files.volbrain.upv.es\/native.*?zip",html_tab_vol_brain,re.MULTILINE)
		for it in myIterator :
			mystr=html_tab_vol_brain[it.start():it.end()]
			myfile = re.search("native_(.*nii.gz)",mystr,re.MULTILINE)
			if myfile.group(1) == wanted_file :
				#print urllib.urlopen(mystr).read()
				print mystr 
				wget.download(mystr,out="/mnt/vout/")
				os.system(str('mv ' + item + ' ' + item + '.finished'))
		driver.close()
	time.sleep( 900 )
