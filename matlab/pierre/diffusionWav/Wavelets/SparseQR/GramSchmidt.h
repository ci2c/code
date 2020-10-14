// GramSchmidt.h
//
// This is the code for performing modified Gram-Schmidt orthogonalization.
// It computes the matrices Q11, R11, and R12 in the full decomposition:
//
//    [A(:,Idxs) A(:,DIdxs)] = [Q11 Q12]  * [R11 R12]
//                                          [ 0  R22]
//
// This routine is a little messy as is.  In particular, some reworking
// of the sparse vector class could simplify the orthogonalization and
// reorthogonalization steps --- this code is quite messy and uses
// two accumulators.
//
// Dependencies:        Basic.h, QuickSort.h, Sparse.h, DynamicHeap.h
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#if !defined(GRAM__H)
#define GRAM__H
#include <stdlib.h>

#include <math.h>
#include "SparseMatrix.h"
#include "InteractionMatrix.h"
#include "DynamicHeap.h"
#include "HFTimer.h"

struct GramOptions {
   double IPThreshold;     // threshold for inner products to be considered zero

   // Reorthogonalization parameters
   bool Reorthogonalize;   // use select reorthogonalization
   // stopping conditions
   uint32 StopN;           // number of iteration stopping condition
   double StopPrecision;   // column l^2 norm stopping condition
   double StopDensity;     // column density stopping condition
};

template<class T, class I>
struct GramReturn {
   SparseMatrix<T,I> *Q11;
   SparseMatrix<T,I> *R11;
   SparseMatrix<T,I> *IR11;

   vector<I> Idxs;            // list of select indices (ordered by selection)
   vector<I> DIdxs;           // list of indices not selected, sorted
};

// return some statistics about the Gram process
template<class T, class I>
struct GramStats {
   uint32   Iterations;          // number of columns selected
   double   LastNorm;            // norm of first rejected column
   uint32   Reorthogonalizaed;   // number of reorthogonalizations

};

