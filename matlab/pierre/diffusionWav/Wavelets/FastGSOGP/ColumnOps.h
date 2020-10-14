// ColumnOps.h
//
// Implementations of the critical column operations for SparseCMatrix.
//
// Uses:
//    utils.h, SparseColumns.h, SparseCMatrix.h
//
// Source Control:
//    JCB   07/22/04   initial version
//
// To Do:
//    [-] All these if's for special cases are slow slow slow ... maybe split
//        into many functions (?) or use more sophisticated template mechanism (?)
//

#ifndef COLUMNOPS__H__JCB
#define COLUMNOPS__H__JCB

#include "utils.h"
#include "SparseColumn.h"
#include "SparseCMatrix.h"
#include <math.h>

/*
 * functions zeaxopby()
 *
 * Performs the operation M1(:,z) = a*M2(:,x) op b*M3(:,y) where op is any
 * binary operation such that op(0.0,0.0) = 0.0.  The template parameter
 * specifies the operation (make sure the functions are inline and the compiler
 * actually produces inline code or this will be SLOW ... you really need to
 * check with a disassembler because so many C++ compilers are pieces of crap).
 *
 * function sum_axopby()
 *
 * Returns the value sum(a*M1(:x) op b*M2(,y)).  This function can compute
 * norms and inner products and such.
 *
 * Note there are two different syntaxes for each operation: one for the general
 * case and one when the columns are all taken from the same matrix.
 *
 * Examples:
 *
 * zeaxopby<OpPlus>(M, 0, 1.0, 0, 2.0, 1, OpPlus())
 *
 * zeaxopby<OpPlus>(M, 0, a, 0, 0.0, 0, OpPlus()) multiplies the first column by the scalar a
 *
 * sum_axopby<OpMul>(M, 1.0, 4, 1.0, 4, OpMul()) computes the square of the l^2 norm of
 *    fifth column.
 *
 * sum_axopby<OpMul>(M, 1.0, 0, 1.0, 2, OpMul()) computes the inner product of the first
 *    and third rows.
 *
 * sum_axopby<OpAbs>(M, 1.0, 0, 0, 0.0, OpAbs()) computes the l^1 norm of the first column
 *
 * sum_axopby<OpCount>(M, 1.0, 2, 0, 0.0, OpCount()) computes the number of nonzero elements of
 *    column 3
 *
 *
 */
class OpPlus {
public:
   OpPlus() {;}
   static inline double op(double x,double y) { return (x+y); }
};

class OpMul {
public:
   OpMul() {;}
   static inline double op(double x,double y) { return x*y; }
};

class OpAbs {
public:
   OpAbs() {;}
   static inline double op(double x,double y) { return fabs(x) + fabs(y); }
};

class OpCount {
public:
   OpCount() {;};
   static inline double op(double x,double y) { return 1.0; /*(fabs(x) > 0.0) + (fabs(y) > 0.0);*/ }
};

template<class T>
void zeaxopby(SparseCMatrix &M1, int z, double a, const SparseCMatrix &M2, int x, double b, const SparseCMatrix &M3, int y, T op)
{
   Assert(M1.nRows == M2.nRows && M2.nRows == M3.nRows,
      "zeaxopby:: matrices have different heights.");
   Assert(z>= 0 && z<= M1.nCols && x >= 0 && x < M2.nCols && y>= 0 && y < M3.nCols,
      "zeaxopby:: out of bounds");
   Assert(M1.newidx!=NULL && M1.newval!=NULL, "zeaxopby: M1.newidx or M1.newval ==NULL");

   SparseColumn *Z = M1.sc[z];
   SparseColumn *X = M2.sc[x];
   SparseColumn *Y = M3.sc[y];
   int nRows = M1.nRows;

   // CASE: x = Op( a * x, 0.0)
   if(Z==X && b==0.0) {
      for(int i=0; i < X->Used; i++) {
         Assert(i < X->Used, "zeaxopby0");
         X->val[i] = T::op(a*X->val[i], 0.0);
      }
      return;
   }

   // CASE: y = Op(0, b*y)
   if(Z==Y && a==0.0) {
      for(int i=0; i < X->Used; i++) {
         Assert(i < Y->Used, "zeaxopby1");
         Y->val[i] = T::op(0.0, b*Y->val[i]);
      }
      return;
   }

   // if we get this far, we need to make a new column object
   int    *newidx = M1.newidx;    // use the matrices scratch buffers
   double *newval = M1.newval;
   int    count   = 0;            // count of new elements

   // z = Op(a*x, 0.0)
   if(b==0.0) {
      for(int i=0; i < X->Used; i++) {
         Assert(i < nRows, "zeaxopby2");
         Assert(i < X->Used, "zeaxopby3");

         newidx[i] = X->idx[i];
         newval[i] = T::op(a*X->val[i], 0.0);
      }
      count = X->Used;
   } else if(a==0.0) {  // z = Op(0.0, b*y)
      for(int i=0; i < Y->Used; i++) {
         Assert(i < nRows, "zeaxopby4");
         Assert(i < Y->Used, "zeaxopby5");

         newidx[i] = Y->idx[i];
         newval[i] = T::op(0.0, b*Y->val[i]);
      }
      count = Y->Used;
   } else if(X==Y) {
      for(int i=0; i < X->Used; i++) {
         Assert(i < nRows, "zeaxopby6");
         Assert(i < X->Used, "zeaxopby7");

         newidx[i] = X->idx[i];
         newval[i] = T::op(a*X->val[i], b*X->val[i]);
      }
      count = X->Used;
   } else {
      int list_pos1=0;
      int list_pos2=0;

      // this loop only works if the two columns are unequal
      while( (list_pos1 < X->Used) || (list_pos2 < Y->Used) ) {
         Y->idx[Y->Used]--;   // cheap little trick to avoid some comparisons
         while( X->idx[list_pos1] == Y->idx[list_pos2] ) {

            Assert(list_pos1 < X->Used, "zeaxopby8");
            Assert(list_pos2 < Y->Used, "zeaxopby9");
            Assert(count < nRows, "zeaxopby10");

            newval[count] = T::op(a*X->val[list_pos1], b*Y->val[list_pos2]);
            newidx[count] = X->idx[list_pos1];
            list_pos1++;
            list_pos2++;
            count++;
         }
         Y->idx[Y->Used]++;   // cheap little trick to avoid some comparisons

         Assert(list_pos1 < X->Used+1, "zeaxopby11");
         Assert(list_pos2 < Y->Used+1, "zeaxopby12");

         while( X->idx[list_pos1] < Y->idx[list_pos2] ) {
            Assert(list_pos1 < X->Used, "zeaxopby13");
            Assert(count < nRows, "zeaxopby14");

            newval[count] = T::op(a*X->val[list_pos1], 0.0);
            newidx[count] = X->idx[list_pos1];
            list_pos1++;
            count++;
         }
         Assert(list_pos1 < X->Used+1, "zeaxopby15");
         Assert(list_pos2 < Y->Used+1, "zeaxopby16");

         while( Y->idx[list_pos2] < X->idx[list_pos1] ) {
            Assert(list_pos2 < Y->Used, "zeaxopby17");
            Assert(count < nRows, "zeaxopby18");

            newval[count] = T::op(0.0, b*Y->val[list_pos2]);
            newidx[count] = Y->idx[list_pos2];
            list_pos2++;
            count++;
         }
      }
   }

   // make a new column, replacing the old
   delete M1.sc[z];
   M1.sc[z] = new SparseColumn(nRows, count, newidx, newval);
}

