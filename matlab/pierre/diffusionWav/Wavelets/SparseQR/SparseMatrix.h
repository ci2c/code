// SparseMatrix.h
//
// Contains the SparseMatrix<T,I> class for storing a sparse matrix as a
// collection of sparse vectors, one for each column of the matrix.
//
// Dependencies:        Basic.h, QuickSort.h, SparseVector.h
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#if !defined(SPARSEMATRIX__H)
#define SPARSEMATRIX__H

#include "SparseVector.h"

#include <vector>
using std::vector;

#if defined(__GNUC__)
#define strcmpi strcasecmp
#endif

// forward declarations
template<class T, class I>
SparseMatrix<T,I> *Multiply(SparseMatrix<T,I> *A, SparseMatrix<T,I> *B);

template<class T, class I>
SparseVector<T,I> *Apply(SparseMatrix<T,I> *A, SparseVector<T,I> *x);

//template<class T, class I>
//class InteractionMatrix;

// class SparseMatrix<T,I>
//
// This is a container clas for SparseVector<T,I> which stores a sparse matrix
// as a collection of sparse vectors, one for each column of the matrix.

template<class T, class I>
class SparseMatrix
{
public:

   typedef SparseVector<T,I>* sc_ptr;            // sparse column pointer type
   typedef typename SparseVector<T,I>::iterator sc_iter;  // sparse column iterator

   ////////////////////////////////
   // Constructors and destructor
   ////////////////////////////////

   // construct the MxN zero matrix
   SparseMatrix(uint32 m, uint32 n) {
      M = m; N = n;
      sc.resize(N);
      // initialize empty sparse vectors
      for(int j=0; j < N; j++)
         sc[j] = new SparseVector<T,I>(M);
      acc = new Accumulator<T,I>(M);
   }

   // construct a MxN matrix of a special type
   SparseMatrix(int m, int n, const char *type, ...) {
      if(strcmpi(type, "Identity")==0) {
         M = m;
         N = n;

         // allocate storage for the sparse vectors
         sc.resize(N);

         double val = 1.0;
         for(int j=0; j < min(N,M); j++)
            sc[j] = new SparseVector<T,I>(M, 1, &j, &val);

      } else if(strcmpi(type, "Laplacian")==0) {
         M = N = n;  // force square

         // allocate storage for the sparse vectors
         sc.resize(N);

         int idxs[3];
         double vals[3];

         for(int j=1; j < N-1; j++) {
            idxs[0] = (I)j-1;
            idxs[1] = (I)j;
            idxs[2] = (I)j+1;
            vals[0] = .25;
            vals[1] = .5;
            vals[2] = .25;

            sc[j] = new SparseVector<T,I>(M, 3, idxs, vals);
         }

         idxs[0] = (I)0;
         idxs[1] = (I)1;
         idxs[2] = (I)N-1;
         vals[0] = .5;
         vals[1] = .25;
         vals[2] = .25;
         sc[0] = new SparseVector<T,I>(M, 3, idxs, vals);

         idxs[0] = (I)0;
         idxs[1] = (I)N-2;
         idxs[2] = (I)N-1;
         vals[0] = .25;
         vals[1] = .25;
         vals[2] = .5;
         sc[N-1] = new SparseVector<T,I>(M, 3, idxs, vals);
      } else
         throw 0; // whoops ... invalid type

      acc = new Accumulator<T,I>(M);
   }

   // "copy" constructor
   SparseMatrix(SparseMatrix *A) {
      M = A->GetM(); N = A->GetN();
      sc.resize(N);
      // initialize empty sparse vectors
      for(int j=0; j < N; j++)
         sc[j] = new SparseVector<T,I>(A->sc[j]);
      acc = new Accumulator<T,I>(M);
   }


#if defined(MATLAB_SUPPORT)

   // load from a matlab array
   SparseMatrix(const mxArray *matlab_array) {
      if(mxIsSparse(matlab_array)) {

         M = mxGetM(matlab_array);
         N = mxGetN(matlab_array);

         int *ir = mxGetIr(matlab_array);
         int *jc = mxGetJc(matlab_array);
         double *pr = mxGetPr(matlab_array);

         // allocate pointers to the sparse columns
         sc.resize(N);

         // initialize each column
         for(int j=0; j < N; j++)
            sc[j] = new SparseVector<T,I>(M, jc[j+1]-jc[j], ir+jc[j], pr+jc[j]);

      } else {throw 0; }

      // allocate the accumulator
      acc = new Accumulator<T,I>(M);
   }
#endif

