// MexUtility.h
//
// Utility routines for MEX files.  These routines are usefuly primarily for
// processing input parameters.  I suppose these should be placed in a seperate
// C++ file, but I think it might be easier just to leave them in a header file.
//
// Dependencies:          Basic.h
// Author:                James Bremer (james.bremer@yale.edu)

#if !defined(MEXUTILITY__H)
#define MEXUTILITY__H

#include "Basic.h"

/*
 * Get??? ultities
 *
 * These routines fetch a parameter value from a MATLAB array.
 */

// bool GetInteger(mxArray *a, int *value)
//
// Retrieve the value of an integer from the matlab array a.  The array must
// must be a 1x1 numeric array.
//
// If there are no type problems, the value is placed in *value and GetInteger
// returns true.  If not, it returns false.

inline bool GetInteger(const mxArray *a, int *value)
{
   if( !mxIsNumeric(a) || mxIsSparse(a) || mxIsComplex(a))
      return false;

   if(mxGetM(a)*mxGetN(a) > 1)
      return false;

   int ID = mxGetClassID(a);

   if(ID==mxDOUBLE_CLASS) {
      double *pr = mxGetPr(a);
      // check to see that the value is actually an integer
      if( floor(pr[0])!=pr[0])
         return false;

      *value = (int)pr[0];
      return true;
   } else if(ID== mxSINGLE_CLASS) {
      float *pr = (float *)mxGetData(a);
      // check to see that the value is actually an integer
      if( floor(pr[0])!=pr[0])
         return false;

      *value = (int)pr[0];
      return true;
   } else if(ID==mxINT8_CLASS) {
      int8 *pr = (int8 *)mxGetData(a);

      *value = (int)pr[0];
      return true;
   } else if(ID==mxUINT8_CLASS) {
      uint8 *pr = (uint8 *)mxGetData(a);

      *value = (int)pr[0];
      return true;
   } else if(ID==mxINT16_CLASS) {

      int16 *pr = (int16 *)mxGetData(a);

      *value = (int)pr[0];
      return true;
   } else if(ID==mxUINT16_CLASS) {
      uint16 *pr = (uint16 *)mxGetData(a);

      *value = (int)pr[0];
      return true;
   } else if(ID==mxINT32_CLASS) {
      int32 *pr = (int32 *)mxGetData(a);

      *value = (int)pr[0];
      return true;
   } else if(ID==mxUINT32_CLASS) {
      uint32 *pr = (uint32 *)mxGetData(a);

      *value = (int)pr[0];
      return true;
   }


   return false;
}

// bool GetDouble(mxArray *a, double *value)
//
// Retrieve the value of an double from the matlab array a.  The array must
// be a 1x1 array of doubles.
//
// If the value is read, it is placed in *value.  If not, GetDouble
// returns true.

bool GetDouble(const mxArray *a, double *value)
{
   if( !mxIsDouble(a) || mxIsSparse(a) || mxIsComplex(a))
      return false;
   if(mxGetM(a)*mxGetN(a) > 1)
       return false;
   double *pr = mxGetPr(a);

   *value = pr[0];
   return true;
}

// bool GetLogical(mxArray *a, double *value)
//
// Retrieve the value of a logical from the matlab array a.  The array must
// be either a 1x1 logical array or a 1x1 array of doubles.
//
// If the value is read, it is placed in *value.  If not, GetLogical
// returns true.

bool GetLogical(const mxArray *a, bool *value)
{
   if(mxIsComplex(a) || mxIsSparse(a) ||
     mxGetN(a)*mxGetM(a)!=1) {
     return false;
   }

   if(mxIsDouble(a))
   {
      double *data = (double *)mxGetData(a);
      if(data[0] > 0.0)
         *value = true;
      else
         *value = false;
      return true;
  }

   if(mxIsLogical(a))
   {
      *value = mxIsLogicalScalarTrue(a);
      return true;
   }

   return false;
}

#endif


