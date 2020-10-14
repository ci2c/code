// SparseColumn.h
//
// Class for storing a single column of the SparseCMatrix.
//
// Uses:
//    utils.h
//
// Source Control:
//    JCB 07/22/04  initial version
//

#ifndef SPARSECOLUMN__H__JCB
#define SPARSECOLUMN__H__JCB

#include "utils.h"
#include <math.h>

/*
 * class SparseColumn
 *
 * Each column is stored as a list of (index, value) pairs.  There is also a
 * trailing INT_MAX at the end of the index list to make some program logic 
 * simpler (it eliminates the need to check for the end of list condition).
 *
 */
class SparseColumn 
{
public:   
   // initialize from a list of (idx, val) pairs
   SparseColumn(int rows, int number, const int *ir, const double *data) { 
      Height    = rows;
      Allocated = number;
      Used      = 0;
         
      DoAllocate();
   
      for(int i=0; i < number; i++) {
         idx[Used]=ir[i];
         val[Used]=data[i];
         Used++;
      }
   
      idx[Used] = INT_MAX; // make end of list
   }
   
   // initialize from a full column (with thresholding)
   SparseColumn(int height, const double *data, double threshold) {
      Height=height;
   
      Allocated=0;   
      for(int i=0; i < Height; i++)
         if(fabs(data[i]) > threshold)
            Allocated++;
      
      Used=Allocated;
   
      DoAllocate(); 
   
      // hit the matrix again
      int count=0;
      for(i=0; i < Height; i++) {
         if(fabs(data[i]) > threshold) {
            val[count] = data[i];
            idx[count] = i;      
            count++;
         }     
      }                        
      idx[Used] = INT_MAX; // make end of list         
   }
   
   // create empty with space for allocate elements
   SparseColumn(int rows, int allocate) {
      Height = rows;
      Used = 0;
      Allocated = allocate;
   
      DoAllocate();
      idx[Used] = INT_MAX; // make end of list      
   }
   
   SparseColumn(const SparseColumn& copy) {
      Height    = copy.Height;
      Used      = copy.Used;
      Allocated = copy.Allocated;
      
      DoAllocate();
      memcpy(idx, copy.idx, sizeof(int)*(Used+1));
      memcpy(val, copy.val, sizeof(double)*(Used));      
   }
     
   ~SparseColumn() {
      if(val!=NULL)
         mxFree(val);
      if(idx!=NULL)
         mxFree(idx);      
   }
   
   
   inline double Get(int i) const {
      Assert(i < Height, "SparseColumn::Set(): out of bounds.");      
      int list_pos = 0;            
      while( idx[list_pos] < i) {list_pos++;}  
      if(idx[list_pos] == i) 
         return val[list_pos];   // found it
      else
         return 0.0;             // entry is zero   
   }
   
   inline void Set(int i, double value) {
      Assert(i < Height, "SparseColumn::Set(): out of bounds.");
   
      if(value==0.0)
         return;
         
      int list_pos = 0;
      while( idx[list_pos] < i) {list_pos++;}
         
      if( idx[list_pos] == i)          // see if its in the list already
         val[list_pos] = value;
      else {                           // didn't think so      
         if(Allocated > Used) {        // do we have room already?            
            for(int k=Used; k > list_pos; k--) {
               val[k] = val[k-1];
               idx[k] = idx[k-1];
            }
            
            val[list_pos] = value;
            idx[list_pos] = i;
            Used++;           
            idx[Used] = INT_MAX; 
         } else {
            // have to make room            
            double *oldval=val;
            int *oldidx=idx;
            
            Allocated+=3;
            DoAllocate();

            // move stuff aread        
            for(int k=0; k < list_pos; k++) {
               val[k] = oldval[k];
               idx[k] = oldidx[k];
            }
               
            val[list_pos] = value;
            idx[list_pos] = i;
               
            Used++;
            for(k=list_pos+1; k < Used; k++) {
               val[k] = oldval[k-1];
               idx[k] = oldidx[k-1];
            }  
            idx[Used] = INT_MAX; // make end of list
            mxFree(oldval);
            mxFree(oldidx);          
         }        
      }      
   }   

// this has to be public because template functions aren't allowed
// to be friends and zeaxopby and sum_axopby need access to this data   
      
//private:
   int      Height;    // height of the column
   int      Used;      // # of elements in the column
   int      Allocated; // # of elements allocated for column elements
   double   *val;      // values of nonzero elements
   int      *idx;      // row indices of nonzero elements

   void DoAllocate() {
      val = (double *) mxMalloc(sizeof(double) * Allocated);
      idx = (int *)    mxMalloc(sizeof(int) * (Allocated+1));
   }      
   
   friend class SparseCMatrix;
};

#endif