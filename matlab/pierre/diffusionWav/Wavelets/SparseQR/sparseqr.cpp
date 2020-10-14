// sparseqr.cpp
//

//#define ASSERTIONS
//#define LEAK_DETECT
//#define DEBUG_OUT
#define MATLAB_SUPPORT

#ifdef DEBUG_OUT
#define dprintf printf
#else
#define dprintf 0
#endif

#include "mex.h"
#include <stdio.h>
#include "HFTimer.h"
#include "GramSchmidt.h"



template<class T>
mxArray *ConvertToMx(const vector<T> &v)
{
   mxArray *matlab_array;

   matlab_array = mxCreateDoubleMatrix(1, v.size(), mxREAL);
   double *pr = mxGetPr(matlab_array);
   for(int j=0; j < v.size(); j++)
      pr[j] = (double)v[j];
   return matlab_array;
}

void Usage()
{
   printf("function [Idxs DIdxs Q11 R11] = sparseqr(T, Options)\n");
   printf("\n");
   printf("Options.StopN\n");
   printf("Options.StopPrecision\n");
   printf("Options.StopDensity\n");
   printf("Options.Reorthogonalize\n");

}


bool GetOption(const mxArray *input, const char *fieldname, double *value)
{
   if( input!=NULL &&
       mxIsStruct(input) &&
       mxGetN(input)*mxGetM(input) == 1)
    {
      mxArray *field0 = mxGetField(input, 0, fieldname);

      // its ok not to have a field
      if(field0==NULL)
         return false;

      // but if specified and wrong type quit on error
      if(  mxIsDouble(field0) &&
          !mxIsComplex(field0) &&
          !mxIsSparse(field0) &&
          mxGetN(input)*mxGetM(input)==1)
      {

         double *data = (double *)mxGetData(field0);
         *value = data[0];
         return true;
      }
    }
    return false;
}

bool GetOption(const mxArray *input, const char *fieldname, unsigned int  *value)
{
   if( input!=NULL &&
       mxIsStruct(input) &&
       mxGetN(input)*mxGetM(input) == 1)
    {
      mxArray *field0 = mxGetField(input, 0, fieldname);

      // its ok not to have a field
      if(field0==NULL)
         return false;

      // but if specified and wrong type quit on error
      if(  mxIsDouble(field0) &&
          !mxIsComplex(field0) &&
          !mxIsSparse(field0) &&
          mxGetN(input)*mxGetM(input)==1)
      {

         double *data = (double *)mxGetData(field0);
         if(floor(data[0])!=ceil(data[0])) {
            char buffer[1024];
            _snprintf(buffer, 1023, "gsqr.cpp: incorrect type Options.%s.\n", fieldname);
            mexErrMsgTxt(buffer);
         }

         *value = (unsigned int)data[0];
         return true;
      }
    }
    return false;
}

bool GetOption(const mxArray *input, const char *fieldname, bool *value)
{
   if( input!=NULL &&
       mxIsStruct(input) &&
       mxGetN(input)*mxGetM(input) == 1)
    {
      mxArray *field0 = mxGetField(input, 0, fieldname);

      // its ok not to have a field
      if(field0==NULL)
         return false;
      // but if specified and wrong type quit on error
      if(  (mxIsDouble(field0) || mxIsLogical(field0))&&
          !mxIsComplex(field0) &&
          !mxIsSparse(field0) &&
          mxGetN(input)*mxGetM(input)==1)
      {
         double *data = (double *)mxGetData(input);
         printf("%f\n", data[0]);
         if(data[0] > 0.0)
            *value = true;
         else
            *value = false;
         return true;
      }
    }
    return false;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   HFTimer timer;

   // report some basic information
   dprintf("Processor clock speed:      %4.2f MHZ\n", (double)timer.GetFrequency()*1e-6);
   dprintf("Apparent address space:     %d bits\n", sizeof(void *)*8);

   dprintf("Assertions:                 ");
 #if defined(ASSERTIONS)
   dprintf("on\n");
#else
   dprintf("off\n");
#endif
   dprintf("Memory leak detection:      ");
#if defined(LEAK_DETECT)
   dprintf("on\n");
#else
   dprintf("off\n");
#endif
   dprintf("\n");

   if(nrhs < 2 || !mxIsSparse(prhs[0]) || !mxIsStruct(prhs[1])) {
      Usage();
      return;
   }
   dprintf("Converting prhs[0] to SparseMatrix<double, int> ... ");
   timer.Reset();
   timer.Start();
   SparseMatrix<double, int>  *A = new SparseMatrix<double, int>(prhs[0]);
   timer.Stop();
   dprintf("%f ms\n", timer.GetElapsedTime());

   // Process options


   GramOptions Opts;
   GramReturn<double, int> Out;

   if(!GetOption(prhs[1], "Reorthogonalize", &Opts.Reorthogonalize))
      Opts.Reorthogonalize = true;
   if(!GetOption(prhs[1], "IPThreshold", &Opts.IPThreshold))
      Opts.IPThreshold     = -1.0;
   if(!GetOption(prhs[1], "StopPrecision", &Opts.StopPrecision))
      Opts.StopPrecision   = 0.0;
   if(!GetOption(prhs[1], "StopN", &Opts.StopN))
      Opts.StopN           = A->GetN();
   if(!GetOption(prhs[1], "StopDensity", &Opts.StopDensity))
      Opts.StopDensity     = 1.0;

   dprintf("Options\n");
   dprintf("   Opts.Reorthogonalize = %d\n", Opts.Reorthogonalize);
   dprintf("   Opts.IPThreshold     = %f\n", Opts.IPThreshold);
   dprintf("   Opts.StopPrecision   = %f\n", Opts.StopPrecision);
   dprintf("   Opts.StopN           = %d\n", Opts.StopN);
   dprintf("   Opts.StopDesnity     = %f\n", Opts.StopDensity);

   GramSchmidt(A, &Opts, &Out);

   // adjust Idxs and DIdxs for matlab 1-based array addressing
   for(int j=0; j < Out.Idxs.size(); j++)
        Out.Idxs[j]++;
   for(int j=0; j < Out.DIdxs.size(); j++)
        Out.DIdxs[j]++;

   plhs[0] = ConvertToMx(Out.Idxs);
   if(nlhs > 1)
      plhs[1] = ConvertToMx(Out.DIdxs);
   if(nlhs > 2)
      plhs[2] = Out.Q11->GetMx();
   if(nlhs > 3)
      plhs[3] = Out.R11->GetMx();
//   if(nlhs > 4)
      //plhs[4] = Out.IR11->GetMx();

      //for(int j=0; j < Out.Idxs.size(); j++)
         //Out.Idxs[j]++;
      //plhs[3] = ConvertToMx(Out.Idxs);
   //}

   //if(nlhs > 4) {
//     for(int j=0; j < Out.DIdxs.size(); j++)
         //Out.DIdxs[j]++;
      //plhs[4] = ConvertToMx(Out.DIdxs);
   //}

   delete Out.Q11;
   delete Out.R11;
   //delete Out.R12;
   delete A;

#if defined(LEAK_DETECT)
   __mbl.DetectLeaks();
#endif

}

