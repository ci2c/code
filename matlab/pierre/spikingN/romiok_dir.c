#include "mex.h"

/*declare rand_mt functions*/
void init_genrand(unsigned long s);
double genrand_real2(void);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /*declare input*/
    mxLogical *A, *Ih;                                          /*input and output A, inhibitory vector*/
    int *U, *V, n, n1, a, b, c, d;
    long long int kr, k, k1, g, h, i, j;
    static int init_mt;
    if(!init_mt)
        init_mt=1, init_genrand(time(NULL));                    /* initialize Mersenne Twister      */
    
    /*check input*/
    if(nrhs<3)
        mexErrMsgTxt("There are three (four) inputs: A, Ih, kr (n1).");
    if(nlhs>1)
        mexErrMsgTxt("There is only one output: A.");
    if(mxIsSparse(prhs[0]) || !mxIsLogical(prhs[0]) || mxGetM(prhs[0])!=mxGetN(prhs[0]))
        mexErrMsgTxt("A (adjacency matrix) must be full, logical and square.");
    if(mxIsSparse(prhs[1]) || !mxIsLogical(prhs[1]) || mxGetNumberOfElements(prhs[1])!=mxGetN(prhs[0]))
        mexErrMsgTxt("Ih (inhibitory neuron vector) must be full, logical and have length(A).");
    if(!mxIsUint64(prhs[2]) || mxGetNumberOfElements(prhs[2])!=1)
        mexErrMsgTxt("kr (number of edges to randomize) must be a uint64-format scalar.");
    
    /*initialize input and output*/
    plhs[0] = mxDuplicateArray(prhs[0]);
    A  = mxGetLogicals(plhs[0]);                                /* adjacency matrix                 */
    Ih = mxGetLogicals(prhs[1]);                                /* inhibitory neuron vector         */
    n  = mxGetM(prhs[0]);                                       /* number of nodes                  */
    n1 = (nrhs==3)?(n/2):(0.5+*mxGetPr(prhs[3]));               /* module border (n/2 by default)   */
    kr = *(long long int *)mxGetData(prhs[2]);                  /* number of edges to randomize     */
        
    /*count number of edges*/
    for(k=k1=j=0;j<n;j++)
        for(i=0;i<n;i++)
            if(*(A+n*j+i))                                      /* count edges                      */
                if(k++, i<n1 ^ j<n1)                            /* comma operator returns last value */
                    k1++;                                       /* count outer-quadrant edges       */
    
    /*get edge indices*/
    U = (int *)mxMalloc(k*sizeof(int));                         /* initialize edge index arrays     */
    V = (int *)mxMalloc(k*sizeof(int));
    for(h=j=0;j<n;j++)
        for(i=0;i<n;i++)
            if(*(A+n*j+i)){
                *(U+h)=i;                                       /* row indices                      */
                *(V+h)=j;                                       /* column indices                   */
                h++;
                if(i==j)
                    mexErrMsgTxt("A must have an empty diagonal.");
            }
    
    if(kr-k1>-1 && kr-k1<1)                                     /* if number of edges sufficiently close*/
        return;                                                 /* no need to rewire                    */
    if(k1>kr)                                                   /* if number of edges exceeds target    */
        k1=-k1, kr=-kr;                                         /* reverse loop condition               */

    /*loop until sufficient number of outer-quadrant edges*/
    for(g=0; g<5000; g++)
        for(h=0; h<k && k1<kr; h++){
            /*select two random edges*/
            do i=k*genrand_real2();
            while(*(Ih+*(U+i)));                                /* exclude inhibitory sources       */
            do j=k*genrand_real2();
            while(*(Ih+*(U+j)) || i==j);                        /* also exclude first chosen edge   */
            
            /*auxiliary variables*/
            a=*(U+i); b=*(V+i);                                 /* edge i (row *(U+i); col *(V+i))  */
            c=*(U+j); d=*(V+j);                                 /* edge j (row *(U+j); col *(V+j))  */
            
            /*test four conditions; rewire if fulfilled*/
            if(a!=c && a!=d && b!=c && b!=d)                    /* 1. all nodes differ              */
                if(!(*(A+n*d+a) || *(A+n*b+c)))             	/* 2. rewiring condition            */
                    if((a<n1 ^ b<n1)+(c<n1 ^ d<n1)==2*(k1<0)) 	/* 3. both quadrants inner or outer */
                        if((a<n1 ^ c<n1)){                   	/* 4. both quadrants differ         */
                            *(A+n*d+a)=*(A+n*b+c)=1;            /* rewire edges                     */
                            *(A+n*b+a)=*(A+n*d+c)=0;
                            *(V+i)=d;                           /* reassign edge indices            */
                            *(V+j)=b;
                            k1+=2;
                        }
        }
}
