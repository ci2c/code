// InteractionMatrix.h
//
// This is the code which keeps track of "interactions" between columns of
// the matrices during the Gram-Schmidt algorithm.  For each column in the
// matrix A it stores the list of columns in A and Q which have overlapping
// support.
//
// It essentially a version of the Gram matrix without entries.  (One could
// do Gram-Schmidt by performing column ops on the Gram matrix but the
// inner products loss accuracy over time).
//
// Dependencies:        SparseVector.h, SparseMatrix.h
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#if !defined(INTERACTIONMATRIX__H)
#define INTERACTIONMATRIX__H

#include "SparseMatrix.h"

#include <vector>
using std::vector;

// class InteractionMatrix<T,I>
//
// This keeps track of which columns of A and Q overlap the support of a
// particular column of A.

template<class T, class I>
class InteractionMatrix
{
public:

   ////////////////////////////////
   // Constructors and destructor
   ////////////////////////////////

   // build interaction lists ... this is approximately as expensive
   // as computing A'*A
   InteractionMatrix(SparseMatrix<T,I> * A) {
      M = A->GetM();
      N = A->GetN();

      // allocate list of lists
      N = A->GetN();
      ALists.resize(N);
      QLists.resize(N);

      // allocate & initialize accumulator
      acc_flags.resize(M);
      acc_idxs.resize(M);

      for(int j=0; j < M; j++)
         acc_flags[j] = 0;

      CurrentFlag = 1;

      // compute transpose ... we could make a (slightly) more efficient
      // specialized function which doesn't bother to copy the entries
      SparseMatrix<T,I> *AT = Transpose(A);

      // for each j, compute the product AT * A(:,j)
      for(int j=0; j < N; j++) {
         // traverse A(:,j)
         typename SparseVector<T,I>::iterator Aiter = A->GetColumn(j)->begin();

         uint32 flag = GetFlag();
         uint32 index = 0;

         while(!Aiter.EndOfList()) {
            uint32 col = (uint32) Aiter.GetIndex();
            typename SparseVector<T,I>::iterator ATiter = AT->GetColumn(col)->begin();
            while(!ATiter.EndOfList()) {
               uint32 row = (uint32) ATiter.GetIndex();
               if(acc_flags[row]!=flag && row!=j) {
                  acc_idxs[index] = row;
                  acc_flags[row] = flag;
                  index++;
               }
               ATiter++;
            }

            Aiter++;
         }

         // initialize the interaction lists for column j
         ALists[j].resize(index);
         for(int i=0; i < index; i++)
            ALists[j][i] = acc_idxs[i];

         // make sure Qlist is 0 length
         QLists[j].resize(0);
      }

      delete AT;
   }

   ~InteractionMatrix() {
   }

   // move column from the A matrix to Q
   void MoveColumnToQ(uint32 qcol, uint32 newqidx) {

      // iterate through each column in Q's list
      for(int j=0; j < ALists[qcol].size(); j++) {
         uint32 acol = ALists[qcol][j];

         // merge the AList of acol with the AList of qcol
         uint32 index = 0;
         uint32 flag  = GetFlag();

         // move the AList of qcol into the accumulator
         for(int i=0; i < ALists[qcol].size(); i++) {
            uint32 col = ALists[qcol][i];
            if(col!=acol) {
               acc_flags[col] = flag;
               acc_idxs[index++] = col;
            }
         }

         // move the AList of acol into the accumulator
         for(int i=0; i < ALists[acol].size(); i++) {
            uint32 col = ALists[acol][i];
            if(acc_flags[col] != flag && col!=qcol)
               acc_idxs[index++] = col;
         }

         // now form the new AList
         ALists[acol].resize(index);
         for(int i=0; i < index; i++)
            ALists[acol][i] = acc_idxs[i];
      }

      // NOW merge Q lists
      for(int j=0; j < ALists[qcol].size(); j++) {
         uint32 acol = ALists[qcol][j];

         // merge the QList of acol with the QList of qcol
         uint32 index = 0;
         uint32 flag  = GetFlag();

         // move the QList of qcol into the accumulator
         for(int i=0; i < QLists[qcol].size(); i++) {
            uint32 col = QLists[qcol][i];
            acc_flags[col] = flag;
            acc_idxs[index++] = col;
         }

         // move the QList of acol into the accumulator
         for(int i=0; i < QLists[acol].size(); i++) {
            uint32 col = QLists[acol][i];
            if(acc_flags[col] != flag)
               acc_idxs[index++] = col;
         }

         acc_idxs[index++] = newqidx;

         // now form the new QList
         QLists[acol].resize(index);
         for(int i=0; i < index; i++)
            QLists[acol][i] = acc_idxs[i];
      }

      // get rid of qcol's lists
      //ALists[qcol].resize(0);
      //QLists[qcol].resize(0);
   }

   ///////////////////////////////////
   // Get functions
   //////////////////////////////////

   // typedef to make life easier
   typedef vector<I> list_type;

   inline list_type GetAList(int column) {
      return ALists[column];
   }

   inline list_type GetQList(int column) {
      return QLists[column];
   }

private:

   uint32 GetFlag() {
      return CurrentFlag++;
   }

   uint32 CurrentFlag;
   uint32 N;                     // number of columns of A
   uint32 M;
   vector<list_type> ALists;
   vector<list_type> QLists;

   // the accumulator
   vector<I> acc_idxs;
   vector<uint32> acc_flags;
};

#endif
