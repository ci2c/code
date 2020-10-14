sd=$1
echo $sd

thr=0.9

cd $sd

for im in `ls $sd`
do
echo "mean_FA_ictus('$sd','$im','$thr')"

matlab -nodisplay <<EOF
mean_FA_ictus('$sd','$im','$thr')
EOF

done



