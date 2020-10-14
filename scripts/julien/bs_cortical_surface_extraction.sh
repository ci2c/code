./bse -i /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/20120912_1652243DT1s301a1003.nii.gz -o /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/skull_stripped_mri.nii.gz --trim --mask /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/mask_mri.nii.gz

./skullfinder -i /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/20120912_1652243DT1s301a1003.nii.gz -o /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/subj.skull.label.nii.gz -m /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/mask_mri.nii.gz

./bfc -i /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/skull_stripped_mri.nii.gz -o /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/output_mri.bfc.nii.gz -L 0.5 -U 1.5


./pvc -i /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/output_mri.bfc.nii.gz -o /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/mri.pvc.label.nii.gz -f /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/mri.frac.nii.gz

./cerebro -i /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/skull_stripped_mri.nii.gz  --atlas /home/global/BrainSuite15c/atlas/brainsuite.icbm452.lpi.v08a.img --atlaslabels /home/global/BrainSuite15c/atlas/brainsuite.icbm452.v15a.label.img -o /NAS/tupac/protocoles/hydrocephalie/temp/Dumont_Andre__Mr_20140701/cerebrum_mask.nii.gz

