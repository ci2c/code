// Sparse.h
//
// Implementation of the primary sparse vector and matrix classes,
// SparseVector<T,I> and SparseMatrix<T,I>, vector and matrix operations,
//  and support routines.
//
// Dependencies:        Basic.h, QuickSort.h
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#if !defined(SPARSE__H)
#define SPARSE__H


// class SparseMatrix<T,I>
//
// This is a container clas for SparseVector<T,I> which stores a sparse matrix
// as a collection of sparse vectors, one for each column of the matrix.

template<class T, class I>
class SparseMatrix
{
public:

   ////////////////////////////////
   // Constructors and destructor
   ////////////////////////////////

   // construct the MxN zero matrix
   SparseMatrix(uint32 m, uint32 n) {
      M = m; N = n;

      sc = new SparseVector<T,I>[N];

      // initialize empty sparse vectors
      for(int j=0; j < N; j++)
         sc[j].Initialize(M);

      acc = new Accumulator<T,I>(M);
   }

   // construct a MxN matrix of a special type
   SparseMatrix(int m, int n, const char *type, ...) {
      if(strcmpi(type, "Identity")==0) {
         M = m;
         N = n;

         // allocate storage for the sparse vectors
         sc = new SparseVector<T,I>[N];

         double val = 1.0;
         for(int j=0; j < min(N,M); j++)
            sc[j].Initialize(M, 1, &j, &val);

      } else if(strcmpi(type, "Laplacian")==0) {
         M = N = n;  // force square

         // allocate storage for the sparse vectors
         sc = new SparseVector<T,I>[N];

         int idxs[3];
         double vals[3];

         for(int j=1; j < N-1; j++) {
            idxs[0] = (I)j-1;
            idxs[1] = (I)j;
            idxs[2] = (I)j+1;
            vals[0] = .25;
            vals[1] = .5;
            vals[2] = .25;

            sc[j].Initialize(M, 3, idxs, vals);
         }

         idxs[0] = (I)0;
         idxs[1] = (I)1;
         idxs[2] = (I)N-1;
         vals[0] = .5;
         vals[1] = .25;
         vals[2] = .25;
         sc[0].Initialize(M, 3, idxs, vals);

         idxs[0] = (I)0;
         idxs[1] = (I)N-2;
         idxs[2] = (I)N-1;
         vals[0] = .25;
         vals[1] = .25;
         vals[2] = .5;
         sc[N-1].Initialize(M, 3, idxs, vals);


      } else
         throw 0; // whoops ... invalid type

      acc = new Accumulator<T,I>(M);
   }

   ~SparseMatrix() {
      delete[] sc;   // make sure destructors are called
      delete acc;
   }

   ///////////////////
   // MATLAB Support
   ///////////////////

#if defined(MATLAB_SUPPORT)

   // load from a matlab array
   SparseMatrix(const mxArray *matlab_array) {

      if(mxIsSparse(matlab_array)) {

         M = mxGetM(matlab_array);
         N = mxGetN(matlab_array);

         int *ir = mxGetIr(matlab_array);
         int *jc = mxGetJc(matlab_array);
         double *pr = mxGetPr(matlab_array);

         sc = new SparseVector<T,I>[N];
         for(int j=0; j < N; j++)
            sc[j].Initialize(M, jc[j+1]-jc[j], ir+jc[j], pr+jc[j]);
      } else {
         throw 0;
      }

      acc = new Accumulator<T,I>(M);
   }

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
         jc[j+1] = jc[j]+sc[j].Used;

         for(int i=0; i < sc[j].Used; i++) {
            assert(index<nnz);
            ir[index]   = sc[j].idxs[i];
            pr[index++] = sc[j].vals[i];
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
      return &sc[x];
   }

   // replace a sparse column
   inline void SetColumn(int x, SparseVector<T,I> *col) {
      assert(x>=0 && x<=N);
      sc[x].Set(col);
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
         nnz+=(uint64)sc[j].GetLength();
      return nnz;
   }

   // return number of bytes used to store the matrix
   inline uint64 GetSize() const {
      uint64 nnz = GetNNZ();
      return sizeof(SparseMatrix<T,I>) + sizeof(SparseVector<T,I>)*N + (nnz+1)*sizeof(I) +
         nnz*sizeof(T) + M*sizeof(T) + (M+1)*sizeof(I);
   }


private:

   // use the default constructor with care ... you must initialize the
   // matrix properly before the destructor gets called
   SparseMatrix() {
   }

   // this will allocate space for the columns and the accumulator ... but
   // it does not initialize columns
   void Allocate(int m, int n) {
      M = m;
      N = n;

      sc = new SparseVector<T,I>[N];
      acc = new Accumulator<T,I>(M);
   }

