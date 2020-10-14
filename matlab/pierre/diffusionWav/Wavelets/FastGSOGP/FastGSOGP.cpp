// FastGSOGP.cpp
//
// C++ implementation of GSOGP algorithm.
//
// Uses:
//    SparseCMatrix.h, MxMatrix.h, utils.h, SparseColumn.h
//
// Source Control:
//    JCB   07/24/04   beta version based on MM's code
//

//#define ASSERTIONS
//#define DEBUG_OUT

#include "mex.h"
#include "matrix.h"

#include "MxMatrix.h"
#include "SparseCMatrix.h"
#include "ColumnOps.h"
#include "sort.h"

// some utility functions
void Usage()
{
   mexPrintf("\n");
   mexPrintf("  function [ VBasis, M, Idxs, DIdxs, WBasis ] = FastGSOGP ( T, [Options] )\n");
   mexPrintf("\n");
   mexPrintf("  The \"Grahmn-Schmidt Orthogoanlization with Geometric Pivoting\" orthogonalizes\n");
   mexPrintf("  the columns of T, discarding those that are below precision.  The result is a \n");
   mexPrintf("  basis of scaling functions VBasis and a downsampling operator M.  If the optional\n");
   mexPrintf("  output argument WBasis is requested, FastGSOGP also computes the corresponding\n");
   mexPrintf("  wavelet basis.\n");
   mexPrintf("\n");
   mexPrintf("  In:\n");
   mexPrintf("     Fcns    = MxN matrix of N vectors in R^M.\n");
   mexPrintf("     Options = A structure for specifying algorithm settings.  None of the fields\n");
   mexPrintf("               need to be set but the defaults are extremely conservative.\n");
   mexPrintf("\n");
   mexPrintf("               Precision  : Stop the process when the square of the L^2 norms of\n");
   mexPrintf("                            columns falls below this value.\n");
   mexPrintf("               N          : Stop after choosing at most N functions.\n");
   mexPrintf("               Relax      : Relaxation parameter for L^2 norms\n");
   mexPrintf("               Aggressive : If true, aggresively search for columns with small\n");
   mexPrintf("                            support.\n");
   mexPrintf("               IPThres    : Threshold for orthogonality; if the inner product\n");
   mexPrintf("                            of two vectors is less than this, don't orthogonalize.\n");
   mexPrintf("               Threshold  : Threshold for Fcn matrix entries on input.\n");
   mexPrintf("\n");
   mexPrintf("  Out:\n");
   mexPrintf("     VBasis  = MxK orthogonal matrix of K scaling functions in R^M.\n");
   mexPrintf("     M       = NxK matrix such that M*Basis' approximates Fcns.  Note that: This is the\n");
   mexPrintf("               transpose of the \"M\" matrix returned by the matlab GSOGP code.\n");
   mexPrintf("     VIdxs   = Indices of the columsn chosen to form VBasis.\n");
   mexPrintf("     WBasis  = Mx(N-K) orthogonal matrix of K wavelet functions in R^M.\n");
   mexPrintf("     WIdxs   = Indices of the columns that were chosen to form WBasis.\n");
   mexPrintf("\n");
   mexPrintf("  Source Control:\n");
   mexPrintf("      beta version (Jim Bremer 07/23/04) based on MM's matlab code\n");
   mexPrintf("\n");
}

