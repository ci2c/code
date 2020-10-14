#include "mex.h"
#include "math.h"
#include <malloc.h>
#include <time.h>
#include "stdio.h"
#include <stdlib.h>
#include <unistd.h>

#define TRUE 1
#define FALSE 0
#define SPARSITY 0.01

#define SMALL_NUM   0.0000001
#define dot(u,v)   ((u).x * (v).x + (u).y * (v).y + (u).z * (v).z)
#define norm(u)    ((float)sqrt( (u).x * (u).x + (u).y * (u).y + (u).z * (u).z));

int index, j_index;

typedef struct
{
    float     *p_coord;
    int        n_points;
    int       *triangle;
    float     *f_coord;
    double    *c_mat;
    int        nf_points;
    int       *id;
    int        N;
    double    *sr;
    double    *si;
    mwIndex   *irs;
    mwIndex   *jcs;
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
    int i, current_id, next_id, fiber_index, cross_flag;
    float R, Dist, w, s, t, u, tt, N1, N2, N3;
    Vector V1, V2, V3, Q1, Q2, A, B, C, W1, W2, D, Q12, Center;
    
    th.jcs[(mwIndex)tri_id] = (mwIndex)index;
    
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
        } else {
            
            if (cross_flag != 0) continue;
            
            Q1.x = th.f_coord[i];
            Q1.y = th.f_coord[i + th.nf_points];
            Q1.y = th.f_coord[i + 2*th.nf_points];
            
            Q2.x = th.f_coord[i + 1];
            Q2.y = th.f_coord[i + 1 + th.nf_points];
            Q2.y = th.f_coord[i + 1 + 2*th.nf_points];
            
            if ( ( (Center.x - Q1.x) * (Center.x - Q1.x) + (Center.y - Q1.y) * (Center.y - Q1.y) + (Center.z - Q1.z) * (Center.z - Q1.z) ) > 1.0f) continue;
            
            /* Below is an implementation of */
            /* Jimenez et al., Computational Geometry (2010) */
            
            /* Define vectors */
            A  = p_diff(V3, Q1);
            B  = p_diff(V3, V1);
            C  = p_diff(V3, V2);
            W1 = vec_prod(B, C);
            w  = dot(A, W1);
            D  = p_diff(V3, Q2);
            s  = dot(D, W1);
            
            /* Tests */
            if (w > SMALL_NUM) {
                if (s > SMALL_NUM) continue;
                W2 = vec_prod(A, D);
                t = dot(W2, C);
                if (t < -SMALL_NUM) continue;
                u = -dot(W2, B);
                if (u < -SMALL_NUM) continue;
                if (w < s + t + u) continue;
            } else if (w < -SMALL_NUM) {
                if (s < -SMALL_NUM) continue;
                W2 = vec_prod(A,D);
                t = dot(W2, C);
                if (t > SMALL_NUM) continue;
                u = -dot(W2,B);
                if (u > SMALL_NUM) continue;
                if (w > s + t + u) continue;
            } else {
                if (s > SMALL_NUM) {
                    W2 = vec_prod(D,A);
                    t = dot(W2,C);
                    if (t < -SMALL_NUM) continue;
                    u = -dot(W2,B);
                    if (u < -SMALL_NUM) continue;
                    if (-s < t + u) continue;
                } else if (s < -SMALL_NUM) {
                    W2 = vec_prod(D,A);
                    t = dot(W2, C);
                    if (t > SMALL_NUM) continue;
                    u = -dot(W2,B);
                    if (u > SMALL_NUM) continue;
                    if (-s > t + u) continue;
                } else continue;
            }
            /* In this case only the segment intersects the triangle */
            /* Store the contact angle at the right matrix place */
            /* We have to use mutex locks to fill the sparse matrix */
            Q12 = p_diff(Q1, Q2);
            N1  = dot(W1, Q12);
            N2  = norm(W1);
            N3  = norm(Q12);
            
            th.sr[(mwIndex)index] = (double) (N1 / (N2 * N3));
            th.irs[(mwIndex)index] = (mwIndex)fiber_index;
            index++;
            cross_flag = 1;
            mexPrintf("tid = %d ; irs = %d ; sr = %f\n", tri_id, fiber_index, (double) (N1 / (N2 * N3)));
        }
    }
}


/* Main function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    int n_points, nf_points, nzmax, ntri, *triangle, *ids, *nr_tracts, t;
    float *p_coord, *f_coord, *s_radius;
    double *sr, *si;
    mwIndex *irs, *jcs;
    
    mexPrintf("Check 0. Starts OK\n");
    
    index   = 0;
    j_index = 0;
    
    if (nrhs != 5)
    mexErrMsgTxt("Must have five inputs");
    if (nlhs != 1)
    mexErrMsgTxt("Must have one output");
    
    mexPrintf("Check 1. Init OK\n");
    
    n_points  = mxGetN(prhs[0]);
    ntri      = mxGetM(prhs[1]);
    nf_points = mxGetM(prhs[2]);
    
    
    p_coord   = (float *)(mxGetPr(prhs[0]));
    triangle  = (int *)(mxGetPr(prhs[1]));
    f_coord   = (float *)(mxGetPr(prhs[2]));
    ids       = (int *)(mxGetPr(prhs[3]));
    nr_tracts = (int *)(mxGetPr(prhs[4]));
    
    nzmax = ceil((float)ntri * (float)nr_tracts[0] * (float)SPARSITY);
    
    mexPrintf("Check 2. Data size OK\n");
    
    plhs[0] = mxCreateSparse((mwSize)nr_tracts[0], (mwSize)ntri, (mwSize)nzmax, 0);
    mexPrintf("Check 3. Memory allocation OK\n");
    sr  = mxGetPr(plhs[0]);
    si  = mxGetPi(plhs[0]);
    irs = mxGetIr(plhs[0]);
    jcs = mxGetJc(plhs[0]);
    
    th.p_coord   = p_coord;
    th.n_points  = n_points;
    th.triangle  = triangle;
    th.f_coord   = f_coord;
    th.nf_points = nf_points;
    th.id        = ids;
    th.N         = nr_tracts[0];
    th.sr        = sr;
    th.si        = si;
    th.irs       = irs;
    th.jcs       = jcs;
    th.ntri      = ntri;
    
    mexPrintf("Check 4. Structure construction OK\n");
    
    /* Debugging */
    mexPrintf("n_points = %d\n", n_points);
    mexPrintf("ntri = %d\n", ntri);
    mexPrintf("nf_points = %d\n", nf_points);
    mexPrintf("nzmax = %d\n", nzmax);
    
    mexPrintf("p_coord = %f %f %f\n %f %f %f\n", p_coord[0], p_coord[1], p_coord[2], p_coord[3], p_coord[3+1], p_coord[3+2]);
    mexPrintf("tri = %d %d %d\n %d %d %d\n", triangle[0], triangle[0 + ntri], triangle[0+2*ntri], triangle[1], triangle[1 + ntri], triangle[1+2*ntri]);
    mexPrintf("nf_points = %f %f %f\n %f %f %f\n", f_coord[0], f_coord[0+nf_points], f_coord[0+2*nf_points], f_coord[1], f_coord[1+nf_points], f_coord[1+2*nf_points]);
    mexPrintf("ids = %d %d %d %d\n", ids[0], ids[1], ids[2], ids[3]);
    
    mexPrintf("Check 5. Mutex creation OK\n");
    
    /* start job */
    for (t=0; t<th.ntri; t++) {
        get_intersect(t);
    }
    
    th.jcs[(mwIndex)th.ntri]  = (mwIndex)index;
}