   /////////////////////
   // Friend Functions
   /////////////////////
   friend SparseMatrix<T,I> *Transpose(const SparseMatrix<T,I> *A);
   friend SparseMatrix<T,I> *Multiply(SparseMatrix<T,I> *A, SparseMatrix<T,I> *B);
   friend SparseMatrix<T,I> *PseudoTranspose(const SparseMatrix<T,I> *A);
   friend class InteractionMatrix<T,I>;
   friend class GramInteractions<T,I>;


   uint32 M;      // number of rows
   uint32 N;      // number of columns

   SparseVector<T,I> *sc;
   Accumulator<T,I> *acc;
};

// SparseMatrix *Transpose(SparseMatrix *A)
//
// Return the transpose of the matrix A.  This requires two passes over each
// element in the matrix A, the first to determine the correct sparse structure
// for A' and the second to copy the entries into the correct positions.

template<class T, class I>
SparseMatrix<T,I> *Transpose(const SparseMatrix<T,I> *A)
{
   int N = A->GetN();
   int M = A->GetM();

   // allocate a new matrix
   SparseMatrix<T,I> *AT = new SparseMatrix<T,I>();

   // initialize transpose matrix
   AT->Allocate(N, M);

   // First pass: count the number of entries in each row
   for(int j=0; j < M; j++)
      AT->sc[j].Used = 0;

   for(int j=0; j < N; j++) {
      for(int i=0; i < A->sc[j].Used; i++) {
         int row = (int)A->sc[j].idxs[i];
         assert(row < AT->N);
         AT->sc[row].Used++;
      }
   }

   // allocate space for the entries of AT
   for(int j=0; j < M; j++) {
      AT->sc[j].Length = 0; // we will use this as a counter
      int Used = (int)AT->sc[j].Used;
      AT->sc[j].idxs = new I[Used+1];
      AT->sc[j].vals = new T[Used];
      AT->sc[j].idxs[Used] = MaxIndex(I);
   }

   // Second pass: copy the entries into A'
   for(int j=0; j < N; j++) {
      for(int i=0; i < A->sc[j].Used; i++) {
         int row = A->sc[j].idxs[i];
         assert(row < AT->N);
         int index = AT->sc[row].Length++;

         assert(index < AT->sc[row].Used);
         AT->sc[row].idxs[index] = j;
         AT->sc[row].vals[index] = A->sc[j].vals[i];
      }
   }

   for(int j=0; j < M; j++)
      AT->sc[j].Length = N;

   return AT;
}

// SparseMatrix *Multiply(SparseMatrix *A, SparseMatrix *B)
//
// Return the matrix product AB.  This operation is O(N*M) where N is the
// number of nonzero entries in A and M the number of nonzero entries in B.
// This is an unoptimized implementation that could be significantly imporved.

template<class T, class I>
SparseMatrix<T,I> *Multiply(SparseMatrix<T,I> *A, SparseMatrix<T,I> *B)
{
   // make sure dimensions match
   assert(A->GetN() == B->GetM());

   int M = A->GetM();
   int K = A->GetN();
   int N = B->GetN();

   // allocate the product matrix
   SparseMatrix<T,I> *AB = new SparseMatrix<T,I>;
   AB->Allocate(M, N);

   // do computations in the matrix A's accumulator
   T *val_buffer = A->acc->GetVals();
   I *idx_buffer = A->acc->GetIdxs();
   uint32 *flag_buffer = A->acc->GetFlags();

   // compute the product
   for(int j=0; j < N; j++) {
      // compute A*B(:,j)
      int index = 0;

      Accumulator<T,I>::flag_type flag = A->acc->GetFlag();

      for(int i=0; i < B->sc[j].Used; i++) {
         int col = (int)B->sc[j].idxs[i];
         T   val = B->sc[j].vals[i];

         assert(0 <= col && col < A->N);
         for(int k=0; k < A->sc[col].Used; k++) {
            I row = A->sc[col].idxs[k];
            T alpha = val*A->sc[col].vals[k];

            if(flag_buffer[row]!=flag) {
               val_buffer[row]     = alpha;
               flag_buffer[row]    = flag;
               idx_buffer[index++] = row;
            } else
               val_buffer[row]+=alpha;
         }
      }
      // copy out of accumulator
      AB->sc[j].Initialize(M, index, A->acc);
   }

   return AB;
}

// SparseMatrix *PseudoTranspose(SparseMatrix *A)
//
// Return the pseudo-transpose of the matrix A.