   ~SparseMatrix() {
      for(int j=0; j < N; j++)
         delete sc[j];
      delete acc;
   }

   ////////////////////
   // MATLAB routines
   ////////////////////
#if defined(MATLAB_SUPPORT)
   // return matlab sparse matrix
   mxArray *GetMx() {
      uint64 nnz = GetNNZ();
      mxArray *mx = mxCreateSparse(GetM(), GetN(), (int)nnz, mxREAL);

      int *ir = mxGetIr(mx);
      int *jc = mxGetJc(mx);
      double *pr = mxGetPr(mx);

      jc[0] = 0;
      int index = 0;

      // fill it in
      for(int j=0; j < GetN(); j++) {
         jc[j+1] = jc[j]+sc[j]->GetNNZ();
         sc_iter iter = sc[j]->begin();
         while(!iter.EndOfList()) {
            assert(index<nnz);
            ir[index]   = iter.GetIndex();
            pr[index++] = *iter;
            iter++;
         }
      }
      return mx;
   }
#endif

   ///////////////////////////
   // Elementwise operations
   //////////////////////////



   /////////////////////
   // Column Operations
   /////////////////////

   // return a sparse vector pointing to column x
   inline SparseVector<T,I> *GetColumn(int x) {
      assert(x>=0 && x<=N);
      return sc[x];
   }

   // replace a sparse column
   inline void SetColumn(int x, SparseVector<T,I> *col) {
      assert(x>=0 && x<=N);
      sc[x]->Set(col);
   }

   // select a subset of the columns
   void PermuteColumns(const vector<I> &columns) {
      assert(columns.size() <= N);

      vector<sc_ptr> oldsc(sc);

      sc.resize(columns.size());

      for(int j=0; j < columns.size(); j++) {
         sc[j] = oldsc[columns[j]];
         oldsc[j] = NULL;
      }

      for(int j=0; j < N; j++)
         if(oldsc[j]!=NULL)
            delete oldsc[j];

      N = columns.size();
   }

   // A = A(:, 1:Columns)
   void Truncate(int Columns) {
      assert(Columns <= N);

      vector<sc_ptr> oldsc(sc);

      sc.resize(Columns);

      for(int j=0; j < Columns; j++) {
         sc[j] = oldsc[j];
         oldsc[j] = NULL;
      }

      for(int j=0; j < N; j++)
         if(oldsc[j]!=NULL)
            delete oldsc[j];

      N = Columns;
   }

   // truncate the rows
   void TruncateRows(int Rows) {

      for(int j=0; j < N; j++) {
         assert(sc[j]->idxs[sc[j]->Used-1] < Rows);
         sc[j]->Length = Rows;
         M = Rows;
      }
   }

   ///////////////////////////////
   // Matrix information routines
   ///////////////////////////////

   inline uint32 GetM() const { return M; }     // return number of rows
   inline uint32 GetN() const { return N; }     // return number of columns

   // return the number of nonzero entries ... this takes O(N) operations
   inline uint64 GetNNZ() const {
      uint64 nnz = 0;
     for(int j=0; j < N; j++)
         nnz+=(uint64)sc[j]->GetNNZ();
      return nnz;
   }

   // return number of bytes used to store the matrix
   //inline uint64 GetSize() const {
     // uint64 nnz = GetNNZ();
      //return sizeof(SparseMatrix<T,I>) + sizeof(SparseVector<T,I>)*N + (nnz+1)*sizeof(I) +
        // nnz*sizeof(T) + M*sizeof(T) + (M+1)*sizeof(I);
   //}

   /////////////////////////
   // Overloaded operators
   /////////////////////////

   inline SparseVector<T,I>* operator () (int index) {
      return GetColumn(index);
   }

   //SparseVector<T,I>* operator () (int index) {
      //return GetColumn(index);
   //}

   Accumulator<T,I> *GetAcc() {
      return acc;
   }
private:

#if defined(__MSVC__)
   friend SparseMatrix<T,I> *Transpose(const SparseMatrix<T,I> *A);
   friend SparseMatrix<T,I> *Multiply(SparseMatrix<T,I> *A, SparseMatrix<T,I> *B);
   friend SparseVector<T,I> *Apply(SparseMatrix<T,I> *A, SparseVector<T,I> *x);
   friend SparseVector<T,I> *Apply(SparseMatrix<T,I> *A, uint32 used, T *vals, I *idxs);

#elif defined(__GNUC__)
   friend SparseMatrix<T,I> *Transpose<T,I>(const SparseMatrix<T,I> *A);
   friend SparseMatrix<T,I> *Multiply<T,I>(SparseMatrix<T,I> *A, SparseMatrix<T,I> *B);
   friend SparseVector<T,I> *Apply<T,I>(SparseMatrix<T,I> *A, SparseVector<T,I> *x);
   friend SparseVector<T,I> *Apply<T,I>(SparseMatrix<T,I> *A, uint32 used, T *vals, I *idxs);
#endif

