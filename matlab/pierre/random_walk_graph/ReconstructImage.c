#include "mex.h"
#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[], 
    int nrhs, const mxArray *prhs[])
{
 int Length_in1, Length_in2, i;
 double *RW1, *RW2, *output, *Length_out;
 if (nrhs != 3)
 mexErrMsgTxt("Must have three inputs");
if (nlhs != 1)
 mexErrMsgTxt("Must have one output");

Length_in1 = mxGetN(prhs[0]);
Length_in2 = mxGetN(prhs[1]);

if (Length_in1 != Length_in2)
mexErrMsgTxt("Size of RW sequences must match");

RW1 = mxGetPr(prhs[0]);
RW2 = mxGetPr(prhs[1]);
Length_out = mxGetPr(prhs[2]);

plhs[0] = mxCreateDoubleMatrix((int)Length_out[0], 1, mxREAL);
output = mxGetPr(plhs[0]);

/* Init output table */
for (i = 0; i < Length_out[0]; i++) 
   {
    output[i] = 0.0;
   }

for (i = 0; i < Length_in1; i++) 
   {
    output[(int)RW2[i]-1] += RW1[i];
   }

return;
}