template<class T, class I>
SparseMatrix<T,I> *PseudoTranspose(const SparseMatrix<T,I> *A)
{
   // allocate a new matrix
   SparseMatrix<T,I> *AT = new SparseMatrix<T,I>();

   int N = A->GetN();
   int M = A->GetM();

   // initialize transpose matrix
   AT->Allocate(N, M);

   // First pass: count the number of entries in each row
   for(int j=0; j < M; j++)
      AT->sc[j].Used = 0;

   for(int j=0; j < N; j++) {
      for(int i=0; i < A->sc[j].Used; i++) {
         int row = (int)A->sc[j].idxs[i];
         assert(row < AT->N);
         AT->sc[row].Used++;
      }
   }

   // allocate space for the entries of AT
   for(int j=0; j < M; j++) {
      AT->sc[j].Length = 0; // we will use this as a counter
      int Used = (int)AT->sc[j].Used;
      AT->sc[j].idxs = new I[Used+1];
      AT->sc[j].vals = NULL;
      AT->sc[j].idxs[Used] = MaxIndex(I);
   }

   // Second pass: copy the entries into A'
   for(int j=0; j < N; j++) {
      for(int i=0; i < A->sc[j].Used; i++) {
         int row = A->sc[j].idxs[i];
         assert(row < AT->N);
         int index = AT->sc[row].Length++;

         assert(index < AT->sc[row].Used);
         AT->sc[row].idxs[index] = j;
      }
   }

   for(int j=0; j < M; j++)
      AT->sc[j].Length = N;

   return AT;
}

#include <vector>
using std::vector;

template<class T, class I>
class GramInteractions
{
public:

   GramInteractions(SparseMatrix<T,I> *A) {
      // compute transpose ... we could optimize this
      SparseMatrix<T,I> *AT = PseudoTranspose(A);

      N = A->GetN();

      // allocate accumulators
      acc_idxs = new I[N];
      acc_flags = new uint32[N];

      Alengths = new uint32[N];
      Qlengths = new uint32[N];

      for(int i=0; i < N; i++)
         acc_flags[i] = MaxIndex(uint32)-1;

      // compute interaction list
      for(int j = 0; j < N; j++) {
         int index = 0;

         for(int i=0; i < A->sc[j].Used; i++) {
            int col = (int)A->sc[j].idxs[i];

            assert(0 <= col && col < AT->N);
            for(int k=0; k < AT->sc[col].Used; k++) {
               I row = AT->sc[col].idxs[k];
               assert(row < N);

               if(acc_flags[row]!=j) {
                  assert(index < N);
                  acc_flags[row]    = j;
                  acc_idxs[index++] = row;
               }
            }
         }

         //Alists[j].resize(index);

         // initialize ilists[j]
         //ilengths[j] = index;
         //whichlist[j] = new uint8[index+1];
         //ilists[j] = new I[index+1];
         //ilists[j][index] = MaxIndex(I);

         //for(int i=0; i < index; i++)
           //Alists[j][i] = acc_idxs[i];

           //ilists[j][i] = acc_idxs[i];

         //QuickSort(ilists[j], 0, index);
      }

      delete AT;

   }

   ~GramInteractions() {
      delete Alists;
      delete Qlists;
      delete Qlengths;
      delete Alengths;
   }

   // return the list of interactions with the matrix A ... make sure the array
   // idxs has at least size(A,1) entries
   void GetAList(I column, uint32 *length, I **idxs) {

      //*length = Alists[column]->length();
      // we know the iterator is of the right type
      //**idxs = Alists[column]->begin();
      //for(int i=0; i < *length; i++)
        // idxs[i] = Alists[column][i];
   }

   // return the list of interactions with the matrix Q
   void GetQList(I column, uint32 *length, I **idxs) {
   }

   // switch a column over from "A" to "Q" ... this entails merging the lists
   // for each column interacting with the chosen columns
   void MoveColumnToQ(I column) {


   }

   // merge two lists
//   void MergeLists(I x, I y) {
   //}

private:
   uint32 N;            // number of columns in A

   I **Alists;
   I **Qlists;
   uint32 *Alengths;
   uint32 *Qlengths;

   uint32 *acc_flags;   // accumulator flags
   I *acc_idxs;         // accumulator indices
};

// class InteractionMatrix<T,I>
//
// This class is used by the gramm-schmidt routine to keep track of nonzero
// entries in the gramm matrix A'*A.  It doesn't actually store the values
// of those entries (because not recomputing inner products leads to numeric
// errors) only their indices.  In other words, for each column in A, it stores
// the list of columns in A which have nonzero inner product with A.

template<class T, class I>
class InteractionMatrix
{
public:

