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
#define SPARSITY 0.0001
pthread_mutex_t mutexsum;

#define SMALL_NUM   0.0000000001f
#define dot(u,v)   ((u).x * (v).x + (u).y * (v).y + (u).z * (v).z)
#define norm(u)    ((float)sqrt( (u).x * (u).x + (u).y * (u).y + (u).z * (u).z));

int index;

typedef struct
{
    float     *p_coord;
    int        n_points;
    int       *triangle;
    float     *f_coord;
    int        nf_points;
    int       *id;
    int        N;
    float     *angle_x;
    float     *angle_y;
    float     *angle_z;
    int       *i_index;
    int       *j_index;
    int        ntri;
} DATA;

typedef struct
{
    float x;
    float y;
    float z;
} Vector;

DATA th;

/* Return vector AB from points A and B */
Vector p_diff(Vector A, Vector B)
{
    Vector C;
    C.x = B.x - A.x;
    C.y = B.y - A.y;
    C.z = B.z - A.z;
    
    return C;
}

/* Function for vectorial product */
Vector vec_prod(Vector A, Vector B)
{
    Vector C;
    C.x = A.y * B.z - A.z * B.y;
    C.y = A.z * B.x - A.x * B.z; 
    C.z = A.x * B.y - A.y * B.x;
    
    return C;
}

/* Compute intersection between 1 triangle and all fibers */
void get_intersect(int tri_id)
{
    int i, current_id, next_id, fiber_index, cross_flag, i_temp;
    long tid;
    float R, Dist, w, s, t, u, v, tt, N1, N2, N3, det, t_param, inv_det;
    Vector V1, V2, V3, Q1, Q2, A, B, C, W1, W2, D, Q12, Center, T, E1, E2;
    
    tid = (long)t;
    
    V1.x = th.p_coord[ (th.triangle[tri_id] - 1) * 3];
    V1.y = th.p_coord[ (th.triangle[tri_id] - 1) * 3 + 1];
    V1.z = th.p_coord[ (th.triangle[tri_id] - 1) * 3 + 2];
    
    V2.x = th.p_coord[ (th.triangle[tri_id + th.ntri] - 1) * 3];
    V2.y = th.p_coord[ (th.triangle[tri_id + th.ntri] - 1) * 3 + 1];
    V2.z = th.p_coord[ (th.triangle[tri_id + th.ntri] - 1) * 3 + 2];
    
    V3.x = th.p_coord[ (th.triangle[tri_id + 2*th.ntri] - 1) * 3];
    V3.y = th.p_coord[ (th.triangle[tri_id + 2*th.ntri] - 1) * 3 + 1];
    V3.z = th.p_coord[ (th.triangle[tri_id + 2*th.ntri] - 1) * 3 + 2];
    
    Center.x = (V1.x + V2.x + V3.x) / 3.0f;
    Center.y = (V1.y + V2.y + V3.y) / 3.0f;
    Center.z = (V1.z + V2.z + V3.z) / 3.0f;
    
    E1 = p_diff(V1,V2);
    E2 = p_diff(V1,V3);
    B  = p_diff(V3,V1);
    C  = p_diff(V3,V2);
    W1 = vec_prod(B,C);
    N2  = norm(W1);
    
    fiber_index = 0;
    cross_flag  = 0;
    for (i = 0; i < th.nf_points - 1; i++)
    {
        /* Get fiber IDS of the segment */
        current_id = th.id[i];
        next_id    = th.id[i+1];
        
        if ( (current_id != next_id) ) {
            fiber_index++;
            cross_flag = 0;
            continue;
        }
            
        if (cross_flag) continue;

        Q1.x = th.f_coord[i];
        Q1.y = th.f_coord[i + th.nf_points];
        Q1.z = th.f_coord[i + 2*th.nf_points];

        Q2.x = th.f_coord[i + 1];
        Q2.y = th.f_coord[i + 1 + th.nf_points];
        Q2.z = th.f_coord[i + 1 + 2*th.nf_points];

        if ( ( (Center.x - Q1.x) * (Center.x - Q1.x) + (Center.y - Q1.y) * (Center.y - Q1.y) + (Center.z - Q1.z) * (Center.z - Q1.z) ) > 0.3f) continue;

        /* Below is an implementation of */
        /* Moller's algorithm */
        D  = p_diff(Q1,Q2);
        A  = vec_prod(D,E2);
        det = dot(A,E1);

        if (det > SMALL_NUM) {
            T = p_diff(V1,Q1);
            u = dot(A,T);
            if (u < 0.0f || u > det) continue;
            B = vec_prod(T,E1);
            v = dot(B,D);
            if (v < 0.0f || u+v > det) continue;
        } else if (det < -SMALL_NUM) {
            T = p_diff(V1,Q1);
            u = dot(A,T);
            if (u > 0.0f || u < det) continue;
            B = vec_prod(T,E1);
            v = dot(B,D);
            if (v > 0.0f || u+v < det) continue;
        } else continue;
        inv_det = 1.0f / det;
        t_param = dot(B,E2) * inv_det;
        if (t_param < 0.0f || t_param > 1.0f) continue;

        
        /* In this case only the segment intersects the triangle */
        /* Store the contact angle at the right matrix place */
        N1  = dot(W1,D);
        N3  = norm(D);

        i_temp = index++;
        th.angle_x[i_temp] = D.x;
        th.angle_y[i_temp] = D.y;
        th.angle_z[i_temp] = D.z;
        th.i_index[i_temp] = fiber_index;
        th.j_index[i_temp] = tri_id;
        cross_flag = 1;
    }
}