template<class T>
double sum_axopby(double a, const SparseCMatrix &M1, int x, double b, const SparseCMatrix &M2, int y, T optype)
{
   Assert(M1.nRows == M2.nRows, "sum_axopyby:: matrices have different heights");
   Assert(x >= 0 && x < M1.nCols && y>= 0 && y < M2.nCols, "sum_axopby:: out of bounds");
   double sum=0.0;

   SparseColumn *X = M1.sc[x];
   SparseColumn *Y = M2.sc[y];

   // first look at some special cases

   // a*OP(x,0.0)
   if(b==0.0) {
      for(int i=0; i < X->Used; i++) {
         Assert(i < X->Used, "sum_axopby0");
         sum+=T::op(a*X->val[i], 0.0);
      }
      return sum;
   }

   // b*OP(0.0,y)
   if(a==0.0) {
      for(int i=0; i < Y->Used; i++) {
         Assert(i < Y->Used, "sum_axopby1");
         sum+=T::op(0.0, b*Y->val[i]);
      }
      return sum;
   }

   // Op(a*x,b*x)
   if(X==Y) {
      for(int i=0; i < X->Used; i++) {
         Assert(i < X->Used, "sum_axopby2");
         sum+=T::op(a*X->val[i], b*X->val[i]);
      }
      return sum;
   }

   int list_pos1=0;
   int list_pos2=0;

   // this loop only works if the two columns are unequal
   while( (list_pos1 < X->Used) || (list_pos2 < Y->Used) ) {
      Y->idx[Y->Used]--;               // cheap little trick to avoid some comparisons
      while( X->idx[list_pos1] == Y->idx[list_pos2] ) {
         Assert(list_pos1 < X->Used && list_pos2 < Y->Used, "sum_axopby3");
         sum += T::op(a*X->val[list_pos1++], b*Y->val[list_pos2++]);
      }
      Y->idx[Y->Used]++;               // cheap little trick to avoid some comparisons

      Assert(list_pos1 <= X->Used+1, "sum_axopby4");
      Assert(list_pos2 <= Y->Used+1, "sum_axopby5");

      while( X->idx[list_pos1] < Y->idx[list_pos2] ) {
         Assert(list_pos1 < X->Used, "sum_axopby6");
         sum += T::op(a*X->val[list_pos1++], 0.0);
      }

      Assert(list_pos1 <= X->Used+1, "sum_axopby7");
      Assert(list_pos2 <= Y->Used+1, "sum_axopby8");

      while( Y->idx[list_pos2] < X->idx[list_pos1] ) {
         Assert(list_pos2 < Y->Used, "sum_axopby9");
         sum += T::op(0.0, b*Y->val[list_pos2++]);
      }
   }

   return sum;
}


template<class T>
inline double sum_axopby(const SparseCMatrix &M, double a, int x, double b, int y, T optype)
{
   return sum_axopby<T>(a, M, x, b, M, y, optype);
}

template<class T>
inline void zeaxopby(SparseCMatrix &M1, int z, double a, int x, double b, int y, T op)
{
   zeaxopby<T>(M1, z, a, M1, x, b, M1, y, op);
}


#endif