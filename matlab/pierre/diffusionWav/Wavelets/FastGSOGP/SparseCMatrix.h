// SparseCMatrix.h
//
// SparseCMatrix is a sparse matrix class designed for efficiently doing the 
// operations necessary  for FastGSOGP.  Essentially we need to be be able to 
// perform the following operations where M is a sparse matrix:
//
//    1. sum(M(:,j)^2)
//    2. M(:,z) = a*M(:,x) + b*M(:,y)
//    3. M(:,j)'*M(:,i) (inner product of columns)
// 
// Ops (1) and (3) are very efficient with the matlab sparse layout but
// replacing the column in (2) is very expensive.  So I wrote SparseCMatrix
// which stores pointer to each column's data instead of storing it 
// sequentially.  This makes operation (2) quite efficient (and of course,
// the efficiency of the other operations is essentially unaffected
// except for the one or two instructions to load the pointers into registers).
// This layout might make other operations slower (the fact that the matrix
// data is scattered in memory will probably make touching every element
// expensive so I don't think this is good for doing multiplication).
//
// Since many C++ compilers (e.g. Microsoft) have trouble with inline funcions
// outside of class definitions and most of the code here is inlined, I just put
// all the code in the class definition.
//
// To Do:
//    [-] This class has expaned and gotten messy ... clean it up a bit
// 
// Uses:
//    utils.h, SparseColumn.h
//
// Source Control:
//    JCB 07/22/04  initial version
//

#ifndef SPARSECMATRIX__H__JCB
#define SPARSECMATRIX__H__JCB

#include "utils.h"
#include "SparseColumn.h"
#include <math.h>

/*
 * class SparseCMatrix
 *
 * Sparse matrix, stored by columns.  These matrices will kill themselves
 * in the destructor (unlike MxMatrix).
 *
 */

class SparseCMatrix {
public:
   // construct from a matlab array with thresholding
   SparseCMatrix(const mxArray *input, double threshold = 0.0) {
      Assert(input!=NULL, "SparseCMatrix::SparseCMatrix(mxArray *): input==NULL");
      Assert(mxIsNumeric(input) && !mxIsComplex(input), 
         "SparseCMatrix::SparseCMatrix(mxArray *): input is bad type");
     
      nRows = mxGetM(input);
      nCols = mxGetN(input);
      const double *data = (const double *)mxGetData(input);        
      //sc.resize(nCols);   
      sc = (SparseColumn **)mxMalloc(sizeof(SparseColumn *) *nCols);
      
      if(mxIsSparse(input)) {
         int *jc = (int *)mxGetJc(input);
         int *ir = (int *)mxGetIr(input);
      
         // now populate that data  
         for(int j=0; j < nCols; j++)             
            sc[j] = new SparseColumn(nRows, jc[j+1]-jc[j], ir+jc[j], data+jc[j]);
      } else {
         //Warn(1, "SparseCMatrix::SparseCMatrix(mxArray *input) Initializing sparse matrix from full matrix.");         
         for(int j=0; j < nCols; j++)
            sc[j] = new SparseColumn(nRows, data+(nRows*j), threshold);
      }      
      
      newidx = (int *)mxMalloc( (nRows+1) * sizeof(int));
      newval = (double *)mxMalloc( (nRows+1) * sizeof(double));

   }
   
   // empty sparse but with allocpercol entries allocated per column
   SparseCMatrix(int rows, int cols, int allocpercol) {
      nRows = rows;
      nCols = cols;
      //sc.resize(nCols);   
      sc = (SparseColumn **)mxMalloc(sizeof(SparseColumn *) *nCols);
   
      for(int i=0; i < nCols; i++)
         sc[i] = new SparseColumn(rows, allocpercol);          
      newidx = (int *)mxMalloc( (nRows+1) * sizeof(int));
      newval = (double *)mxMalloc( (nRows+1) * sizeof(double));         
   }
   
   // make NxN identity
   SparseCMatrix(int M, int N) {
      nRows = M;
      nCols = N;
      
      int idx[1];
      double value[1];
      
      value[0]=1.0;
      
      //sc.resize(nCols);   
      sc = (SparseColumn **)mxMalloc(sizeof(SparseColumn *) *nCols);
   
      for(int i=0; i < nRows; i++) {
         idx[0]=i;
         sc[i] = new SparseColumn(nRows, 1, idx, value);          
      }
      
      for( ; i < nCols; i++)
         sc[i] = new SparseColumn(nRows, 0);
   
      newidx = (int *)mxMalloc( (nRows+1) * sizeof(int));
      newval = (double *)mxMalloc( (nRows+1) * sizeof(double));         
      
   }
      
   SparseCMatrix(const SparseCMatrix &copy) {
      nRows = copy.nRows;
      nCols = copy.nCols;
      
      sc = (SparseColumn **)mxMalloc(sizeof(SparseColumn *) *nCols);
      
      for(int i=0; i < nCols; i++)
         sc[i] = new SparseColumn(*copy.sc[i]);

      newidx = (int *)mxMalloc( (nRows+1) * sizeof(int));
      newval = (double *)mxMalloc( (nRows+1) * sizeof(double));                  
   }
   
   
   SparseCMatrix(const SparseCMatrix &copy, int n, int *newidxs) {
      Assert(n <= copy.nCols, "SparseCMatrix::ChooseColumns(int, int *): out of bounds.");
      
      nCols = n;
      nRows = copy.nRows;
      
      SparseColumn **newsc;      
      newsc = (SparseColumn **)mxMalloc( sizeof(SparseColumn *) *n);      
      for(int j=0; j < n; j++) {
         Assert(newidxs[j] < copy.nCols, "SparseCMatrix::ChooseColumns(int): out of bounds.");
         newsc[j] = sc[newidxs[j]];           
      }

      newidx = (int *)mxMalloc( (nRows+1) * sizeof(int));
      newval = (double *)mxMalloc( (nRows+1) * sizeof(double));                  
      
      mxFree(sc);
      sc=newsc;      
   }
      