/* Loop on triangles using NUM_THREADS threads */
void *loop_triangles(void *t)
{
    int i;
    long tid;
    
    tid = (long)t;
    for (i = (int)tid; i < th.ntri; i+=NUM_THREADS)
    {
        get_intersect(i);
    }
    
    pthread_exit((void*) t);
}


/* Main function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    int i, j, k, n_points, nf_points, nzmax, ntri, *triangle, *ids, *nr_tracts, rc, *i_index, *j_index;
    long t;
    void *status;
    float *p_coord, *f_coord, *angle_x, *angle_y, *angle_z;
    double *sr, *si, *i_out, *j_out, *ax_out, *ay_out, *az_out;
    mwIndex *irs, *jcs;
    
    index = 0;
    
    pthread_t thread[NUM_THREADS];
    pthread_attr_t attr;
    
    if (nrhs != 5)
    mexErrMsgTxt("Must have five inputs");
    if (nlhs != 5)
    mexErrMsgTxt("Must have three outputs");
    
    n_points  = mxGetN(prhs[0]);
    ntri      = mxGetM(prhs[1]);
    nf_points = mxGetM(prhs[2]);
    
    
    p_coord   = (float *)(mxGetPr(prhs[0]));
    triangle  = (int *)(mxGetPr(prhs[1]));
    f_coord   = (float *)(mxGetPr(prhs[2]));
    ids       = (int *)(mxGetPr(prhs[3]));
    nr_tracts = (int *)(mxGetPr(prhs[4]));
    
    nzmax = ceil((float)ntri * (float)nr_tracts[0] * (float)SPARSITY);
    
    i_index = mxMalloc(nzmax * sizeof(int));
    j_index = mxMalloc(nzmax * sizeof(int));
    angle_x = mxMalloc(nzmax * sizeof(float));
    angle_y = mxMalloc(nzmax * sizeof(float));
    angle_z = mxMalloc(nzmax * sizeof(float));
    
    th.p_coord   = p_coord;
    th.n_points  = n_points;
    th.triangle  = triangle;
    th.f_coord   = f_coord;
    th.nf_points = nf_points;
    th.id        = ids;
    th.N         = nr_tracts[0];
    th.angle_x   = angle_x;
    th.angle_y   = angle_y;
    th.angle_z   = angle_z;
    th.i_index   = i_index;
    th.j_index   = j_index;
    th.ntri      = ntri;
    
    pthread_mutex_init(&mutexsum, NULL);
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    
    /* start threads */
    for (t=0; t<NUM_THREADS; t++) {
        rc = pthread_create( &thread[t], &attr, loop_triangles, (void *)t);
        if (rc) {
            mexPrintf("ERROR; return code from pthread_create() is %d\n", rc);
            exit(-1);
        }
    }
    
    pthread_attr_destroy(&attr);
    
    /* join threads */
    for (t=0; t<NUM_THREADS; t++) {
        rc = pthread_join(thread[t], &status);
        if (rc) {
            mexPrintf("ERROR; return code from pthread_join() is %d\n", rc);
            exit(-1);
        }
    }
    
    /* Second version of the function : insted of returning the whole sparse matrix, returns only the i and j indices and the angle associated */
    plhs[0] = mxCreateDoubleMatrix((mwSize)index, (mwSize)1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix((mwSize)index, (mwSize)1, mxREAL);
    plhs[2] = mxCreateDoubleMatrix((mwSize)index, (mwSize)1, mxREAL);
    plhs[3] = mxCreateDoubleMatrix((mwSize)index, (mwSize)1, mxREAL);
    plhs[4] = mxCreateDoubleMatrix((mwSize)index, (mwSize)1, mxREAL);
    i_out   = mxGetPr(plhs[0]);
    j_out   = mxGetPr(plhs[1]);
    ax_out  = mxGetPr(plhs[2]);
    ay_out  = mxGetPr(plhs[3]);
    az_out  = mxGetPr(plhs[4]);
    
    for (j = 0; j < index; j++) {
        i_out[j] = (double)th.i_index[j];
        j_out[j] = (double)th.j_index[j];
        ax_out[j] = (double)th.angle_x[j];
        ay_out[j] = (double)th.angle_y[j];
        az_out[j] = (double)th.angle_z[j];
    }
    
    /* Free mem */
    mxFree(i_index);
    mxFree(j_index);
    mxFree(angle_x);
    mxFree(angle_y);
    mxFree(angle_z);
    
    pthread_mutex_destroy(&mutexsum);
    
    
}