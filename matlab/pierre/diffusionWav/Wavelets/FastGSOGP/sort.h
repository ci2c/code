// sort.h
//
// Some simple template-base sort routines.  I implemented both quicksort
// and mergesort because I'm not sure if I need a stable sort or not 
// (mergesort is stable but not as fast as quicksort). 
//
// Source Control:
//    JCB   07/21/04   initial version (should work unless I forgot my CS101)
//

#ifndef SORT__H__JCB
#define SORT__H__JCB

#include "QuickSort.h"

template<class T>
void mergesort(T* a, int *idxs, int left, int right)
{
   if (left < right)
   {
      int middle = (left + right) / 2;
      mergesort (a, idxs, left, middle);
      mergesort (a, idxs, middle+1, right);
      merge (a, idxs, left, right);
   }
}

template<class T>
void merge(T* a, int *idxs, int left, int right)
{
   int n=right-left+1;
   
   T   *temp     = (T*)    mxMalloc(sizeof(T)*n);
   int *tempidxs = (int *) mxMalloc(sizeof(int)*n);
   
   int middle = (left+right)/2;
   // copy the values to the temp array 
   int i=left;
   int j=middle+1;
   int count=0;
   
   while(  i <= middle  && j <= right ) {
      if ( a[i] <= a[j] ) {
         temp[count] = a[i];
         tempidxs[count] = idxs[i];
         i++; count++;
      } else {
         temp[count] = a[j];
         tempidxs[count] = idxs[j];
         j++; count++;         
      }
   }
   
   while( i<=middle ) {
      temp[count] = a[i];
      tempidxs[count] = idxs[i];
      count++; i++;
   }

   while( j<=right ) {
      temp[count] = a[j];
      tempidxs[count] = idxs[j];
      count++; j++;
   }
      
   for(i=0; i < n; i++) {
      a[left+i] = temp[i];
      idxs[left+i] = tempidxs[i];
   }
      
   
   mxFree(tempidxs);
   mxFree(temp);
}


template<class T>
void quicksort(T *values, int *idxs, int left, int right)
{
	QuickSort(values, idxs, left, right);
}

/*
template<class T>
void quicksort(T *values, int *idxs, int left, int right)
{
   if(left < right) {
      
      T x=values[left];  // value to partition on
      
      int i=left-1;
      int j=right+1;
      
      while(1) {
         do { i++; } while (values[i] < x);
         do { j--; } while (values[j] > x);
      
         if(i<j) {
            T  swap_d = values[i];
            int    swap_i = idxs[i];
            values[i] = values[j];
            idxs[i] = idxs[j];
            values[j] =swap_d;
            idxs[j] = swap_i;
         } else {
            quicksort(values, idxs, left, j);         
            quicksort(values, idxs, j+1, right);
            break;
         }           
      }           
   }
}

template<class T>
void quicksort(T *values, int left, int right)
{
   if(left < right) {
      
      T x=values[left];  // value to partition on
      
      int i=left-1;
      int j=right+1;
      
      while(1) {
         do { i++; } while (values[i] < x);
         do { j--; } while (values[j] > x);
      
         if(i<j) {
            T  swap_d = values[i];
            values[i] = values[j];
            values[j] =swap_d;
         } else {
            quicksort(values, left, j);         
            quicksort(values, j+1, right);
            break;
         }           
      }           
   }
}
*/

#endif