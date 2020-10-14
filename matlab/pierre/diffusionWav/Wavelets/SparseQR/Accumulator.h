// Accumulator.h
//
// Contains the Accumulator<T,I> class which is used by SparseMatrix<T,I> and
// by some of the vector operator routines for SparseVector<T,I>.
//
// Dependencies:        Basic.h
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#if !defined(ACCUMULATOR__H)
#define ACCUMULATOR__H

#include "Basic.h"

// class Accumulator<T,I>
//
// This accumulator class provides temporary storage for sparse operations.
// Many sparse ops require O(M) temporary storage where M is the number of
// rows of the sparse matrix or the "length" of the sparse vector.
//
// By using a flag which is incremented after each operation, we can
// avoid reinitializing the accumulator (which costs O(M)).

template<class T, class I>
class Accumulator
{
public:

   typedef uint32 flag_type;

   Accumulator(uint32 length) {
      Length = length;

      flags = new uint32[Length];
      vals  = new T[Length];
      idxs  = new I[Length];

      // initialize flags
      for(int j=0; j < Length; j++)
         flags[j] = 0;

      CurrentFlag = 0;
   }

   ~Accumulator() {
      delete flags;
      delete vals;
      delete idxs;
   }

   // return the next value to use for flags
   inline flag_type GetFlag() {
      return ++CurrentFlag;
   }

   // return the current flag w/o advancing it
   inline flag_type GetCurrentFlag() {
      return CurrentFlag;
   }

   // return the length of the accumulator
   inline uint32 GetLength() { return Length; }

   // methods to return the buffers
   inline I *GetIdxs() { return idxs; }
   inline T *GetVals() { return vals; }
   inline uint32 *GetFlags() { return flags; }
private:

   uint32 Length;

   uint32 CurrentFlag;
   uint32 *flags;
   T      *vals;
   I      *idxs;
};

#endif
