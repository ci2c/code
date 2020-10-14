#include "mex.h"
#include <math.h>
#include <malloc.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int nx, ny, i, last_id, index;
    double Dist, R;
    double *s_center, *fib_coord, *s_radius, *isin_sph, *ids, *nr_tracts;

    if (nrhs != 5)
    mexErrMsgTxt("Must have five inputs");
    if (nlhs != 1)
    mexErrMsgTxt("Must have one output");

    nx = mxGetM(prhs[0]);
    ny = mxGetN(prhs[0]);

    fib_coord = mxGetPr(prhs[0]);
    s_center  = mxGetPr(prhs[1]);
    s_radius  = mxGetPr(prhs[2]);
    ids       = mxGetPr(prhs[3]);
    nr_tracts = mxGetPr(prhs[4]);
    
    R = s_radius[0] * s_radius[0];

    plhs[0] = mxCreateDoubleMatrix( (mwSize)1, (mwSize)(int)nr_tracts[0], mxREAL);
    isin_sph = mxGetPr(plhs[0]);
    
    last_id = (int)ids[0];
    index = 0;

    for (i=0; i < nx; i++) {
        
        if (last_id != (int)ids[i]) {
            last_id = (int)ids[i];
            index++;
        }
        
        if (isin_sph[index] > 0.0) {
            continue;
        } else {
            Dist = (fib_coord[i] - s_center[0])*(fib_coord[i] - s_center[0]) + (fib_coord[i+nx] - s_center[1])*(fib_coord[i+nx] - s_center[1]) + (fib_coord[i+2*nx] - s_center[2])*(fib_coord[i+2*nx] - s_center[2]);
            if (Dist <= R) {
                isin_sph[index] = 1.0;
            }
        }
    }
    
    return;

}
