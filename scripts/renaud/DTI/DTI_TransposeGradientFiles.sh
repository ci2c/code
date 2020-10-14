#! /bin/bash
set -e

BVAL=$1
BVEC=$2

echo "bval: ${BVAL}"
echo "bvec: ${BVEC}"
echo ""

OUTBVAL=`echo "$BVAL" | cut -d'.' -f1`
OUTBVAL="${OUTBVAL}"_t.bval

OUTBVEC=`echo "$BVEC" | cut -d'.' -f1`
OUTBVEC="${OUTBVEC}"_t.bvec

echo "out bval: ${OUTBVAL}"
echo "out bvec: ${OUTBVEC}"


matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	x=load('${BVAL}');
	x=x';
	dlmwrite('${OUTBVAL}',x);

	y=load('${BVEC}');
	y=y';
	dlmwrite('${OUTBVEC}',y,'delimiter',' ','precision','%.12f');

EOF
echo ""