// read one of the option's values if the field exists
// if the field exists but is of the wrong type, quit on error
void GetOptionValue(const mxArray *input, const char *fieldname, double *value)
{
   if( input!=NULL &&
       mxIsStruct(input) &&
       mxGetN(input)*mxGetM(input) == 1)
    {
      mxArray *field0 = mxGetField(input, 0, fieldname);

      // its ok not to have a field
      if(field0==NULL)
         return;

      // but if specified and wrong type quit on error
      if(  mxIsDouble(field0) &&
          !mxIsComplex(field0) &&
          !mxIsSparse(field0) &&
          mxGetN(input)*mxGetM(input)==1)
      {

         double *data = (double *)mxGetData(field0);
         *value = data[0];
      } else {
         char buffer[1024];
         _snprintf(buffer, 1023, "FastGSOGP: incorrect type Options.%s.\n", fieldname);
         mexErrMsgTxt(buffer);
      }

    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   int i,j,k;  // loop indices (MS C++ scope is messed up)

   /////////////////////////////////////////
   // Check and initialize input variables
   /////////////////////////////////////////
   if(nrhs < 1 || nrhs >2 || nlhs > 5) {
      Usage();
      return;
   }

   // first argument: Fcns
   if( !mxIsNumeric(prhs[0]) ||
        mxIsComplex(prhs[0]) ||
      (!mxIsDouble(prhs[0]) && !mxIsSparse(prhs[0])))
      mexErrMsgTxt("FastGS: first argument must be a real matrix of doubles.\n\n");

   // second argument: Options

   // default options are very conservative
   int    nFcnsMax    = -1;
   double fRelax      = 1.001;
   double fPrecision  = 0.0;
   int    bAggressive = 0;
   double fIPThres    = 1e-15;
   double fThreshold  = 0.0;

   if( nrhs > 1) {
      if( !mxIsStruct(prhs[1]) ||
           mxGetN(prhs[1]) * mxGetM(prhs[1]) !=1)
         mexErrMsgTxt("FastGS: optional second argument must be a structure.\n\n");

      double N = -1.0;
      double A = (double) bAggressive;

      GetOptionValue(prhs[1], "Precision", &fPrecision);
      GetOptionValue(prhs[1], "N", &N);
      GetOptionValue(prhs[1], "Relax", &fRelax);
      GetOptionValue(prhs[1], "Aggressive", &A);
      GetOptionValue(prhs[1], "IPThres", &A);
      GetOptionValue(prhs[1], "Threshold", &A);

      if(N!=-1.0)
         nFcnsMax = (int)N;
      bAggressive = (int)A;
   }

   SparseCMatrix Fcns(prhs[0], fThreshold);  // the sparse input array

   if(nFcnsMax == -1)
      nFcnsMax = Fcns.GetN();

   #ifdef DEBUG_OUT
   mexPrintf("FastGSOGP[N = %d, Relax = %g, Precision = %g, Aggressive = %d, IPThres = %g, Threshold = %f] %dx%d",
      nFcnsMax, fRelax, fPrecision, bAggressive, fIPThres, fThreshold, Fcns.GetM(), Fcns.GetN());

   if(mxIsSparse(prhs[0]))
      mexPrintf(" Sparse");


   #ifdef ASSERTIONS
   mexPrintf(" (assertions on)");
   #endif
   mexPrintf(".\n");
   #endif

   /////////////////////////////////////////
   // Initialize algorithm variables
   /////////////////////////////////////////

   int nFcns   = Fcns.GetN();
   int nDim    = Fcns.GetM();

   SparseCMatrix M(nDim, nFcns, 0);

   int    *nCols   = (int *)  mxMalloc( sizeof(int) * nFcns);
   double *fNorms  = (double *)mxMalloc( sizeof(double) *nFcns);

   for(i=0; i < nFcns; i++) {
      fNorms[i] = sum_axopby<OpMul>(1.0, Fcns, i, 1.0, Fcns, i, OpMul());
      nCols[i]  = i;
   }

   int nLastFcn    = nFcns-1;      // index of last function we can consider
   int nFcnsChosen = 0;            // # we have chosen so far

   /////////////////////////////////////////
   // Find the scaling functions
   /////////////////////////////////////////

   // do at most nFcnsMax
   for(i=0; i < nFcnsMax; i++) {
      #ifdef DEBUG_OUT
      mexPrintf("\t iter %03d :: ",i);
      #endif

      // sort the norms with their column indices using mergesort
      // because its stable
      //mergesort(fNorms, nCols, 0, nLastFcn);
      quicksort(fNorms, nCols, 0, nLastFcn);

      double RelaxedNorm = fNorms[nLastFcn];

      // if we are below precision, book
      if(RelaxedNorm < fPrecision) {
         #ifdef DEBUG_OUT
         mexPrintf("stopped @ norm %g.\n", RelaxedNorm);
         #endif
         break;
      }

      #ifdef DEBUG_OUT
      mexPrintf("norm = %g ", RelaxedNorm);
      #endif

      // look for the first function with acceptable L^2 norm
      int    ChosenIdx  = nLastFcn;

      // if we are aggressive we look for anything above precision
      if(bAggressive)
         RelaxedNorm = fPrecision;
      else
         RelaxedNorm = RelaxedNorm / fRelax;

      // find index of first column with big enough norm
      while( ChosenIdx>0 && fNorms[ChosenIdx-1] > RelaxedNorm) {ChosenIdx--;}

      #ifdef DEBUG_OUT
      mexPrintf("relaxed norm = %g ", RelaxedNorm);
      mexPrintf("looked at = %d ", nLastFcn-ChosenIdx+1);
      #endif

      // among the good functions, find the one with smallest support
      double SNorm = sum_axopby<OpCount>(1.0, Fcns, nCols[ChosenIdx], 0.0, Fcns, 0, OpCount());

      for(j=ChosenIdx+1; j < nLastFcn+1; j++) {

         double temp = sum_axopby<OpCount>(1.0, Fcns, nCols[j], 0.0, Fcns, 0, OpCount());

         if(temp < SNorm) {
            SNorm=temp;
            ChosenIdx = j;
         }
      }
      // if the chosen index isn't in the last variable, swap it
      if(ChosenIdx != nLastFcn) {
         int    col_temp  = nCols[nLastFcn];
         double norm_temp = fNorms[nLastFcn];
         nCols[nLastFcn] = nCols[ChosenIdx];
         fNorms[nLastFcn] = fNorms[ChosenIdx];
         nCols[ChosenIdx] = col_temp;
         fNorms[ChosenIdx] = norm_temp;
      }

      double ChosenNorm = fNorms[ChosenIdx];
      int    ChosenCol  = nCols[ChosenIdx];


      ChosenNorm = fNorms[nLastFcn];
      ChosenCol  = nCols[nLastFcn];
      #ifdef DEBUG_OUT
      mexPrintf("choose column %d ( norm %g support %g)", ChosenCol, ChosenNorm, SNorm);
      #endif

      double t = sqrt(ChosenNorm);
      // normalize the chosen vector
      zeaxopby<OpPlus>(Fcns, ChosenCol, 1/t, Fcns, ChosenCol, 0.0, Fcns, 0, OpPlus());

      M.Set(ChosenCol, i, t);

      // orthogonalize all other columns to it
      for(j=0; j < nLastFcn; j++) {
         double ip = sum_axopby<OpMul>(1.0, Fcns, nCols[j], 1.0, Fcns, ChosenCol, OpMul());
         if(fabs(ip) > fIPThres) {
            M.Set(nCols[j], i, ip);

            zeaxopby<OpPlus>(Fcns, nCols[j], 1.0, Fcns, nCols[j], -ip, Fcns, ChosenCol, OpPlus());
            // adjust L^2 norm
            fNorms[j] = sum_axopby<OpMul>(Fcns, 1.0, nCols[j], 1.0, nCols[j], OpMul());
         }
      }
      nLastFcn--; nFcnsChosen++;

      #ifdef DEBUG_OUT
      mexPrintf("\n");
      #endif
   }

   int nFcnsDiscarded = nFcns - nFcnsChosen;

   int *SelectedIdxs  = (int *)mxMalloc( sizeof(int) * nFcnsChosen);
   int *DiscardedIdxs = (int *)mxMalloc( sizeof(int) * nFcnsDiscarded);

   for(i=0; i < nFcnsDiscarded; i++)
      DiscardedIdxs[i] = nCols[i];

   // reverse the order
   for(i=0; i < nFcnsChosen; i++)
      SelectedIdxs[i] = nCols[nFcns-1-i];

   /////////////////////////////////////////
   // Prepare scaling function return info
   /////////////////////////////////////////

   if(nlhs > 0) // return selected columns as VBasis
      plhs[0] = Fcns.GetSparseMx(nFcnsChosen, SelectedIdxs);

   if(nlhs > 1) // return the matrix M
   {
      M.ChooseColumns(nFcnsChosen);
      plhs[1] = M.GetSparseMx();
   }

   if(nlhs > 2) // return VIdxs
   {
      MxMatrix<MxDbl> Idxs(1, nFcnsChosen);
      for(i=0; i < nFcnsChosen; i++)
         Idxs(0, i) = (double)(SelectedIdxs[i]+1);
      plhs[2] = Idxs.GetMx();
   }

   /////////////////////////////////////////
   // Find wavelet functions
   /////////////////////////////////////////

   if(nlhs > 3) {
      // make another copy of the input data
      SparseCMatrix  WaveletFcns(prhs[0]);
      SparseCMatrix  Id(WaveletFcns.GetM(), WaveletFcns.GetN());

      // take I-T
      for(j=0; j < WaveletFcns.GetN(); j++)
         zeaxopby<OpPlus>(WaveletFcns, j, 1.0, Id, j, -1.0, WaveletFcns, j, OpPlus());

      int nNumWavelets = nFcnsDiscarded;

      // selected the discarded columns
      WaveletFcns.ChooseColumns(nNumWavelets, DiscardedIdxs);

      // reuse nIdxs and fNorms arrays
      for(i=0; i < nNumWavelets; i++) {
         fNorms[i] = sum_axopby<OpMul>(WaveletFcns, 1.0, i, 1.0, i, OpMul());
         nCols[i]  = i;
      }

      for(i=0; i < nFcnsDiscarded; i++) {
         // choose the functions one by one on the basis of L^2 norm

         mergesort(fNorms, nCols, 0, nNumWavelets-1);

         int ChosenIdx  = nNumWavelets-1;
         double ChosenNorm = fNorms[ChosenIdx];
         int ChosenCol  = nCols[ChosenIdx];

         // orthogonalize it to the scaling basis
         for(j=0; j < nFcnsChosen; j++) {
            double ip = sum_axopby<OpMul>(1.0, WaveletFcns, ChosenCol, 1.0, Fcns, SelectedIdxs[j], OpMul());
            if( fabs(ip) > fIPThres)
               zeaxopby<OpPlus>(WaveletFcns, ChosenCol, 1.0, WaveletFcns, ChosenCol, -ip, Fcns, SelectedIdxs[j], OpPlus());
         }

         // now normalize the chosen function
         double norm = sum_axopby<OpMul>(WaveletFcns, 1.0, ChosenCol, 1.0, ChosenCol, OpMul());
         zeaxopby<OpPlus>(WaveletFcns, ChosenCol, 1/sqrt(norm), ChosenCol, 0.0, 0, OpPlus());

         // normalize the reamining wavelets to it
         for(j=0; j < nNumWavelets-1; j++) {
            double ip = sum_axopby<OpMul>(WaveletFcns, 1.0, ChosenCol, 1.0, nCols[j], OpMul());

            if( fabs(ip) > fIPThres)
               zeaxopby<OpPlus>(WaveletFcns, nCols[j], 1.0, nCols[j], -ip, ChosenCol, OpPlus());
         }
         nNumWavelets--;
      }

      plhs[3] = WaveletFcns.GetSparseMx();   // return the wavelet functions

      if(nlhs > 4) { // return WIdxs
         MxMatrix<MxDbl> WIdxs(1, nFcnsChosen);
         for(i=0; i < nFcnsDiscarded; i++)
            WIdxs(0, i) = (double)(DiscardedIdxs[i]+1);
         plhs[4] = WIdxs.GetMx();
      }

   }


   mxFree(fNorms);
   mxFree(nCols);
   mxFree(SelectedIdxs);
   mxFree(DiscardedIdxs);
}