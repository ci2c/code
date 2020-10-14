#include "mex.h"        /* for mex   */
#include "math.h"       /* for exp   */
#include "stdlib.h"     /* for qsort */

#define PK1(i_,t_) ( exp(-t_ / *(Alph+i_)) )
#define PK2(i_,t_) ( exp(-t_ / *(Beta+i_)) )
#define PU3(i_,t_) ( exp(-t_**(g+i_)*c) )
#define PU2(i_,pu3_,pk2_) ( c**(Beta+i_) * ( pu3_ - pk2_ ) / (*(Beta+i_)**(g+i_)*c-1) )
#define PU1(i_,pu3_,pk1_) ( c**(Alph+i_) * ( pk1_ - pu3_ ) / (*(Alph+i_)**(g+i_)*c-1) )

static int comp_st(const void *p1, const void *p2) {
    double **m1 = (double **)p1;
    double **m2 = (double **)p2;
    if(*(*m1+1) < *(*m2+1))                             /* index 1 is spike time */
        return -1;
    else
        return  1;
}

void snmex(
double *IS, double *K, double *KD, double *St, double *TS, double *U, double *UD, double *Wv,
const double *Alph,      const double *Beta,      const double bin_sze,    const double c,
const mxArray *cell_In,  const mxArray *cell_Out, const mxArray *cell_pIn, const mxArray *cell_pOut,
const double delta_t,    const uint32_T *D,       const double eta_wpos,   const double eta_wneg,
const double *g,         const mxLogical *Ih,     const int max_d,         const int max_ps,
const int mem,           const int n,             const int stdp_rule,     const double t_rfr,
const int t_sim,         const double tau_pos,    const double tau_neg,    const double *Uthr,
const double *Urst,      const double v0,         const double w_max)
{
    int *Ind_s, ps, h, i, j, t_delay, t_delay_i, t_, neg, num_s, ind_s, k_in, k_out, a_h, w_h;
    double **S_it, *U0, *K0, *Pk1, *Pk2, *Pu1, *Pu2, *Pu3;
    double t, t_em, t1,  pk1, pk2, pu1, pu2, pu3, pk1_em, pk2_em, delta_w, k0;
    uint32_T *In, *Out, *pIn, *pOut;
    
    U0    =  (double *)mxMalloc(n*sizeof(double));
    K0    =  (double *)mxMalloc(2*n*sizeof(double));
    Pk1   =  (double *)mxMalloc(n*sizeof(double));
    Pk2   =  (double *)mxMalloc(n*sizeof(double));
    Pu1   =  (double *)mxMalloc(n*sizeof(double));
    Pu2   =  (double *)mxMalloc(n*sizeof(double));
    Pu3   =  (double *)mxMalloc(n*sizeof(double));
    Ind_s =     (int *)mxMalloc(n*sizeof(double));
    S_it  = (double **)mxMalloc(n*sizeof(double *));
    for(i=0; i<n; i++)
        *(S_it+i) = (double *)mxMalloc(2*sizeof(double));
    
    for(i=0; i<n; i++){                                 /* integration constants */
        /* CAREFUL, MACROS: PROTECT ALL INPUTS */
        *(Pk1+i) = PK1(i,delta_t);
        *(Pk2+i) = PK2(i,delta_t);
        *(Pu3+i) = PU3(i,delta_t);
        *(Pu2+i) = PU2(i,*(Pu3+i),*(Pk2+i));
        *(Pu1+i) = PU1(i,*(Pu3+i),*(Pk1+i));
    }
    
    for(ps=0, t=delta_t; t<=t_sim; t+=delta_t){         /* main loop */
        if( !((int)(t-delta_t) % (t_sim/5)) )
            mexPrintf("%d\n", (int)(t-delta_t));
        
        for(i=0; i<n; i++){                             /* copy current states  */
            *(U0  +i) = *(U  +i);
            *(K0  +i) = *(K  +i);
            *(K0+n+i) = *(K+n+i);
        }
        
        for(i=0; i<n; i++){                             /* integrate neurons    */
            *(U  +i) *= *(Pu3+i);
            *(U  +i) += *(Pu1+i)**(K  +i) + *(Pu2+i)**(K+n+i);
            *(K  +i) *= *(Pk1+i);
            *(K+n+i) *= *(Pk2+i);
        }
        
        t_delay  = (int)(0.5 + t/delta_t) % max_d;
        for(i=0; i<n; i++)                              /* add synaptic input   */
            if( *(UD+t_delay*n+i) || *(KD+2*t_delay*n+i) ){
                *(U  +i) += *(UD+  t_delay*n  +i);
                *(K  +i) += *(KD+2*t_delay*n  +i);
                *(K+n+i) += *(KD+2*t_delay*n+n+i);
            }
        
        for(i=0; i<n; i++)
            if(t-*(St+i)-delta_t < t_rfr){              /* refractory neurons   */
                *(U+i) = *(Urst+i);
                if(t-*(St+i) > t_rfr){                  /* emerging neurons     */
                    t_em = *(St+i) + t_rfr + delta_t - t;
                    
                    /* CAREFUL, MACROS: PROTECT ALL INPUTS */
                    pk1_em = PK1(i,t_em)**(K0+i);
                    pk2_em = PK2(i,t_em)**(K0+n+i);
                    
                    t_ = delta_t-t_em;
                    pk1 = PK1(i,t_);
                    pk2 = PK2(i,t_);
                    pu3 = PU3(i,t_);
                    pu2 = PU2(i,pu3,pk2);
                    pu1 = PU1(i,pu3,pk1);
                    
                    *(U+i) *= pu3;
                    *(U+i) += pu1*pk1_em + pu2*pk2_em;
                    *(U+i) += *(UD+n*t_delay+i)*(1-t_em/delta_t);
                }
            }
        
        for(i=0; i<n; i++){                             /* recycle memory       */
            *(UD+  t_delay*n  +i) = 0;
            *(KD+2*t_delay*n  +i) = 0;
            *(KD+2*t_delay*n+n+i) = 0;
        }
        
        for(num_s=i=0; i<n; i++)                        /* check spiked neurons */
            if(*(U+i)>*(Uthr+i))
                *(Ind_s+num_s++)=i;
        
        if(num_s){                                      /* process spikes       */
            for(i=0; i<num_s; i++){                     /* sort spikes          */
                ind_s = *(Ind_s+i);
                *(*(S_it+i)+0) = (double)ind_s;
                *(*(S_it+i)+1) = t - delta_t*(*(U+ind_s) - *(Uthr+ind_s))/(*(U+ind_s) - *(U0+ind_s));
            }
            
            qsort(S_it, num_s, sizeof(double *), comp_st);
            
            for(j=0; j<num_s; j++){
                i = 0.5 + *(*(S_it+j)+0);
                *(St+i) = *(*(S_it+j)+1);
                
                In   = (uint32_T *)mxGetData(mxGetCell(cell_In,i));
                Out  = (uint32_T *)mxGetData(mxGetCell(cell_Out,i));
                pIn  = (uint32_T *)mxGetData(mxGetCell(cell_pIn,i));
                pOut = (uint32_T *)mxGetData(mxGetCell(cell_pOut,i));
                
                k_in  = mxGetNumberOfElements(mxGetCell(cell_In,i));
                k_out = mxGetNumberOfElements(mxGetCell(cell_Out,i));
                
                for(h=0; h<k_in; h++){                  /* STDP in  */
                    a_h = *(In+h);
                    w_h = *(pIn+h);
                    delta_w = eta_wpos * exp(-(*(St+i)-*(St+a_h))/tau_pos);
                    switch(stdp_rule){
                        case 2:
                            *(Wv+w_h) += delta_w*(1-*(Wv+w_h)/w_max);
                            break;
                        case 1:
                            *(Wv+w_h) += delta_w;
                            if(*(Wv+w_h)>w_max)
                                *(Wv+w_h)=w_max;
                            break;
                            default:
                                mexErrMsgTxt("STDP rule is not recognized.");
                    }
                }
                
                for(h=0; h<k_out; h++){                 /* STDP out */
                    a_h = *(Out+h);
                    w_h = *(pOut+h);
                    delta_w = eta_wneg * exp(-(*(St+i)-*(St+a_h))/tau_neg);
                    switch(stdp_rule){
                        case 2:
                            *(Wv+w_h) -= delta_w*(*(Wv+w_h)/w_max); break;
                        case 1:
                            *(Wv+w_h) -= delta_w;
                            if(*(Wv+w_h)<0)
                                *(Wv+w_h)=0;
                            break;
                            default:
                                mexErrMsgTxt("STDP rule is not recognized.");
                    }
                }
                
                /* CAREFUL, MACROS: PROTECT ALL INPUTS */
                t1 = t - *(St+i);
                pk1 = PK1(i,t1);
                pk2 = PK2(i,t1);
                pu3 = PU3(i,t1);
                pu2 = PU2(i,pu3,pk2);
                pu1 = PU1(i,pu3,pk1);
                
                t_delay_i = (t_delay+(int)*(D+i))%(max_d);
                neg = *(Ih+i) ? -1:1;
                
                for(h=0; h<k_out; h++){                 /* input to other neurons */
                    a_h = *(Out+h);
                    w_h = *(pOut+h);
                    k0 = neg*v0**(Wv+w_h);
                    
                    *(UD +   t_delay_i*n+  a_h) += (pu1+pu2)*k0;
                    *(KD + 2*t_delay_i*n+  a_h) +=  pk1*k0;
                    *(KD + 2*t_delay_i*n+n+a_h) +=  pk2*k0;
                }
                
                *(IS+ps) = i+1;
                *(TS+ps) = t/bin_sze;
                if(++ps >= max_ps)
                    mexErrMsgTxt("Out of spike memory.\n");
            }
        }
    }
    
    mxFree(U0);  mxFree(K0);  mxFree(Pk1); mxFree(Pk2);
    mxFree(Pu1); mxFree(Pu2); mxFree(Pu3); mxFree(Ind_s);
    for(i=0; i<n; i++)
        mxFree(*(S_it+i));
    mxFree(S_it);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray *mxU, *mxK, *mxUD, *mxKD, *mxSt, *mxWv, *mxIS, *mxTS;
    double    *U,   *K,   *UD,   *KD,   *St,   *Wv,   *IS,   *TS;
    
    const mxArray *pn, *cell_In, *cell_Out, *cell_pIn, *cell_pOut;
    const double *g, *Alph, *Beta, *Uthr, *Urst;
    const mxLogical *Ih;
    const uint32_T *D;
    
    double delta_t, bin_sze, c, t_rfr, v0, tau_pos, tau_neg, eta_wpos, eta_wneg, w_max;
    int n, t_sim, stdp_rule, max_d, mem, i, max_ps;
    
    pn = mexGetVariablePtr("caller","n");
    
    if(nrhs || nlhs)
        mexErrMsgTxt("There are no inputs or outputs.");
    for(i=0; i<mxGetNumberOfFields(pn)-1; i++)
        if(mxIsEmpty(mxGetFieldByNumber(pn,0,i)))
            mexErrMsgTxt("All fields must be nonempty.");
        else if(i>0 && i<5 && !mxIsCell(mxGetFieldByNumber(pn,0,i)))
            mexErrMsgTxt("Cells must be cells.");
        else if(i==5 && !mxIsLogical(mxGetFieldByNumber(pn,0,i)))
            mexErrMsgTxt("Logicals must be logical.");
        else if(i>5 && !mxIsDouble(mxGetFieldByNumber(pn,0,i)))
            mexErrMsgTxt("Doubles must be double.");
    if(!i)
        mexErrMsgTxt("Structure must be a structure.");
    
    cell_In   =  mxGetField(pn,0,"In");
    cell_Out  =  mxGetField(pn,0,"Out");
    cell_pIn  =  mxGetField(pn,0,"pIn");
    cell_pOut =  mxGetField(pn,0,"pOut");
    
    g         =  mxGetPr(mxGetField(pn,0,"g"));
    Alph      =  mxGetPr(mxGetField(pn,0,"alpha"));
    Beta      =  mxGetPr(mxGetField(pn,0,"beta"));
    Ih        = (mxLogical*)mxGetData(mxGetField(pn,0,"ih"));
    Uthr      =  mxGetPr(mexGetVariablePtr("caller","Uthr"));
    Urst      =  mxGetPr(mexGetVariablePtr("caller","Urest"));
    D         = (uint32_T *)mxGetData(mexGetVariablePtr("caller","D"));
    
    n         = 0.5 + *mxGetPr(mxGetField(pn,0,"N"));
    t_sim     = 0.5 + *mxGetPr(mxGetField(pn,0,"T"));
    delta_t   = *mxGetPr(mxGetField(pn,0,"delta_t"));
    bin_sze   = *mxGetPr(mxGetField(pn,0,"bin_size"));
    c         = *mxGetPr(mxGetField(pn,0,"c"));
    t_rfr     = *mxGetPr(mxGetField(pn,0,"Trefr"));
    v0        = *mxGetPr(mxGetField(pn,0,"V0"));
    
    max_d     = 0.5 + *mxGetPr(mexGetVariablePtr("caller","max_D"));
    stdp_rule = 0.5 + *mxGetPr(mxGetField(pn,0,"stdp_rule"));
    eta_wpos  = *mxGetPr(mxGetField(pn,0,"Eta"))**mxGetPr(mxGetField(pn,0,"w_pos"));
    eta_wneg  = *mxGetPr(mxGetField(pn,0,"Eta"))**mxGetPr(mxGetField(pn,0,"w_neg"));
    w_max     = *mxGetPr(mxGetField(pn,0,"w_max"));
    tau_pos   = *mxGetPr(mxGetField(pn,0,"tau_pos"));
    tau_neg   = *mxGetPr(mxGetField(pn,0,"tau_neg"));
    
    mem  = 0.5 + *mxGetPr(mexGetVariablePtr("caller","memory"));
    mxU  =  mexGetVariable("caller","U");
    mxK  =  mexGetVariable("caller","K");
    mxUD =  mexGetVariable("caller","UD");
    mxKD =  mexGetVariable("caller","KD");
    mxSt =  mexGetVariable("caller","St");
    mxWv =  mexGetVariable("caller","Wv");
    mxIS =  mexGetVariable("caller","IS");
    mxTS =  mexGetVariable("caller","TS");
    max_ps = mxGetNumberOfElements(mxIS);
    
    U = mxGetPr(mxU);
    K = mxGetPr(mxK);
    UD = mxGetPr(mxUD);
    KD = mxGetPr(mxKD);
    St = mxGetPr(mxSt);
    Wv = mxGetPr(mxWv);
    IS = mxGetPr(mxIS);
    TS = mxGetPr(mxTS);
    
    snmex(IS,   K,      KD,     St,     TS,     U,      UD,     Wv,
    Alph,       Beta,       bin_sze,    c,          cell_In,    cell_Out,
    cell_pIn,   cell_pOut,  delta_t,    D,          eta_wpos,   eta_wneg,
    g,          Ih,         max_d,      max_ps,     mem,        n,
    stdp_rule,  t_rfr,      t_sim,      tau_pos,    tau_neg,    Uthr,
    Urst,       v0,         w_max);
    
    mexPutVariable("caller","U", mxU );
    mexPutVariable("caller","K", mxK );
    mexPutVariable("caller","UD",mxUD);
    mexPutVariable("caller","KD",mxKD);
    mexPutVariable("caller","St",mxSt);
    mexPutVariable("caller","Wv",mxWv);
    mexPutVariable("caller","IS",mxIS);
    mexPutVariable("caller","TS",mxTS);
}
