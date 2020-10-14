// gconv.cpp
//
// MEX function for generating a sparse convolution operator rapidly from a
// vector (i.e. without the need for matlab for loops to fill in the i, j and
// s vectors).
//
//

#include <mex.h>
#include <math.h>

// workaround for MSVC for loop scope problem
#if defined( _MSC_VER)
#ifndef for
#define for if (0) {} else for
#endif
#endif

char *MEXName = "gconv";

inline int integermod(int n, int m)
{
   while(n < 0) n = n+m;
   while(n >= m) n = n-m;
   return n;
}

void Usage()
{
   printf("                                                                              \n");
   printf("  function T = gconv(v, shift)                                                \n");
   printf("                                                                              \n");
   printf("  GCONV constructs a (sparse) convolution operator T on the circle such that  \n");
   printf("  T(:, shift) = v.                                                            \n");
   printf("                                                                              \n");
   printf("  In:                                                                         \n");
   printf("     v     = nx1 sparse vector specifying a column of T                       \n");
   printf("     shift = determines which column of the convolution is v                  \n");
   printf("                                                                              \n");
   printf("  Out:                                                                        \n");
   printf("     T     = an nxn (sparse) convolution operator                             \n");
   printf("                                                                              \n");
   printf("  Dependencies:                                                               \n");
   printf("     none                                                                     \n");
   printf("                                                                              \n");
   printf("  Version History:                                                            \n");
   printf("     jcb        7/2005         initial version created                        \n");
   printf("                                                                              \n");
}

// void GetPositiveInteger(mxArray *a)
//
// If the matlab array a is 1x1 with an integer value, then return
// true and set *n equal to that value.  Otherwise, return false.
//

bool GetInteger(const mxArray *a, int *n)
{
   if(!mxIsSparse(a) && !mxIsComplex(a) && mxGetN(a)==mxGetM(a)==1) {
      if(mxGetClassID(a)==mxDOUBLE_CLASS) {
         double *data = mxGetPr(a);
         double value = data[0];

         if(ceil(value)!=value) return false;
         *n = (int)value;
      } else if(mxGetClassID(a)==mxINT32_CLASS) {
         int *data = (int *)mxGetPr(a);
         *n = (int)data[0];
      } else if(mxGetClassID(a)==mxINT16_CLASS) {
         short *data = (short *)mxGetPr(a);
         *n = (int)data[0];
      }else if(mxGetClassID(a)==mxINT8_CLASS) {
         char *data = (char *)mxGetPr(a);
         *n = (int)data[0];
      }else if(mxGetClassID(a)==mxUINT32_CLASS) {
         unsigned *data = (unsigned *)mxGetPr(a);
         *n = (int)data[0];
      }else if(mxGetClassID(a)==mxUINT16_CLASS) {
         unsigned short *data = (unsigned short *)mxGetPr(a);
         *n = (int)data[0];
      }else if(mxGetClassID(a)==mxUINT8_CLASS) {
         unsigned char *data = (unsigned char *)mxGetPr(a);
         *n = (int)data[0];
      }else
         return false;
   } else
      return false;
   return true;

}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   // initialize output
   if(nrhs==0) {
      Usage();
      return;
   }

   // get parameters
   int N;
   int shift;

//   if(nrhs<1 || !GetInteger(prhs[0], &N) || N <= 0) {
      //printf("%s: parameter 1 must be a positive integer.\n", MEXName);
      //plhs[0] = mxCreateSparse(1,1,0, mxREAL);
      //return;
   //}

   if(nrhs < 1 || !mxIsSparse(prhs[0]) || mxGetN(prhs[0])!=1 || mxIsComplex(prhs[1])) {
      printf("%s: parameter 1 must be a real sparse Nx1 matrix.\n", MEXName);
      plhs[0] = mxCreateSparse(1,1,0, mxREAL);
      return;
   }

   if(nrhs<2 || !GetInteger(prhs[1], &shift)) {
      printf("%s: parameter 2 must be an integer.\n", MEXName);
      plhs[0] = mxCreateSparse(1,1,0, mxREAL);
      return;
   }
   shift=shift-1; // take care of 1 vs 0 based indexing

   const mxArray *v = prhs[0];

   N = mxGetM(v);   // find out n

   int *v_ir = mxGetIr(v);
   int *v_jc = mxGetJc(v);
   double *v_pr = mxGetPr(v);
   int v_M = v_jc[1];

   // allocate a sparse matrix of the correct size
   mxArray *T = mxCreateSparse(N, N, v_jc[1]*N, mxREAL);

   plhs[0] = T;

   int *ir = mxGetIr(T);
   int *jc = mxGetJc(T);
   double *pr = mxGetPr(T);

   int i, j; // loop vars

   // initialize jc
   jc[0] = 0;
   for(j=1; j <= N; j++)
      jc[j] = jc[j-1]+v_M;

   // initialize pr and ir
   int index = 0;
   for(j=0; j < N; j++)
      for(i=0; i < v_M; i++) {
         pr[index]   = v_pr[i];
         ir[index++] = integermod(v_ir[i]+j-shift, N);
      }

}