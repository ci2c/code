// Basic.h
//
// Basic macros and definitions.  If the macro LEAK_DETECT is defined, Basic.h
// will overload the new and delete operators and provide a basic (and very
// inefficient) leak detection mechanism.  If the macro ASSERTIONS is defined,
// the assertion macros will be activated.  This can slow down the program
// substantially.
//
// Dependencies:   none
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#if !defined(BASIC__H)
#define BASIC__H

#include "LeakDetect.h"    // leak detection routines

// standardized macro for Visual C++
#if defined(_MSC_VER)
#define __MSVC__
#endif

// workaround for MSVC "for loop scope problem"
#if defined(__MSVC__)
#ifndef for
#define for if (0) {} else for
#endif
#endif

// define basic integer types .. these are independent of platform
typedef unsigned int     uint32;
typedef unsigned short   uint16;
typedef unsigned char    uint8;
typedef int              int32;
typedef short            int16;
typedef char             int8;

// 64-bit types are system dependent
#if defined(__MSVC__)

typedef __int64            int64;
typedef unsigned __int64   uint64;

#elif defined(__GNUC__)

typedef unsigned long long uint64;
typedef long long          int64;

#endif

// Simple assertion mechanism which is activated when then macro ASSERTIONS
// is defined.  The advantage of these routines over the C library routines,
// is that they can be adpated to a GUI environment or matlab.

#if defined(ASSERTIONS)

#include <stdlib.h>
void _assert(int condition, const char *file, int lineno, const char *assertion)
{
   if(!condition) {
      printf("\n\nAssertion failed in %s at line %d: %s\n", file, lineno, assertion);

#if !defined(MATLAB_MEX_FILE)
      exit(0);
#else
      mexErrMsgTxt("");
#endif
  }
}

#define assert(condition) _assert(condition, __FILE__, __LINE__, #condition)

#else
#define assert 0;
#endif

#undef max
#undef min

#if !defined(min)
template<class T>
inline T min(T a, T b)
{
   return a > b ? b : a;
}
#endif

#if !defined(max)
template<class T>
inline T max(T a, T b)
{
   return a > b ? a : b;
}
#endif

template<class T>
inline T abs(T x)
{
   return x < 0 ? -x : x;
}

#endif
