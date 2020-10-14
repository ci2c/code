// MxMatrix.h
//
// Impementation fo the MxMatrix class for manipulating two-dimensional numeric
// matlab arrays.  
// 
// To Do:
//    [-] Implement sort routines for SortRows instead of calling matlab.
//        I've implemented quicksort but I want a stable sort I think (I
//        want to exactly duplicate the matlab behavior).
//
// Source Control:
//    JCB 07/21/04  initial version
//

#ifndef MX__MATRIX__GUARD
#define MX__MATRIX__GUARD

#include <vector>
using namespace std;

typedef vector<int> IntArray;
typedef vector<double> DblArray;

#include "utils.h"

/*
 * MxDbl, MxInt32, etc.
 *
 * These are the classes for the MxMatrix template parameter.  They tell MxMatrix
 * what type the elements of the matrix are.  
 *
 */

class MxDbl
{
public:      
   
   typedef double entry_type;
   inline static mxClassID class_id() { return mxDOUBLE_CLASS; }   // more portable then static consts (I hope)
};

class MxInt32
{
public:
   typedef int entry_type;
   inline static mxClassID class_id() { return mxINT32_CLASS; }   // more portable then static consts (I hope)
};

/*
 * class MxMatrix
 *
 * Class for manipulating matlab matrices.  
 *
 * Memory behavior:
 * 
 * MxMatrix objects will delete themselves in their destructors UNLESS there 
 * is a call to the GetMx() method in which case they will not.  The assumption 
 * behind this behaviour is that objects for which GetMx() is being called are 
 * going to be returned to matlab.  If that is not the case, destroy them 
 * explicitly with Destroy().
 * 
 */

template<class T> 
class MxMatrix
{
public:

   // constructor to create a new mxArray
   MxMatrix(int rows, int cols) {
      DestroyThis=true;
      nRows = rows;
      nCols = cols;
   
      int dims[2];   
      dims[0] = rows;
      dims[1] = cols;   
      array = mxCreateNumericArray(2, dims, (mxClassID)T::class_id(), mxREAL);   
      data = (T::entry_type *)mxGetData(array);  
   }

   MxMatrix(int rows, int cols, T::entry_type *source) {
      DestroyThis=true;
      nRows = rows;
      nCols = cols;
   
      int dims[2];   
      dims[0] = rows;
      dims[1] = cols;   
      array = mxCreateNumericArray(2, dims, (mxClassID)T::class_id(), mxREAL);   
      data = (T::entry_type *)mxGetData(array);  
      
      int count=0;
      for(int j=0; j < nCols; j++)
         for(int i=0; i < nRows; i++)
            data[count]=source[count++];
   }
   
   // constructor to associate object with already existing mxArray
   MxMatrix(mxArray *source) { DestroyThis=true; Associate(source); }
  
   // constructor to make a copy of existing mxArray
   MxMatrix(const mxArray *source) { DestroyThis=true; Copy(source); }
  
   // copy constructor
   MxMatrix(const MxMatrix& copy) {
      nRows = copy.nRows;
      nCols = copy.nCols;
      
      int dims[2];   
      dims[0] = nRows;
      dims[1] = nCols;   
      array = mxCreateNumericArray(2, dims, (mxClassID)T::class_id(), mxREAL);      
      data = (T::entry_type *)mxGetData(array);
      
      memcpy(data, copy.data, sizeof(T::entry_type)*nRows*nCols);
   }
      
   // from vector
   MxMatrix(int rows, int cols, const vector<T::entry_type> &source) {
      nRows = rows;
      nCols = cols;
      
      int dims[2];   
      dims[0] = nRows;
      dims[1] = nCols;   
      array = mxCreateNumericArray(2, dims, (mxClassID)T::class_id(), mxREAL);      
      data = (T::entry_type *)mxGetData(array);
      
      int count=0;
      for(int j=0; j < cols; j++)
         for(int i=0; i < rows; i++)
            data[count]=source[count++];
   }
   
   ~MxMatrix()
   {
      if(DestroyThis) 
         mxDestroyArray(array);
   }
   
   // associate this object with already existing mxArray
   void Associate(mxArray *input) {
      // some checks on the input 
      Assert(input!=NULL, "MxMatrix<T>::Associate(mxArray *)   input==NULL.");  
      Assert(CheckType(input, (mxClassID)T::class_id, false), 
         "MxMatrix<T>::Associate(mxArray *)   input array is wrong type.");
      
      array=input;
   
      nRows = mxGetM(array);
      nCols = mxGetN(array);  
      data  = (T::entry_type *)mxGetData(array);        
   }
   
