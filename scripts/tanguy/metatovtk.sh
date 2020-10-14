#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  metatovtk.sh -i <META input file> -o <VTK output file> [ -v <value to map>]"
	echo ""
	echo "	-i				: input file (.meta)"
	echo "	-o				: output file (.vtjk)"
	echo "	-v				: vector (.txt)"
	echo ""
	echo "Usage:  metatovtk.sh -i <META input file> -o <VTK output file> [ -v <value to map>]"
	echo ""
	echo ""
	exit 1
fi

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  metatovtk.sh -i <META input file> -o <VTK output file> [ -v <value to map>]"
		echo ""
		echo "	-i				: input file (.meta)"
		echo "	-o				: output file (.vtjk)"
		echo "	-v				: vector (.txt)"
		echo ""
		echo "Usage:  metatovtk.sh -i <META input file> -o <VTK output file> [ -v <value to map>]"
		echo ""
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval meta_file=\${$index}
		echo "META file : ${meta_file}"
		;;
	-o)
		index=$[$index+1]
		eval vtk_file=\${$index}
		echo "VTK file : ${vtk_file}"
		;;
	-v)
		index=$[$index+1]
		eval value=\${$index}
		echo "values to map : ${value}"
		;;

	-*)
		echo ""
		echo "Usage:  metatovtk.sh -i <META input file> -o <VTK output file> [ -v <value to map>]"
		echo ""
		echo "	-i				: input file (.meta)"
		echo "	-o				: output file (.vtjk)"
		echo "	-v				: vector (.txt)"
		echo ""
		echo "Usage:  metatovtk.sh -i <META input file> -o <VTK output file> [ -v <value to map>]"
		echo ""
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

echo "value : <$value>"

filename=${vtk_file%%.vtk*}

matlab -nodisplay <<EOF

meta='$meta_file'
vec = '$value'
outfile='$filename'
vtk_file='$vtk_file'

Meta2Obj(meta,[outfile '.obj']);
S = SurfStatReadSurf([outfile '.obj']);



if exist('vec')
    if size(vec,1)~=0
        disp('size(vec)')
        size(vec)
        vec_value = [];

        fid = fopen(vec);
        disp('ouverture du fichier vec')
        while feof(fid) == 0
            tline = fgetl(fid)
            if ~isempty(str2num(tline(1)))
                vec_value=[vec_value str2num(tline)];
            end
        end
        fclose(fid);
        size(vec_value)
        
        disp('writing vtk file with value')
        save_surface_vtk(S,vtk_file,'ASCII',vec_value)
    else
        disp('writing vtk file without value')
        save_surface_vtk(S,vtk_file)
    end
else
    disp('writing vtk file without value')
    save_surface_vtk(S,vtk_file)
end


EOF













