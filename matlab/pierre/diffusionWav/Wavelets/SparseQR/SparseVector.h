// SparseVector.h
//
// Implementation of the SparseVector<T,I> class for storing a vector as a list
// of (index, value) pairs.
//
// Dependencies:        Basic.h, QuickSort.h, Accumulator.h
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#if !defined(SPARSEVECTOR__H)
#define SPARSEVECTOR__H

#include <math.h>
#include <string.h>
#include <stdarg.h>
#include <memory.h>
#include <limits> // numeric_limits

#include "Basic.h"
#include "QuickSort.h"
#include "Accumulator.h"

#undef max

// forward declarations
template<class T, class I>
class SparseMatrix;

template<class T, class I>
SparseMatrix<T,I> *Transpose(const SparseMatrix<T,I> *A);

// macro MaxIndex(I)
//
// Returns the largest positive integer which the type I can hold.  This
// value is used as an end-of-list indicator by the SparseVector<T,I>
// class.
#define MaxIndex(I) std::numeric_limits<I>::max()

template<class T, class I>
class SparseVector;

// class SparseVector<T,I>
//
// Class for storing a sparse vector as a list of (index, value) pairs where
// the indices are of type I and the values of type T.
//
// The list of indices is terminated with a special end-of-list marker
// equal to MaxIndex(I).  This simplifies certain loops.
//

template<class T, class I>
class SparseVector
{
public:
   ////////////////////////////////
   // Constructors and destructor
   ////////////////////////////////

   // construct the zero sparse vector of length m
   SparseVector(uint32 m) {
      Initialize(m);
   }

   // initialize from a list of sorted (index,value) pairs of type (int, double)
   SparseVector(uint32 m, uint32 used, int *ir, double *pr) {
      Initialize(m, used, ir, pr);
   }

   // initialize from a list of sorted (index, value) pairs of types I,T
   // note the order of ir and pr is swapped to distinguish this from the
   // preceeding constructor when I is int and T is double
   SparseVector(uint32 m, uint32 used, T *pr, I *ir) {
      Initialize(m, used, pr, ir);
   }

   // copy from an accumulator buffer
   SparseVector(uint32 m, uint32 used, Accumulator<T,I> *acc) {
      Initialize(m, used, acc);
   }

   // pointer "copy" constructer
   SparseVector(const SparseVector<T,I> *v) {
      Initialize(*v);
   }

   // pointer "copy" constructer
   SparseVector(const SparseVector<T,I> &v) {
      Initialize(v);
   }

   // destructor
   ~SparseVector() {
      Destroy();
   }

   /////////////////////////
   // Information routines
   /////////////////////////

   // return the length of the vector
   inline uint32 GetLength() const {
      return Length;
   }

   // return number of nonzero entriees
   inline uint32 GetNNZ() const {
      return (uint32)Used;
   }

   ////////////////////////
   // Set and get methods
   ////////////////////////

   // "zero" out this vector
   inline void Zero() {
      Destroy();              // clear current values
      Initialize(Length);     // make us the zero vector
   }

   inline T Get(int row) const {
      assert(0<= row && row < Length);
      int index = 0;

      // advance to the right position
      while(idxs[index] < row)
         index++;

      // check to see if the entry is 0
      if(row==idxs[index])
         return vals[index];
      else
         return 0;
   }

   // copy values from a list of (index, value) pairs of types (int, double)
   inline void Set(int num, int *ir, double *pr) {
      Destroy();
      Initialize(Length, num, ir, pr);
   }

   // copy from a list (index, value) pairs of type (I, T) ... note the
   // order of the parameters is reversed to distinguish it from the preceeding
   // set method
   inline void Set(int num, T *pr, I *ir) {
      Destroy();
      Initialize(Length, num, pr, ir);
   }

   // copy from a sparse vector
   inline void Set(const SparseVector<T,I> &v) {
      Destroy();
      Initialize(v);
   }

   // set from an accumulator buffer
   inline void Set(uint32 m, uint32 used, Accumulator<T,I> *acc) {
      Destroy();
      Initialize(m, used, acc);
   }

   // copy from a full vector with thresholding
   inline void Set(T *buffer, double threshold) {
      Destroy();
      Initialize(Length, buffer, threshold);
   }

   ////////////////////////////////
   // Iterator class and routines
   ////////////////////////////////

