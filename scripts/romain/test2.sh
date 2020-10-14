echo $#

index=3
while [ $index -le $# ]
do
	eval arg=\${$index}
	echo $arg
	index=$[$index+1]

done

exit

