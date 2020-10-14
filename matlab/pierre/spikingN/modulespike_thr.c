#include "mex.h"
#include "time.h"                                           /*to initialize rand_mt*/
#include "string.h"                                         /*for memset*/

/*declare rand_mt and computational function*/
void init_genrand(unsigned long s);
double genrand_real2(void);
void modulespike_thr(double *thr, const int n, const int t, const double *Sn, const int reps, const int ind);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int n, t, reps, ind;
    double *Sn, *thr, p;
    static int mt_state;
    
    /*check input*/
    if(nrhs<4)
        mexErrMsgTxt("There are at least four inputs: n, t, Sn, reps, p.");
    if(nlhs>1)
        mexErrMsgTxt("There is one output variable: thr.");
    if((mxGetNumberOfElements(prhs[0])!=1) || (mxGetNumberOfElements(prhs[1])!=1)
    || (mxGetNumberOfElements(prhs[3])!=1))
        mexErrMsgTxt("The first, second and fourth inputs, n, t and reps, must be scalars.");
    if(!mxIsDouble(prhs[2]) || (mxGetNumberOfElements(prhs[2])!=*mxGetPr(prhs[0])))
        mexErrMsgTxt("The third input Sn must be a double-precision vector of length n.");
    
    /*initialize input*/
    n = *mxGetPr(prhs[0]);                                  /*number of neurons*/
    t = *mxGetPr(prhs[1]);                                  /*simulation time*/
    Sn = mxGetPr(prhs[2]);                                  /*number of spikes per neuron*/
    reps = *mxGetPr(prhs[3]);                               /*number of repetitions*/    
    p = (nrhs==4)?(0.95):(*mxGetPr(prhs[4]));
    ind = p*t+0.5;                                          /*threshold index*/
    
    /*initialize output*/
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);             /*module spike threshold*/
    thr = mxGetPr(plhs[0]);
    
    /*initialize mersenne twister*/
    if(!mt_state)
        mt_state=1, init_genrand(time(NULL));
    
    modulespike_thr(thr, n, t, Sn, reps, ind);
}

void modulespike_thr(double *thr, const int n, const int t, const double *Sn, const int reps, const int ind)
{
    int *N1, *St, *Fn;
    int h, i, j, x;
    
    N1 = (int*) mxMalloc(n*t*sizeof(int));                  /*shuffled matrix*/
    St = (int*) mxMalloc(t*sizeof(int));                    /*number of spikes at a given time*/
    Fn = (int*) mxMalloc((n+1)*sizeof(int));                /*frequency of spike number at a given time*/
    
    for(h=0; h<reps; h++){
        memset(N1,0,n*t*sizeof(int));
        memset(St,0,t*sizeof(int));
        memset(Fn,0,(n+1)*sizeof(int));
        
        /*shuffle matrix, get number of spikes at each timepoint*/
        for(i=0; i<n; i++)
            for(j=0; j<*(Sn+i); j++){
                do x=t*genrand_real2();                     /*get random integer x (0<=x<=t)*/
                while(*(N1+i*t+x));                         /*such N1(i,x) is empty*/
                *(N1+i*t+x)=1;
                *(St+x)+=1;
            }
        
        /*get histogram for number of spikes at each timepoint*/
        for(i=0;i<t;i++)
            *(Fn+*(St+i))+=1;
        
        /*get value of threshold*/
        i=-1, j=0;
        do j+=*(Fn+(++i));
        while(j<ind);
        *thr+=i;
    }
    *thr/=reps;
    
    mxFree(N1);
    mxFree(St);
    mxFree(Fn);
}