   // class SparseVector::iterator
   //
   // This is the primary public interface to the sparse vector class.
   // The iterator advances through the list of nonzero entries in the vector.
   //
   // WARNING: I haven't found an efficient way to implement postfix operators
   // yet, so right now iter++ behaves like PREFIX!!!!

   class iterator {
   public:

      // return true if we are at the end of the list
      inline bool EndOfList() { return *idx==MaxIndex(I); };

      inline const T& GetValue() const { return *val; }
      inline const I GetIndex() const { return *idx; }

      // operators
      inline T& operator *() { return *val; };

      inline void Inc() {
         idx++;
         val++;
      }

      // prefix version
      inline iterator &operator ++() {
         idx++; val++;
         return *this;
      };

      // WARNING THIS IS PREFIX AS WELL
      inline iterator &operator ++(int) {
         idx++; val++;
         return *this;//*(new iterator(idx-1,val-1));

      };

      inline bool operator != (const iterator& it) const {
         return *idx!=*it.idx;
      }
      inline bool operator == (const iterator& it) const {
         return *idx==*it.idx;
      }
      inline bool operator < (const iterator& it) const {
         return *idx<*it.idx;
      }
      inline bool operator <= (const iterator& it) const {
         return *idx<=*it.idx;
      }
      inline bool operator > (const iterator& it) const {
         return *idx>*it.idx;
      }
      inline bool operator >= (const iterator& it) const {
         return *idx>=*it.idx;
      }
   private:

      iterator(I *idxs, T *vals) {
         val =vals;
         idx = idxs;
      }

      T *val;
      I *idx;

      friend class SparseVector<T,I>;
   };

   iterator begin() {
      return iterator(idxs, vals);
   }

   iterator end() {
      return iterator(idxs+Used, vals+Used);
   }

   /////////////////////////
   // Overloaded operators
   /////////////////////////

private:


   // this constructor should be used with care
   SparseVector() {
   }

   inline void Destroy() {
      delete idxs;
      if(vals!=NULL)
         delete vals;

      vals = NULL;
      idxs = NULL;
      Used = 0;
   }

   ////////////////////////////////////////////////////////////////
   // Initialize routines (used by constructors and Set() routines)
   ////////////////////////////////////////////////////////////////

   // construct an "empty" sparse vector
   inline void Initialize(uint32 m) {
      Used    = 0;
      Length  = m;
      idxs    = new I[1];
      idxs[0] = MaxIndex(I);
      vals    = NULL;
   }

   // initialize from a list of int/double (index, value) pairs
   inline void Initialize(uint32 m, uint32 used, int *ir, double *pr) {
      assert(used <= m);

      Length = m;
      Used   = used;

      idxs = new I[Used+1];
      vals = new T[Used];

      // cannot use memcpy b/c their might be a conversion
      for(int j=0; j < Used; j++) {
         idxs[j] = (I)ir[j];
         vals[j] = (T)pr[j];
      }

      idxs[Used] = MaxIndex(I);
   }

   inline void Initialize(uint32 m, int32 num, T *pr, I *ir) {
      Used = num;
      Length = m;

      idxs = new I[Used+1];
      vals = new T[Used];

      memcpy(idxs, ir, sizeof(I)*Used);
      memcpy(vals, pr, sizeof(T)*Used);

      idxs[Used] = MaxIndex(I);
   }

   inline void Initialize(uint32 m, T *buffer, double threshold) {
      Length = m;

      // count length
      Used = 0;
      for(uint32 j=0; j < m; j++)
         if(fabs((double)buffer[j]) > threshold) Used++;

      idxs = new I[Used+1];
      vals = new T[Used];

      // copy
      uint32 count = 0;
      for(uint32 j=0; j < m; j++)
         if(fabs((double)buffer[j]) > threshold) {
            assert(count < Used);
            idxs[count] = j;
            vals[count] = buffer[j];
            count++;
         }

      idxs[Used] = MaxIndex(I);
   }

   inline void Initialize(const SparseVector<T,I> &v) {
      Used   = v.Used;
      Length = v.Length;

      idxs = new I[Used+1];
      vals = new T[Used];

      memcpy(idxs, v.idxs, sizeof(I)*(Used+1));
      memcpy(vals, v.vals, sizeof(T)*(Used));
   }

   inline void Initialize(const SparseVector<T,I> *v) {
     Initialize(*v);
   }

