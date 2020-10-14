#!/bin/bash

data_dir='/NAS/tupac/protocoles/Strokdem/Lesions/72H'

i=0
for f in 231023MB 251214JD 260403JD 260410AV 260426RK 300403PP 310317GD 310501VH 320428IM 321230AL 330930MD 340303JV 350112GC 350612JG 360821GV 370207MJD 371011SG 380614FS 390914CD 420203JL 420919CB 430109MD 430602SD 431119AM 440302HP 440410FM 440718YT 441111MC 450322MD 450906AM 460415FM 470101MT 470815CM 480221GR 490105RM 490401AD 490409YS 510506NP 510702MFB 510807WC 520214ML 520907MD 521029PB 530512AS 540416JD 561020LA 610415JD 620227JB 691229DB

do 
	if [ -e ${data_dir}/${f}_72H/*lesions_mni152.nii.gz ]; then
		if [ $i -eq 0 ]; then
			mris_calc -o tmp.nii ${data_dir}/${f}_72H/*lesions_mni152.nii.gz add 0
		else
			mris_calc -o tmp.nii tmp.nii add ${data_dir}/${f}_72H/*lesions_mni152.nii*
		fi

	((i++))
	fi
done
echo $i
mris_calc -o ${data_dir}/moyenne_lesions72H_TC.nii tmp.nii div $((i-1))
rm -f tmp.nii


i=0
for f in  290729JL 350605MM 380126NB 380919MD 381020LF 390217JF 391216FD 421028RB 450912BH 451229MTK 460121DD 460321JD 460412CT 461106MB 461113JMD 490301AC 491228CD 500328AR 500522FM 510718CP 510915PD 511202MS 520821EC 530816CG 540205BB 540310PE 540412AB 541027GL 550721AL 560525GM 561230PV 600506GH 600816JLS 610612HV 620818NC 650328MCG 671019NL 690408PM 720501GL 731001LC 851225EM


do 
	if [ -e ${data_dir}/${f}_72H/*lesions_mni152.nii.gz ]; then
		if [ $i -eq 0 ]; then
			mris_calc -o tmp.nii ${data_dir}/${f}_72H/*lesions_mni152.nii.gz add 0
		else
		mris_calc -o tmp.nii tmp.nii add ${data_dir}/${f}_72H/*lesions_mni152.nii*
		fi

	((i++))
	fi
done
echo $i
mris_calc -o ${data_dir}/moyenne_lesions72H_NTC.nii tmp.nii div $((i-1))
rm -f tmp.nii

