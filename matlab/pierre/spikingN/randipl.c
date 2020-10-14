#include "mex.h"
#include "time.h"

/*declare rand_mt functions*/
void init_genrand(unsigned long s);
double genrand_real2(void);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    static int twist;
    int n, xmax, i, x1, x2, d;
    double *P, *X, r;
    
    /*check input*/
    if(nrhs!=2)
        mexErrMsgTxt("There are two input variables: n and P.");
    if(nlhs>1)
        mexErrMsgTxt("There is one output variable.");
    if( (mxGetNumberOfElements(prhs[0])!=1) )
        mexErrMsgTxt("The first input (n) must be a scalar.");
    if(!mxIsDouble(prhs[1]) || (mxGetN(prhs[1])!=1 && mxGetM(prhs[1])!=1))
        mexErrMsgTxt("The fourth input (P) must be a double-precision vector.");
    
    /*initialize input and output*/
    n = *mxGetPr(prhs[0]);                                  /*number of samples*/
    P = mxGetPr(prhs[1]);                                   /*cumulative distribution function*/
    plhs[0] = mxCreateDoubleMatrix(1,n,mxREAL);             /*initialize output*/
    X = mxGetPr(plhs[0]);
    if(!twist)                                              /*initialize mersenne twister*/
        twist=1, init_genrand(time(NULL));
    
    xmax = mxGetNumberOfElements(prhs[1])-1;                /*bound on xmax imposed by length of P*/
    if(xmax<1 || *(P+xmax)>=1)                            	/*necessities: xmax>=1, P(xmax+1)<1*/
        return;
    
    for(i=0;i<n;i++){
        do
            r=1-genrand_real2();                         	/*get random number r*/
        while(r<=*(P+xmax));                             	/*such that r>P(xmax+1)*/
        
        /*double the search range until r>P(x2+1) or x2>xmax*/
        for(x1=0, x2=1; x2<=xmax && r<=*(P+x2); x1=x2, x2*=2)
            ;
        
        /*binary search*/
        if(x2>xmax)
            x2=xmax;
        do{
            d=(x2-x1)/2;
            if(r<=*(P+x1+d))
                x1+=d;
            else
                x2-=d;
        }while(d>=1);
        
        *(X+i)=x1+1;
    }
}