   // initialize from an accumulator's buffers
   inline void Initialize(uint32 m, uint32 used, Accumulator<T,I> *acc) {
      Length = m;
      Used   = used;

      I *acc_idxs = acc->GetIdxs();
      T *acc_vals = acc->GetVals();

      idxs = new I[Used+1];
      vals = new T[Used];
      idxs[Used] = MaxIndex(I);

      for(int i=0; i < Used; i++) {
         I row = acc_idxs[i];
         idxs[i] = row;
         vals[i] = acc_vals[row];
      }

      QuickSort(idxs, vals, 0, Used-1);
   }

   /////////////////////
   // Friend Functions
   /////////////////////

   // These are functions that need to see the internals of SparseVector
   // for whatever reason

#if defined(__GNUC__)
   friend SparseMatrix<T,I> *Transpose<T,I>(const SparseMatrix<T,I> *A);
#elif defined(__MSVC__)
   friend SparseMatrix<T,I> *Transpose(const SparseMatrix<T,I> *A);
#endif

   // matrix operations
//   friend SparseMatrix<T,I> *Transpose(const SparseMatrix<T,I> *A);
  // friend SparseMatrix<T,I> *Multiply(SparseMatrix<T,I> *A, SparseMatrix<T,I> *B);
   //friend SparseMatrix<T,I> *PseudoTranspose(const SparseMatrix<T,I> *A);

   // friend classes
   friend class SparseMatrix<T,I>;
   //friend class InteractionMatrix<T,I>;
   // friend class GramInteractions<T,I>;

   //////////////
   // Variables
   //////////////

   uint32 Length;    // length of the vector -- i.e. maximum number of elements
   uint32 Used;      // number of nonzero entries

   I *idxs;          // list of nonzero entries
   T *vals;          // value of each entry
};


// T InnerProduct(const SparseVector<T,I> *x, const SparseVector<T,I> *y)
//
// Return the (Euclidean) inner product <x, y>.
//
// Error handling:      assertions only

template<class T, class I>
inline T InnerProduct(SparseVector<T,I> *x,  SparseVector<T,I> *y)
{
   assert(x->GetLength()==y->GetLength());

   typename SparseVector<T,I>::iterator xiter = x->begin();
   typename SparseVector<T,I>::iterator yiter = y->begin();

   // check for zero vectors
   if(xiter.EndOfList() || yiter.EndOfList())
      return 0.0;

   T sum = 0.0;
   while(!xiter.EndOfList()) {

      while(yiter < xiter) yiter++;

      if(yiter==xiter)  {
         sum+=(*xiter)*(*yiter);
         yiter++;
      }

      xiter++;
   }

   return sum;
}

// T NormSquared(SparseVector<T,I> *x)
//
// Return the square of the l^2 norm of the sparse vector; that is, the
// sum of the squares of the entries of x.
//
// Error handling:      none

template<class T, class I>
inline T NormSquared(SparseVector<T,I> *x)
{
   T sum = 0;
   typename SparseVector<T,I>::iterator iter = x->begin();

   while(!iter.EndOfList()) {
      sum+=pow(*iter, 2.0);
      iter++;
   }

   return sum;
}

// T Norm(SparseVector<T,I> *x)
//
// Return the l^2 norm of the sparse vector; that is, the square root of the
// sum of the squares of the entries of x.
//
// Error handling:      none

template<class T, class I>
inline T Norm(SparseVector<T,I> *x)
{
   return sqrt(NormSquared(x));
}

// T L1Norm(SparseVector<T,I> *x)
//
// Return the l^1 norm of the sparse vector; that is, the sum of the absolute
// values of the entries of x.
//
// Error handling:      none

template<class T, class I>
inline T L1Norm(SparseVector<T,I> *x)
{
   T sum = 0;
   typename SparseVector<T,I>::iterator iter = x->begin();

   while(!iter.EndOfList()) {
      sum+=abs(*iter);
      iter++;
   }

   return sum;

}

// void ScaleVector(SparseVector<T,I> *x, T alpha)
//
// Perform scalar multiplication on the specified vector; that is, perform
// the operation: x = alpha * x.
//
// Error handling:      none

template<class T, class I>
inline void ScaleVector(SparseVector<T,I> *x, T alpha)
{
   typedef typename SparseVector<T,I>::iterator sv_iterator;
   for(sv_iterator iter = x->begin(); iter < x->end(); iter++)
      *iter*=alpha;
}