   // use this constructor with care ... you must properly initialize everything
   // before the destructor gets called
   SparseMatrix() {
   }

   // this is a utility rotuine to help initialize the matrix if you do
   // use the default constructor
   void Allocate(int m, int n) {
      M = m; N = n;
      sc.resize(N);
      acc = new Accumulator<T,I>(M);
   }

   uint32 M;      // number of rows
   uint32 N;      // number of columns

   vector<sc_ptr> sc;
   Accumulator<T,I> *acc;
};


// SparseMatrix *Transpose(SparseMatrix *A)
//
// Return the transpose of the matrix A.  This requires two passes over each
// element in the matrix A, the first to determine the correct sparse structure
// for A' and the second to copy the entries into the correct positions.
//
// Transpose is one of the few routines that requires access to private
// fields in SparseMatrix and in SparseVector.

template<class T, class I>
SparseMatrix<T,I> *Transpose(const SparseMatrix<T,I> *A)
{
   int M = A->GetM();
   int N = A->GetN();

   // construct the zero matrix (for now)
   SparseMatrix<T,I> *AT = new SparseMatrix<T,I>();

   // initialize transpose matrix
   AT->Allocate(N, M);

   // First pass: count the number of entries in each row
   for(int j=0; j < M; j++) {
      AT->sc[j] = new SparseVector<T,I>();
      AT->sc[j]->Used = 0;
   }

   for(int j=0; j < N; j++) {
      for(int i=0; i < A->sc[j]->Used; i++) {
         int row = (int)A->sc[j]->idxs[i];
         assert(row < AT->N);
         AT->sc[row]->Used++;
      }
   }

   // reallocate each column of AT
   for(int j=0; j < M; j++) {
      AT->sc[j]->Length = 0; // we will use this as a counter
      int Used = (int)AT->sc[j]->Used;
      AT->sc[j]->idxs = new I[Used+1];
      AT->sc[j]->vals = new T[Used];
      AT->sc[j]->idxs[Used] = MaxIndex(I);
   }

   // Second pass: copy the entries into A'
   for(int j=0; j < N; j++) {
      for(int i=0; i < A->sc[j]->Used; i++) {
         int row = A->sc[j]->idxs[i];
         assert(row < AT->N);
         int index = AT->sc[row]->Length++;

         assert(index < AT->sc[row]->Used);
         AT->sc[row]->idxs[index] = j;
         AT->sc[row]->vals[index] = A->sc[j]->vals[i];
      }
   }

   for(int j=0; j < M; j++)
      AT->sc[j]->Length = N;

   return AT;
}

// SparseMatrix *Multiply(SparseMatrix *A, SparseMatrix *B)
//
// Return the matrix product AB.  This operation is O(N*M) where N is the
// number of nonzero entries in A and M the number of nonzero entries in B.
// This is an unoptimized implementation that could be significantly imporved.
// It does, however, seem to be faster than Matlab 7.01's implementation ...
// although this doesn't say much.

template<class T, class I>
SparseMatrix<T,I> *Multiply(SparseMatrix<T,I> *A, SparseMatrix<T,I> *B)
{
   // make sure dimensions match
   assert(A->GetN() == B->GetM());

   int M = A->GetM();
   int K = A->GetN();
   int N = B->GetN();

   // allocate the product matrix
   SparseMatrix<T,I> *AB = new SparseMatrix<T,I>(M,N);

   // do computations in the matrix A's accumulator
   T *val_buffer = A->acc->GetVals();
   I *idx_buffer = A->acc->GetIdxs();
   uint32 *flag_buffer = A->acc->GetFlags();

   // compute the product
   for(int j=0; j < N; j++) {
      // compute A*B(:,j)
      int index = 0;

      typename Accumulator<T,I>::flag_type flag = A->acc->GetFlag();

      typename SparseVector<T,I>::iterator Biter = B->sc[j]->begin();
      while(!Biter.EndOfList()) {
         int col = Biter.GetIndex();
         T   val = *Biter;

         assert(0 <= col && col < A->N);
         typename SparseVector<T,I>::iterator Aiter = A->sc[col]->begin();
         while(!Aiter.EndOfList()) {
            I row = Aiter.GetIndex();
            T alpha = val*(*Aiter);

            if(flag_buffer[row]!=flag) {
               val_buffer[row]     = alpha;
               flag_buffer[row]    = flag;
               idx_buffer[index++] = row;
            } else
               val_buffer[row]+=alpha;

            Aiter++;
         }

         Biter++;
      }
      // copy out of accumulator
      AB->sc[j]->Set(M, index, A->acc);
   }

   return AB;
}

