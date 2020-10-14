#!/bin/bash

dir=$1

for i in `ls -d1 $dir/*8c --hide=fsaverage --hide=lh.EC_average --hide=rh.EC_average --hide=surfstat`
do
name=`basename $i`
cp $i/asl/rh.fsaverage.asl.mgh $dir/surfstat/${name}_rh_fsaverage_asl.mgh
cp $i/asl/lh.fsaverage.asl.mgh $dir/surfstat/${name}_lh_fsaverage_asl.mgh
done

for i in `ls -d1 $dir/*32c --hide=fsaverage --hide=lh.EC_average --hide=rh.EC_average --hide=surfstat`
do
name=`basename $i`
cp $i/asl/rh.fsaverage.asl.mgh $dir/surfstat/${name}_rh_fsaverage_asl.mgh
cp $i/asl/lh.fsaverage.asl.mgh $dir/surfstat/${name}_lh_fsaverage_asl.mgh
done