// SparseVector<T,I> *VectorSum(T a, SparseVector<T,I> *x, T b,
//    SparseVector<T,I> *y, Accumulator<T,I> *acc)
//
// Return the vector sum a*x+b*y.  This routine needs an auxillary accumulator
// to do its work of the same length as the vectors.
//
// Error handling:      assertions only

template <class T, class I>
SparseVector<T,I> *VectorSum(T a, SparseVector<T,I> *x, T b, SparseVector<T,I> *y,
   Accumulator<T,I> *acc)
{
   assert(x->GetLength() == y->GetLength());
   assert(x->GetLength() <= acc->GetLength());

   typename SparseVector<T,I>::iterator xiter = x->begin();
   typename SparseVector<T,I>::iterator yiter = y->begin();

   // check for zero vector
   if(yiter.EndOfList()) {
      SparseVector<T,I> *out = new SparseVector<T,I>(x);
      ScaleVector(out, a);
      return out;
   }

   if(xiter.EndOfList()) {
      x->Set(y);
      ScaleVector(x, b);
      return;
   }

   I *acc_idxs = acc->GetIdxs();
   T *acc_vals = acc->GetVals();

   register uint32 index = 0;

   while(!xiter.EndOfList() || !yiter.EndOfList()) {

      if(xiter==yiter) {
         acc_idxs[index] = xiter.GetIndex();
         acc_vals[index] = a*(*xiter)+b*(*yiter);
         xiter++;
         yiter++;
      } else if(xiter < yiter) {
         acc_idxs[index] = xiter.GetIndex();
         acc_vals[index] = a*(*xiter);
         xiter++;
      } else {
         acc_idxs[index] = yiter.GetIndex();
         acc_vals[index] = b*(*yiter);
         yiter++;
      }

      index++;

  }

  return new SparseVector<T,I>(x->GetLength(), index, acc_idxs, acc_vals);
}

// void PlusEqual(SparseVector<T,I> *x, T b, SparseVector<T,I> *y,
//    Accumulator<T,I> *acc)
//
// Performs the operation x = x + a*y.  This entails slightly less overhead
// than using the vector Set() method and the VectorSum function.
//
// Error handling:      assertions only

template<class T, class I>
void PlusEqual(SparseVector<T,I> *x, T b, SparseVector<T,I> *y,
    Accumulator<T,I> *acc)
{
   assert(x->GetLength() == y->GetLength());
   assert(x->GetLength() <= acc->GetLength());

   typename SparseVector<T,I>::iterator xiter = x->begin();
   typename SparseVector<T,I>::iterator yiter = y->begin();

   // check for zero vector
   if(yiter.EndOfList())
      return;

   if(xiter.EndOfList()) {
      x->Set(y);
      ScaleVector(x, b);
      return;
   }

   I *acc_idxs = acc->GetIdxs();
   T *acc_vals = acc->GetVals();

   register uint32 index = 0;

   while(!xiter.EndOfList() || !yiter.EndOfList()) {

      if(xiter==yiter) {
         acc_idxs[index] = xiter.GetIndex();
         acc_vals[index] = *xiter+b*(*yiter);
         xiter++;
         yiter++;
      } else if(xiter < yiter) {
         acc_idxs[index] = xiter.GetIndex();
         acc_vals[index] = *xiter;
         xiter++;
      } else {
         acc_idxs[index] = yiter.GetIndex();
         acc_vals[index] = b*(*yiter);
         yiter++;
      }

      index++;

   }
   x->Set(index, acc_vals, acc_idxs);
}

// mixed full/sparse operations
//
// y = y + a*x
template<class T,class I>
void PlusEqual(T *y, T a, SparseVector<T,I> *x)
{
   SparseVector<T,I>::iterator iter = x->begin();
   while(!iter.EndOfList()) {
      y[iter.GetIndex()]+=a*(*iter);
      iter++;
   }

}

template<class T,class I>
T InnerProduct(T *y, SparseVector<T,I> *x)
{
   T sum = 0.0;
   SparseVector<T,I>::iterator iter = x->begin();
   while(!iter.EndOfList()) {
      sum+=(y[iter.GetIndex()]*(*iter));
      iter++;
   }
   return sum;
}

#endif