// SparseVector<T,I> *Apply(SparseMatrix<T,I> *A, SparseVector<T,I> *x)
//
//

template<class T, class I>
SparseVector<T,I> *Apply(SparseMatrix<T,I> *A, SparseVector<T,I> *x)
{
   // make sure dimensions match
   assert(A->GetN() == x->GetLength());

   int M = A->GetM();
   int K = A->GetN();

   // do computations in the matrix A's accumulator
   T *val_buffer = A->acc->GetVals();
   I *idx_buffer = A->acc->GetIdxs();
   uint32 *flag_buffer = A->acc->GetFlags();

   int index = 0;

   typename Accumulator<T,I>::flag_type flag = A->acc->GetFlag();

   typename SparseVector<T,I>::iterator xiter = x->begin();
   while(!xiter.EndOfList()) {
      int col = xiter.GetIndex();
      T   val = *xiter;

      assert(0 <= col && col < A->N);
      typename SparseVector<T,I>::iterator Aiter = A->sc[col]->begin();
      while(!Aiter.EndOfList()) {
         I row = Aiter.GetIndex();
         T alpha = val*(*Aiter);

         if(flag_buffer[row]!=flag) {
            val_buffer[row]     = alpha;
            flag_buffer[row]    = flag;
            idx_buffer[index++] = row;
         } else
            val_buffer[row]+=alpha;

         Aiter++;
      }

      xiter++;
   }

   // copy out of accumulator
   return new SparseVector<T,I>(M, index, A->acc);
}

template<class T, class I>
SparseVector<T,I> *Apply(SparseMatrix<T,I> *A, uint32 used, T *vals, I *idxs)
{
   // make sure dimensions match
   //assert(A->GetN() == x->GetLength());

   int M = A->GetM();
   int K = A->GetN();

   // do computations in the matrix A's accumulator
   T *val_buffer = A->acc->GetVals();
   I *idx_buffer = A->acc->GetIdxs();
   uint32 *flag_buffer = A->acc->GetFlags();

   int index = 0;

   typename Accumulator<T,I>::flag_type flag = A->acc->GetFlag();

   //typename SparseVector<T,I>::iterator xiter = x->begin();
   for(int i=0; i < used; i++) {
   //while(!xiter.EndOfList()) {
      int col = idxs[i];//xiter.GetIndex();
      T   val = vals[i];

      assert(0 <= col && col < A->N);
      typename SparseVector<T,I>::iterator Aiter = A->sc[col]->begin();
      while(!Aiter.EndOfList()) {
         I row = Aiter.GetIndex();
         T alpha = val*(*Aiter);

         if(flag_buffer[row]!=flag) {
            val_buffer[row]     = alpha;
            flag_buffer[row]    = flag;
            idx_buffer[index++] = row;
         } else
            val_buffer[row]+=alpha;

         Aiter++;
      }

      //xiter++;
   }

   // copy out of accumulator
   return new SparseVector<T,I>(M, index, A->acc);
}

// x = x + alpha*Ay (full x, full y)
template<class T, class I>
void *PlusEqualAy(double *x, T alpha, SparseMatrix<T,I> *A, double *y)
{

}

// x = x + alpha*Ay (sparse x, sparse y)
template<class T, class I>
void PlusEqualAy(SparseVector<T,I> *x, T alpha, SparseMatrix<T,I> *A,
   SparseVector<T,I> *y, Accumulator<T,I> *Acc)
{
   SparseVector<T,I> *temp = Apply(A, y);
   PlusEqual(x, alpha, temp, Acc);
   delete temp;
}

template<class T, class I>
void PlusEqualAy(SparseVector<T,I> *x, T alpha, SparseMatrix<T,I> *A,
   int used, T *ip_vals, I *ip_idxs, Accumulator<T,I> *Acc)
{
   SparseVector<T,I> *temp = Apply(A, used, ip_vals, ip_idxs);
   PlusEqual(x, alpha, temp, Acc);
   delete temp;
}

#endif