   InteractionMatrix(SparseMatrix<T,I> *A) {
      // compute transpose ... we could optimize this
      SparseMatrix<T,I> *AT = PseudoTranspose(A);

      N = A->GetN();

      ilists = new I*[N];
      whichlist = new uint8*[N];

      ilengths = new uint32[N];
      acc_idxs = new I[N];
      acc_flags = new uint32[N];

      for(int i=0; i < N; i++)
         acc_flags[i] = MaxIndex(uint32)-1;

      // compute interaction list
      for(int j = 0; j < N; j++) {
         int index = 0;

         for(int i=0; i < A->sc[j].Used; i++) {
            int col = (int)A->sc[j].idxs[i];

            assert(0 <= col && col < AT->N);
            for(int k=0; k < AT->sc[col].Used; k++) {
               I row = AT->sc[col].idxs[k];
               assert(row < N);

               if(acc_flags[row]!=j) {
                  assert(index < N);
                  acc_flags[row]    = j;
                  acc_idxs[index++] = row;
               }
            }
         }

         // initialize ilists[j]
         ilengths[j] = index;
         whichlist[j] = new uint8[index+1];
         ilists[j] = new I[index+1];
         ilists[j][index] = MaxIndex(I);

         for(int i=0; i < index; i++) {
           ilists[j][i] = acc_idxs[i];
           whichlist[j][i] = 0;
      }

         QuickSort(ilists[j], 0, index);
      }

      delete AT;
      flag = 0;
      for(int j=0; j < N; j++)
         acc_flags[j] = 0;
   }

   ~InteractionMatrix() {
       for(int j=0; j < N; j++) {
          if(ilists[j]!=NULL)
            delete ilists[j];
          if(whichlist[j]!=NULL)
            delete whichlist[j];
       }
       delete ilists;
       delete whichlist;
       delete ilengths;
       delete acc_idxs;
       delete acc_flags;
   }

   // return the list of columns in A we interact with
   void GetList(int column, int *num, I **idx_list) {
      assert(column>=0 && column<=N);
      *num = ilengths[column];
      *idx_list = ilists[column];
   }

   // get the list of columns in Q that we interact with
   void GetQList(int column, int *num, I **idx_list) {
   }

   // free the memory associated with one of the columns
   void DeleteList(int x) {
      assert(x>=0 && x<= N);
      delete ilists[x];
      ilists[x] = NULL;
      ilengths[x] = 0;
   }

   // merge the interaction lists for y with that for x
   void MergeLists(int x, int y) {
      uint32 index = 0;

      uint32 xlength = ilengths[x];
      uint32 ylength = ilengths[y];
      uint32 xpos = 0;
      uint32 ypos = 0;

      I *xidxs = ilists[x];
      I *yidxs = ilists[y];


      while(xpos < xlength || ypos < ylength) {

         yidxs[ylength]--;
         while(xidxs[xpos]==yidxs[ypos]) {
            assert(xpos < xlength);
            assert(ypos < ylength);
            assert(index < N);
            acc_idxs[index++] = xidxs[xpos];
            xpos++;
            ypos++;
         }
         yidxs[ylength]++;

         while(xidxs[xpos] < yidxs[ypos]) {
            assert(xpos < xlength);
            assert(index < N);
            acc_idxs[index++] = xidxs[xpos];
            xpos++;
         }

         while(yidxs[ypos] < xidxs[xpos]) {
            assert(ypos < ylength);
            assert(index < N);
            acc_idxs[index++] = yidxs[ypos];
            ypos++;
         }

      }

      // copy the newly formed list
      delete ilists[x];
      ilengths[x] = index;
      ilists[x] = new I[index+1];

      for(int i=0; i < index; i++)
         ilists[x][i] = acc_idxs[i];

      ilists[x][index] = MaxIndex(I);

      /*flag++;  // increment accumulator flag
      uint32 index = 0;

      for(int i=0; i < ilengths[x]; i++) {
         I row = ilists[x][i];
         acc_idxs[index++] = row;
         acc_flags[row] = flag;
      }

      for(int i=0; i < ilengths[y]; i++) {
         int row = ilists[y][i];
         if(acc_flags[row]!=flag)
            acc_idxs[index++] = row;
      }

      // copy the newly formed list
      delete ilists[x];
      ilengths[x] = index;
      ilists[x] = new I[index+1];
      ilists[x][index] = MaxIndex(I);

      for(int i=0; i < index; i++)
         ilists[x][i] = acc_idxs[i];*/
   }


private:

   uint32 flag;

   int N;                        // number of columns
   I **ilists;                   // stores each interaction list
   uint32 *ilengths;             // stores length of each interaction list
   uint8  **whichlist;          // Q list or A list

   I      *acc_idxs;
   uint32 *acc_flags;
};



#endif