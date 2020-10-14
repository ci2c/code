#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int32_T *X;                                   	/*input*/
    double *C, *F, *xlim;                           /*output*/
    int i, n, xmin, xmax, d;
    
    /*check input*/
    if(nrhs!=1)
        mexErrMsgTxt("There is one input variable.");
    if(nlhs>3)
        mexErrMsgTxt("There are three output variables.");
    if(!mxIsInt32(prhs[0]) || (mxGetN(prhs[0])!=1 && mxGetM(prhs[0])!=1))
        mexErrMsgTxt("X must be an int32 vector.");
    
    /*initialize input*/
    X = (int32_T *) mxGetData(prhs[0]);           	/*get elements*/
    n = mxGetNumberOfElements(prhs[0]);             /*number of elements*/
    
    /*get xmin and xmax*/
    for(i=1, xmin=xmax=*X; i<n; i++){
        if(*(X+i)>xmax)
            xmax=*(X+i);
        if(*(X+i)<xmin)
            xmin=*(X+i);
    }
    d=xmax-xmin;
    
    /*inialize output*/
    plhs[0] = mxCreateDoubleMatrix(1,d+1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1,d+1,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(1,2,mxREAL);
    F = mxGetPr(plhs[0]);                           /*frequency distribution*/
    C = mxGetPr(plhs[1]);                           /*cumulative frequency distribution*/
    xlim = mxGetPr(plhs[2]);                        /*[xmin xmax]*/
    
    /*get frequency distribution*/
    for(i=0;i<n;i++)
        *(F+*(X+i)-xmin)+=1;
    
    /*get cumulative frequency distribution*/
    *(C+d)=*(F+d);
    for(i=d-1;i>=0;i--)
        *(C+i)=*(C+i+1)+*(F+i);
    
    /*get xlim*/
    *(xlim+0)=xmin;
    *(xlim+1)=xmax;
}
