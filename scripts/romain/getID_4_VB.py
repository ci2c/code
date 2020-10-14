# arg 1 = T1 file path
# arg 2 = age
# arg 3 = sexe ("Female","Male")
# arg 4 = real filename

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options
from selenium.webdriver import Firefox
import os,sys,datetime,random,re

age = sys.argv[2] 
sexe = sys.argv[3] 
os.system(str('cp '+sys.argv[1]+' '+sys.argv[4]))
T1_filename = sys.argv[4] 

ladate=datetime.datetime.today().strftime('%Y-%m-%d')
myDict = {"romain_viard@yahoo.fr":"xIO52ts0UWm5","juliette.mitjans@yahoo.fr":"mdpvolbrain","rhumun@gmail.com":"EYyS9kx1UhWo","renaud.lopes@gmail.com":"Ci2c@chru"}
ladate=datetime.datetime.today().strftime('%Y-%m-%d')

tmp_order=range(len(myDict))
test=random.shuffle(tmp_order)

for eval_order in tmp_order :
    cle = myDict.items()[eval_order][0]
    valeur = myDict.items()[eval_order][1]
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
    cpt=0
    for m in re.finditer(" "+str(ladate)+" ",txt_tab_vol_brain):
        cpt += 1
    if cpt <= 9 :
            elem = driver.find_element_by_id("pipeline1")
            elem.click()
            elem = driver.find_element_by_name("volbrain_t1_file")
            elem.send_keys(T1_filename)
            elem = driver.find_element_by_name("volbrain_patientssex")
            elem.send_keys(sexe)
            elem = driver.find_element_by_name("volbrain_patientsage")
            elem.send_keys(age)
            elem = driver.find_element_by_name("button_volbrain")
            elem.click()
            out_filename=str("/mnt/vout/"+os.path.basename(sys.argv[4])+".txt")
            print out_filename
            outputFile = open(out_filename,'w')
            outputFile.write(str(eval_order));
            outputFile.close()
            break
    else :
        driver.close()
