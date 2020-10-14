surf=SurfStatReadSurf({['/home/fatmike/Protocoles_3T/Strokdem/test/test_reg/Mask/421028RB_M36/surf/lh.pial'],['/home/fatmike/Protocoles_3T/Strokdem/test/test_reg/Mask/421028RB_M36/surf/rh.pial']});

Y_M36=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/test/test_reg/Mask/421028RB_M36/surf/lh.thickness'],['/home/fatmike/Protocoles_3T/Strokdem/test/test_reg/Mask/421028RB_M36/surf/rh.thickness']} );

figure, SurfStatView(Y_M36, surf);