   ~SparseCMatrix() {
      
      if(sc!=NULL)   // user might have destroyed it explicity
         Destroy();
   }
      
   void Destroy() {
      Assert(newidx!=NULL && newval!=NULL && sc!=NULL, "SparseCMatrix::Destroy(): newidx=null, newval=null, or sc=NULL");
      mxFree(newidx);
      mxFree(newval);
      
      for(int j=0; j < nCols; j++)
         delete sc[j];      
      mxFree(sc);      
      sc=NULL;
   }
   
   // pick first n columns
   void ChooseColumns(int n) {
      Assert(n <= nCols, "SparseCMatrix::ChooseColumns(int): out of bounds.");
      SparseColumn **newsc;      
      newsc = (SparseColumn **)mxMalloc( sizeof(SparseColumn *) *n);      
      for(int j=0; j < n; j++)
         newsc[j] = sc[j];
      mxFree(sc);
      sc=newsc;      
      nCols = n;      
   }
   
   // move the columns around
   void ChooseColumns(int n, int *newidxs) {
      Assert(n <= nCols, "SparseCMatrix::ChooseColumns(int, int *): out of bounds.");
      
      SparseColumn **newsc;      
      newsc = (SparseColumn **)mxMalloc( sizeof(SparseColumn *) *n);      
      for(int j=0; j < n; j++) {
         Assert(newidxs[j] < nCols, "SparseCMatrix::ChooseColumns(int): out of bounds.");
         newsc[j] = sc[newidxs[j]];           
      }
      mxFree(sc);
      sc=newsc;      
      nCols = n;
   }
   
   inline int GetN() const { return nCols; };
   inline int GetM() const { return nRows; };
      
   // output a matlab sparse array (with thresholding) from chosen columns
   mxArray *GetSparseMx(int n, int *colidxs, double threshold = 0.0) {
      int *jc = (int *)mxMalloc(sizeof(int)*(n+1));
      
      // count # of sparse elements
      int nnz = 0;   
      for(int j=0; j < n; j++) {
         jc[j] = nnz;         
         Assert(colidxs[j] < nCols, "SparseCMatrix::GetSparseMX() out of bounds");         
         SparseColumn *col = sc[colidxs[j]];
         
         for(int i=0; i < col->Used; i++)
            if(fabs(col->val[i]) > threshold)
               nnz++;      
      }
      jc[n]=nnz;
      
      mxArray *array=mxCreateSparse(nRows, n, nnz, mxREAL);
      mxSetJc(array, jc);
      
      int *ir = mxGetIr(array);
      double *data = (double *)mxGetData(array);
   
      int count=0;
      for(j=0; j < n; j++) {
         
         SparseColumn *col = sc[colidxs[j]];         
         for(int i=0; i < col->Used; i++) {
            if(fabs(col->val[i]) > threshold) {
               Assert(count < nnz, "SparseCMatrix::GetSparseMX() arg");         
               ir[count]=col->idx[i];
               data[count]=col->val[i];
               count++;
            }
         }            
      }         
      return array;            
   }
   
   
   // output a matlab sparse array (with thresholding) 
   mxArray *GetSparseMx(double threshold = 0.0) {
      int *jc = (int *)mxMalloc(sizeof(int)*(nCols+1));
      
      // count # of sparse elements
      int nnz = 0;   
      for(int j=0; j < nCols; j++) {
         jc[j] = nnz;
         
         for(int i=0; i < sc[j]->Used; i++)
            if(fabs(sc[j]->val[i]) > threshold)
               nnz++;
      }
      jc[nCols]=nnz;
   
      mxArray *array=mxCreateSparse(nRows, nCols, nnz, mxREAL);
      mxSetJc(array, jc);
      
      int *ir = mxGetIr(array);
      double *data = (double *)mxGetData(array);
   
      int count=0;
      for(j=0; j < nCols; j++) {
         for(int i=0; i < sc[j]->Used; i++) {
            if(fabs(sc[j]->val[i]) > threshold) {
               ir[count]=sc[j]->idx[i];
               data[count]=sc[j]->val[i];
               count++;
            }
         }            
      }         
      return array;            
   }
   
   // output a matlab full array
   mxArray *GetMx() {
      mxArray *array=mxCreateDoubleMatrix(nRows, nCols, mxREAL);
      double *data = (double *)mxGetData(array);
   
      for(int j=0; j < nCols; j++) 
         for(int i=0; i < sc[j]->Used; i++)
            data[j*nRows+sc[j]->idx[i]] = sc[j]->val[i];      
   
      return array;            
   }
 
   inline const double Get(int i, int j) const {
      Assert(j<nCols && i < nRows, "SparseCMatrix::Get(int, int): out of bounds.");            
      return sc[j]->Get(i);
   }
   
   inline void Set(int i, int j, double value) {
      Assert(j<nCols && i < nRows, "SparseCMatrix::Set(int, int): out of bounds.");            
      sc[j]->Set(i, value);
   }
    
   inline const double operator()(int i, int j) const {
      return Get(i,j);
   }
      
// this has to be public because template functions aren't allowed
// to be friends and zeaxopby and sum_axopby need access to this data   

//private:  
   int nCols;
   int nRows;       
   SparseColumn **sc;
   
   // used as scratch memory by zeaxopby 
   int    *newidx;
   double *newval;
     
};

 
#endif