template<class T, class I>
void GramSchmidt(SparseMatrix<T, I> *InputA, GramOptions *Options,
   GramReturn<T,I> *Return)
{
   bool FallThrough = false;

   // make a copy of the input matrix
   SparseMatrix<T,I> *A = new SparseMatrix<T,I>(InputA);

   typedef InteractionMatrix<T,I>::list_type list_type;
   typedef InteractionMatrix<T,I>::list_type::iterator list_iterator;

   HFTimer timer;

   // setup some variables for the routine
   uint32 M = A->GetM();
   uint32 N = A->GetN();
   Accumulator<T,I> *Acc = new Accumulator<T,I>(M);
   bool *Chosen = new bool[N];  // marks whether a column has been chosen
   for(int j=0; j < N; j++)
      Chosen[j] = false;

   Return->Idxs.resize(N);
   uint32 NumChosen = 0;

   // initialize the heap used to select the columns of largest norm
   // on each iteration
   dprintf("Initialing column heap ... ");
   timer.Reset(); timer.Start();
   T *original_norms = new T[N];
   for(int j=0; j < N; j++)
      original_norms[j] = NormSquared(A->GetColumn(j));
   DynamicHeap<T> ColumnHeap(N, N, original_norms);
   timer.Stop();
   dprintf("%f ms\n", timer.GetElapsedTime());

   // initialize the interaction matrix
   dprintf("Constructing interaction matrix ... ");
   timer.Reset(); timer.Start();
   InteractionMatrix<T,I> *IMatrix = new InteractionMatrix<T,I>(A);
   timer.Stop();
   dprintf("%f ms\n", timer.GetElapsedTime());

   // create the matrix "Q" for storing chosen columns and the upper triangular
   // matrix "R"
   SparseMatrix<T,I> *Q = new SparseMatrix<T,I>(M, N);
   SparseMatrix<T,I> *R = new SparseMatrix<T,I>(N, N);

   I *ip_idxs = new I[N];//R->GetAcc()->GetIdxs();
   T *ip_vals = new T[N];//R->GetAcc()->GetVals();
   I *ip2_idxs = new I[N];
   T *ip2_vals = new T[N];

   HFTimer HeapTimer;
   HFTimer InteractTimer;
   HFTimer OpTimer;

   timer.Reset();
   timer.Start();
   dprintf("Gramm-schmidt ... ");

   dprintf("\n");

   printf("00000");
   // main loop
   for(int j=0; j < min(N, Options->StopN); j++) {


      if ( rand()/RAND_MAX > .8)
         printf("\b\b\b\b\b%05d", j);

      T HeapNorm;            // recorded norm of the column (on the heap)
      T ChosenNorm;          // recomputed norm of the chosen column
      int ChosenColumn;      // chosen column

      HeapTimer.Start();
      ColumnHeap.Extract(&HeapNorm, &ChosenColumn);
      HeapTimer.Stop();

      // compute the inner products Q'*A(:,ChosenColumn) in an accumulator
      uint32 index = 0;
      list_type QList = IMatrix->GetQList(ChosenColumn);
      for(list_iterator iter = QList.begin(); iter < QList.end(); iter++) {
         uint32 idx = *iter;
         OpTimer.Start();
         T ip = InnerProduct(Q->GetColumn(idx), A->GetColumn(ChosenColumn));
         OpTimer.Stop();

         if(fabs((double)ip) > Options->IPThreshold) {
            ip_idxs[index] = idx;
            ip_vals[index++] = ip;
         }
      }

      // Perform the operation Q(:,j) = A(:,ChosenColumn) - Q*ips
      OpTimer.Start();
      Q->GetColumn(j)->Set(A->GetColumn(ChosenColumn));
      PlusEqualAy(Q->GetColumn(j), -1.0, Q, index, ip_vals, ip_idxs, R->GetAcc());
      OpTimer.Stop();

      // Reorthogonalize (if necessary) ... a second projection
      if(Options->Reorthogonalize) {
          double ratio, threshold;

         // determine which criterion to use (prefer K)
/*         if(Options->K >= 0.0) {
            ratio = Norm(A->GetColumn(ChosenColumn)) /
                    Norm(Q->GetColumn(j));
            threshold = Options->K;
             dprintf("K");
         } else {
            // compute L^1 norm of temporary R(:,j)
            double sum = 0.0;
            for(int k=0; k < index; k++)
               sum+= fabs((double)ip_vals[k]);
            ratio = sum / (double)Norm(Q->GetColumn(j));
            threshold = Options->L;
            dprintf("L");
         }*/

//         dprintf(" ---> (%f) ", ratio );
//         if(ratio > threshold) {
            dprintf("!");
            // compute the inner products Q'*Q(:,j) in an new accumulator
            for(int i=0; i < index; i++) {
               uint32 idx = ip_idxs[i];
               OpTimer.Start();
               T ip = InnerProduct(Q->GetColumn(idx), Q->GetColumn(j));
               OpTimer.Stop();

               ip2_idxs[i] = idx;
               ip2_vals[i] = ip;
            }

            // Perform the operation Q(:,j) -=  Q*ips2
            //
            // This is a little wasteful as we make unnecessary copies
            // we should probably implement SparseVector - SparseMatrix*SparseVector
            OpTimer.Start();
            PlusEqualAy(Q->GetColumn(j), (T)-1.0, Q, index, ip2_vals, ip2_idxs,
               R->GetAcc());
            OpTimer.Stop();

            // update original ips
            for(int k=0; k < index; k++) {
              assert(ip_idxs[k]==ip2_idxs[k]);
              ip_vals[k]+=ip2_vals[k];
            }
  //        }
      }

      // Compute the norm and mark the column as chosen
      OpTimer.Start();
      ChosenNorm = Norm(Q->GetColumn(j));
      OpTimer.Stop();
      double ColumnDensity =(double)Q->GetColumn(j)->GetNNZ()/
         (double)Q->GetColumn(j)->GetLength();

       dprintf("  column %d with norm %g (HeapNorm = %g, difference =%g)\n", ChosenColumn, ChosenNorm,
         sqrt(HeapNorm), abs(sqrt(HeapNorm)-ChosenNorm));


      if(ChosenNorm < Options->StopPrecision ||
         ColumnDensity > Options->StopDensity)
       {
         Q->GetColumn(j)->Zero();      // don't return the column < Precision
         R->GetColumn(j)->Zero();
         break;
      }

      // mark the column as chosen
      Chosen[ChosenColumn] = true;
      NumChosen++;
      Return->Idxs[j] = ChosenColumn;

      // initialize R(:,j)
      ip_idxs[index] = j;
      ip_vals[index++] = ChosenNorm;
      R->GetColumn(j)->Set(index, ip_vals, ip_idxs);

      // normalize Q(:,j) and get rid of A(:,ChosenColumn)
      OpTimer.Start();
      ScaleVector(Q->GetColumn(j), 1/ChosenNorm);
      A->GetColumn(ChosenColumn)->Zero();
      OpTimer.Stop();

      // update interaction lists
      InteractTimer.Start();
      IMatrix->MoveColumnToQ(ChosenColumn, j);
      InteractTimer.Stop();

      // accumulator for R
      //I *Ridxs = R->GetAcc()->GetIdxs();
      //T *Rvals = R->GetAcc()->GetVals();
      //int Rcount = 0;

      // update inner products
      list_type AList = IMatrix->GetAList(ChosenColumn);
      for(list_iterator iter = AList.begin(); iter < AList.end(); iter++) {
         uint32 idx = *iter;

         OpTimer.Start();
         T ip = InnerProduct(A->GetColumn(idx), Q->GetColumn(j));
         OpTimer.Stop();

         HeapTimer.Start();
         T oldnorm;
         ColumnHeap.Lookup(idx, &oldnorm);   // find old norm
         ColumnHeap.Modify(idx, (T)fabs(oldnorm-(double)ip*(double)ip)); // replace it with new norm
         HeapTimer.Stop();

      }

   }
   printf("\b\b\b\b\b");

   delete IMatrix;

   timer.Stop();
   dprintf("%f ms\n", timer.GetElapsedTime());
   dprintf("Op time = %f\n", OpTimer.GetElapsedTime());
   dprintf("Interaction matrix time = %f\n", InteractTimer.GetElapsedTime());
   dprintf("Heap time = %f\n", HeapTimer.GetElapsedTime());

   Return->Idxs.resize(NumChosen);
   Return->DIdxs.resize(N-NumChosen);
   int count = 0;
   for(int j=0; j < N; j++)
      if(!Chosen[j]) Return->DIdxs[count++] = j;


   Return->Q11 = Q;
   Return->R11 = R;
   Return->Q11->Truncate(NumChosen);
   Return->R11->Truncate(NumChosen);
   Return->R11->TruncateRows(NumChosen);

   // compute R12 = Q'*A(:,DIdxs)
/*   Return->R12 = new SparseMatrix<T,I>(N, N-NumChosen);
   for(int j=0; j < Return->DIdxs.size(); j++) {
         uint32 idx = (uint32)Return->DIdxs[j];

         uint32 index = 0;
         list_type QList = IMatrix->GetQList(idx);
         for(list_iterator iter = QList.begin(); iter < QList.end(); iter++) {

            OpTimer.Start();
            T ip = (double)InnerProduct(Q->GetColumn(*iter), A->GetColumn(idx));
            OpTimer.Stop();

            if(fabs((double)ip) > Options->IPThreshold) {
               ip_idxs[index] = *iter;
               ip_vals[index++] = ip;
            }
         }

         Return->R12->GetColumn(j)->Set(index, ip_vals, ip_idxs);
   }*/

   //Return->R12->Truncate(Return->DIdxs.size());

   delete Acc;
   delete Chosen;
   delete A;
   delete original_norms;
   delete ip2_idxs;
   delete ip2_vals;
   delete ip_idxs;
   delete ip_vals;
}

#endif