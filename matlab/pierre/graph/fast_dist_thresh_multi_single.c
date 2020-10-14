#include "mex.h"
#include "math.h"
#include <malloc.h>
#include <time.h>
#include "stdio.h"
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

#define TRUE 1
#define FALSE 0
#define NUM_THREADS 4
pthread_mutex_t mutexsum;

typedef struct
{
    float *coord;
    float *center;
    float *radius;
    double *isinsph;
    int    nel;
    float *id;
    int    N;
} DATA;

DATA th;

void *get_dist(void *t)
{
    int i, last_id, index;
    long tid;
    float R, Dist;
    
    tid = (long)t;
    R = th.radius[0] * th.radius[0];
    index = 0;
    last_id = (int)th.id[index];
    
    /*pthread_mutex_lock(&mutexsum);*/
    
    for (i=(int)tid; i<th.nel; i+=NUM_THREADS)
    {
        if (last_id != (int)th.id[i]) {
            last_id = (int)th.id[i];
            index++;
        }
        
        if (th.isinsph[index] == 0.0) {
            Dist = (th.coord[i] - th.center[0])*(th.coord[i] - th.center[0]) + (th.coord[i+th.nel] - th.center[1])*(th.coord[i+th.nel] - th.center[1]) + (th.coord[i+2*th.nel] - th.center[2])*(th.coord[i+2*th.nel] - th.center[2]);
            if (Dist <= R) {
                th.isinsph[index] = 1.0;
            }
        }
    }
    
    /*pthread_mutex_unlock (&mutexsum);*/
    pthread_exit((void*) t);
}



void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    int nx, ny, rc;
    long t;
    void *status;
    float *s_center, *fib_coord, *s_radius, *ids, *nr_tracts;
    double *isin_sph;
    pthread_t thread[NUM_THREADS];
    pthread_attr_t attr;
    
    if (nrhs != 5)
    mexErrMsgTxt("Must have five inputs");
    if (nlhs != 1)
    mexErrMsgTxt("Must have one output");
    
    nx = mxGetM(prhs[0]);
    ny = mxGetN(prhs[0]);
    
    fib_coord = (float *)(mxGetPr(prhs[0]));
    s_center  = (float *)(mxGetPr(prhs[1]));
    s_radius  = (float *)(mxGetPr(prhs[2]));
    ids       = (float *)(mxGetPr(prhs[3]));
    nr_tracts = (float *)(mxGetPr(prhs[4]));
    
    plhs[0] = mxCreateDoubleMatrix((mwSize)1, (mwSize)(int)nr_tracts[0], mxREAL); 
    isin_sph = mxGetPr(plhs[0]);
    
    th.coord   = fib_coord;
    th.center  = s_center;
    th.radius  = s_radius;
    th.isinsph = isin_sph;
    th.nel     = nx;
    th.id      = ids;
    th.N       = (int)nr_tracts[0];
    
    pthread_mutex_init(&mutexsum, NULL);
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    
    /* start threads */
    for (t=0; t<NUM_THREADS; t++) {
        rc = pthread_create( &thread[t], &attr, get_dist, (void *)t);
        if (rc) {
            printf("ERROR; return code from pthread_create() is %d\n", rc);
            exit(-1);
        }
    }
    
    pthread_attr_destroy(&attr);
    
    /* join threads */
    for (t=0; t<NUM_THREADS; t++) {
        rc = pthread_join(thread[t], &status);
        if (rc) {
            printf("ERROR; return code from pthread_join() is %d\n", rc);
            exit(-1);
        }
    }
    
    pthread_mutex_destroy(&mutexsum);
    /*pthread_exit(NULL);*/
}


