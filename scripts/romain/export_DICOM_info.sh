dcmdump $1 --search "0018,0020" --search "0018,0023" --search "0018,0080" --search "0018,0081" --search "0018,9079" --search "0018,9241" --search "2001,1018" --search "0018,1314" --search "0018,0050" --search "0018,1310" --search "0028,0030" --search "0028,0010" --search "0028,0011" --search "2001,100b" --search "0018,9073" 

echo ""
echo "infos complémentaires"
echo ""

dcmdump $1 --search "0018,0094" --search "0018,1100" --search "0018,0088"
