// Assertf.h
//
// Simple assert routines.  These routines need to be rewritten depending on
// platform used.
//
// Source Control:
//    JCB 07/22/04
//

#ifndef UTILS__H__JCB
#define UTILS__H__JCB

#include "mex.h"
#include "matrix.h"
#include <string.h>

// this is my own stupid little assertion mechanism (I had trouble getting
// matlab's to work right).
#ifdef ASSERTIONS

void Warn(int condition, char *message)
{
   mexWarnMsgTxt(message);
}

void Assert(int condition, char *message)
{
   if(!condition) {
      char buffer[1024];
      _snprintf(buffer, 1024, "Assertion failed: %s\n", message);
      mexErrMsgTxt(buffer);
   }
}
#else
   #define Assert  0;
   #define Warn 0;
#endif


#endif
