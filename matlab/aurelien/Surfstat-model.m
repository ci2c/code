filenames=SurfStatListDir('/home/aurelien/ASL/CPT/yann/surfstat/');
[ Y0, vol0 ] = SurfStatReadVol( filenames );
control=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
size(control)
[ wmav, volwmav ] = SurfStatAvVol( filenames );
clf; SurfStatView1( wmav, volwmav );
SurfStatView1( wmav, volwmav, 'datathresh', 500 );
[ Y, vol ] = SurfStatReadVol( filenames, wmav > 500 );
Group = term( var2fac( control, { 'repos'; 'cpt' } ) );
slm = SurfStatLinMod( Y, Group, vol );
slm = SurfStatT( slm, Group.repos - Group.cpt );
clf; SurfStatView1( slm.t, vol );
clf; SurfStatView1( SurfStatP( slm ), vol );
clf; SurfStatView1( slm.ef, vol );
clf; SurfStatView1( slm.sd, vol );
PP = SurfStatP( slm );
clf; SurfStatView1( PP, vol );