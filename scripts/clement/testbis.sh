FS_dir=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask
i=1
for subj in 510702MFB_M6 431031JPC_M6 300403PP_M6 691229DB_M6 451229MTK_M6 320428IM_M6 440302HP_M6 660412LM_M6 560525GM_M6 260426RK_M6 450322MD_M6 540412AB_M6 421028RB_M6 311109MR_M6 460321JD_M6 290729JL_M6 480221GR_M6 380919MD_M6 490401AD_M6 851225EM_M6 490105RM_M6 350612JG_M6 600816JLS_M6 460412CT_M6 720501GL_M6 520821EC_M6 531019PL_M6 650328MCG_M6 731001LC_M6 561230PV_M6 490301AC_M6 630418CM_M6 521029PB_M6 380126NB_M6 440718YT_M6 510718CP_M6 460415FM_M6 580714PF_M6 420203JL_M6 600130DC_M6 671019NL_M6 391130GW_M6 481012GT_M6 371218ET_M6 630527GT_M6 810305BB_M6 500921XD_M6 690510ND_M6 500628MW_M6 370921BW_M6 311203RB_M6 680518AH_M6 630618AF_M6 480303JL_M6 360912LD_M6 490508DS_M6 391120GA_M6 571216AT_M6 260410AV_M6 381020LF_M6 511202MS_M6 231029JC_M6 561020LA_M6 370207MJD_M6 581002PR_M6 231023MB_M6 440410FM_M6 500522FM_M6 280515LD_M6 680917AG_M6 510506NP_M6 461106MB_M6 520907MD_M6 321230AL_M6 530512AS_M6 470815CM_M6 610415JD_M6 540416JD_M6 450912BH_M6 600506GH_M6 441111MC_M6 620227JB_M6 500328AR_M6 310109JP_M6 690408PM_M6 330930MD_M6 430109MD_M6 390914CD_M6 391216FD_M6 310317GD_M6 420919CB_M6 620818NC_M6 340303JV_M6 360821GV_M6 380614FS_M6 470101MT_M6 520214ML_M6 690526CR_M6 670213PC_M6 290318AB_M6 640427PV_M6 531122JCD_M6 710509KM_M6 501120PAC_M6 460711ML_M6 400504GD_M6
do


subjid=${subj:0: ( ${#f}-3 ) }
EPI=`ls /NAS/tupac/protocoles/Strokdem/par/${subjid}/${subj}/FE_EPI_64x64_resting/*gz 2> /dev/null`


echo "${EPI}">> /NAS/tupac/protocoles/Strokdem/FMRI/test.txt

done



 