   void Copy(const mxArray *input) {      
      // some checks on the input 
      Assert(input!=NULL, "MxMatrix<T>::Copy(mxArray *)   input==NULL.");  
      Assert(CheckType(input, (mxClassID)T::class_id(), false), 
         "MxMatrix<T>::Copy(mxArray *)   input array is wrong type.");

      nRows = mxGetM(input);
      nCols = mxGetN(input);  
         
      int dims[2];   
      dims[0] = nRows;
      dims[1] = nCols;   
      array = mxCreateNumericArray(2, dims, (mxClassID)T::class_id(), mxREAL);
      data = (T::entry_type *)mxGetData(array);                 
      memcpy(data, mxGetData(input), sizeof(T::entry_type)*nRows*nCols);      
   }
   
   void Destroy() {
      if(array!=NULL)
         mxDestroyArray(array);
      array=NULL;            
   }
   
   // construct a new matrix which is a subset of the matrix
   MxMatrix<T> Choose(IntArray rows, IntArray columns) {      
      MxMatrix<T> newmatrix(rows.size(), columns.size());

      for(int j=0; j < columns.size(); j++)
         for(int i=0; i < rows.size(); i++)
            newmatrix(i,j) = Get(rows[i], columns[j]);
            
      return newmatrix;
   }
   
   // sort the matrix by one or more columns
   MxMatrix<T> SortRows(IntArray columns) {
      MxMatrix<MxInt32> mxColumns(1, columns.size());
      
      for(int i=0; i < columns.size(); i++)
         mxColumns(0, i) = columns[i]+1;
      
      int      nrhs=2;
      mxArray *prhs[2];
      prhs[0] = array;
      prhs[1] = mxColumns.GetMx();
      
      int nlhs=1;
      mxArray *plhs[1];
      
      mexCallMATLAB(nlhs, plhs, nrhs, prhs, "SortRows");      
      mxColumns.Destroy();       // we must explicit destroy since we called GetMx()      
      
      return MxMatrix<T>(plhs[0]);
   }
   
   // get pointer to matlab array
   mxArray *GetMx() {
      DestroyThis = false;      // assume user is returning this object
      return array;
   }
   
   // get # of rows
   int GetM() const {
      return nRows;
   }
   
   // get # of columns
   int GetN() const {
      return nCols;
   }
   
   MxMatrix<T> &operator=(const MxMatrix<T> &copy) {
      
      Destroy();      
      nRows = copy.nRows;
      nCols = copy.nCols;
      
      int dims[2];   
      dims[0] = nRows;
      dims[1] = nCols;   
      array = mxCreateNumericArray(2, dims, (mxClassID)T::class_id(), mxREAL);      
      data = (T::entry_type *)mxGetData(array);
      
      memcpy(data, copy.data, sizeof(T::entry_type)*nRows*nCols);
      
      return *this;
   }
   
   // element access functions      
   inline const T::entry_type Get(int i, int j) const {
      Assert(data!=NULL, "MxMatrix<T>::operator()(int,int): data==NULL.");
      Assert(i>=0 && i < nRows && j>=0 && j <nCols, 
         " MxMatrix<T>::operator(int, int): out of bounds.");
      
      return data[i+j*nRows];      
   }

   inline T::entry_type &Get(int i, int j)
   {
      Assert(data!=NULL, "MxMatrix<T>::Get(int,int): data==NULL.");
      Assert(i>=0 && i < nRows && j>=0 && j <nCols, 
         "MxMatrix<T>::Get(int, int): out of bounds.");
   
      return data[i+j*nRows];      
   }

   inline void Set(int i, int j, T::entry_type value)
   {
      Assert(data!=NULL, "MxMatrix<T>::Set(int,int): data==NULL.");
      Assert(i>=0 && i < nRows && j>=0 && j <nCols, 
         "MxMatrix<T>::Set(int, int): out of bounds.");
   
      data[i+j*nRows]=value;      
   }
          
   inline T::entry_type operator()(int i, int j) const {
      return Get(i, j);
   }
   
   inline T::entry_type& operator()(int i, int j) {
      return Get(i,j);
   }

            
private:   
   // quick little utility function
   bool CheckType(const mxArray *array, mxClassID class_id, bool sparse)
   {
      bool good = true;
   
      good = good & (mxIsNumeric(array));
      good = good & (!mxIsComplex(array));
      good = good & (mxIsSparse(array) == sparse);
      good = good & (mxGetClassID(array) == class_id);
   
      return good;
   }


   bool          DestroyThis;
   int           nRows;
   int           nCols;
   T::entry_type *data;
   mxArray       *array;
};


#endif