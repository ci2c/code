// DynamicHeap.h
//
// Implementation of a heap class which allows for dynamic modification of
// keys.  This class is used by the pivoted Gramm-Schmidt algorithm to
// efficiently track column norms and choose the column of largest norm
// at each iteration.
//
// Dependencies:   Basic.h
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#ifndef DYNAMIC__HEAP
#define DYNAMIC__HEAP

#include <assert.h>
#include "Basic.h"

// class DynamicHeap<TKey>
//
// A class for managing a dynamic heap whose keys can be changed.  The heap
// elements are ordered via the primary key, of type TKey, with the largest
// element on the "top of the heap".  They can be modified via their second,
// reverse lookup, keys which are necessarily natural numbers.
//

template<class TKey>
class DynamicHeap
{
public:

   // allocate a new heap with n elements and room for max elements
   DynamicHeap(int max, int n, TKey *keys, int *rkeys = NULL)
   {
      Max    = max;
      Length = n;

      // allocate the heap variables
      heap_keys  = new TKey[Max];
      heap_rkeys = new int[Max];
      lookup     = new int[Max];

      for(int j=0; j < Max; j++)
         lookup[j] = -1;

      if(rkeys!=NULL) {
         for(int j=0; j < Length; j++) {
            heap_keys[j]     = keys[j];
            heap_rkeys[j]    = rkeys[j];
            lookup[rkeys[j]] = j;
         }
      }  else {
         for(int j=0; j < Length; j++) {
            heap_keys[j]     = keys[j];
            heap_rkeys[j]    = j;
            lookup[j]        = j;
         }
      }

      if(Length)
         for(int j=Length/2; j >= 0; j--)
            Heapify(j);

   }

   // destructor frees memory associated with heap
   ~DynamicHeap() {
      delete heap_keys;
      delete heap_rkeys;
      delete lookup;
   }

   // return true if the heap is empty
   inline bool Empty() const {
      return (Length==0);
   }

   // return the current size of the heap (the number of elements on the heap
   // ... not the maximum number of elements allowable)
   inline int Size() const {
      return Length;
   }

   // find an element based on its reverse lookup key
   TKey& Lookup(int rkey) {
      int idx = lookup[rkey];
      assert(idx!=-1);
      return heap_keys[idx];
   }

   // find an element based on its reverse lookup, return NULL if
   // the key cannot be found
   bool Lookup(int rkey, TKey *key)  {
      assert(rkey < Max);
      int idx = lookup[rkey];

      if(idx==-1)
         return false;

      if(key!=NULL)
         *key = heap_keys[idx];

      return true;
   }

   // look at -- but don't extract -- the element at the top of the heap
   TKey Peek() {
      assert(Length>0);
      return heap_keys[0];
   }

   // grab the element at the top of the heap
   TKey Extract() {
      assert(Length>0);

      // swap record 0 with the last record
      HeapSwap(0, Length-1);
      if(--Length) Heapify(0);

      lookup[heap_rkeys[Length]] = -1;
      return heap_keys[Length];
   }

   // grab the element at the top of the heap, returning both
   // its key and its reverse key
   void Extract(TKey *key, int *rkey) {
      assert(Length>0);

      // swap record 0 with the last record
      HeapSwap(0, Length-1);
      if(--Length) Heapify(0);

      lookup[heap_rkeys[Length]] = -1;
      *key = heap_keys[Length];
      *rkey = heap_rkeys[Length];
   }

   void Remove(int rkey) {
      // find index of the column
      int idx = lookup[rkey];
      assert(idx!=-1);

      if(idx!=-1) {
         if(idx==(Length-1))
            Length--;
         else {
            HeapSwap(idx, Length-1);
            if(--Length) Adjust(idx);
         }

         lookup[rkey] = -1;
      }
   }

   // remove an element from the heap based on its reverse lookup key,
   // but return the value of its key
   void Remove(int rkey, TKey *key) {
      // find index of the column
      int idx = lookup[rkey];
      assert(idx!=-1);

      if(idx!=-1) {
         if(idx==(Length-1))
            Length--;
         else {
            HeapSwap(idx, Length-1);
            if(--Length) Adjust(idx);
         }

         *key = heap_keys[Length];
         lookup[rkey] = -1;
      }
   }

   void Insert(TKey key, int rkey) {
      assert(rkey < Max);
      assert(Length < Max);
      assert(lookup[rkey]==-1);

      heap_keys[Length] = key;
      heap_rkeys[Length] = rkey;
      lookup[rkey] = Length;
      Length++;

      FloatUp(Length-1);
   }

   void Modify(int rkey, TKey new_key) {
      assert(rkey < Max);
      assert(lookup[rkey]!=-1);

      int idx = lookup[rkey];
      heap_keys[idx] = new_key;
      Adjust(idx);
   }

private:

   void Adjust(int index) {

      if(index==0)
         Heapify(0);
      else {
         int parent = (index-1)/2;

         if(heap_keys[parent] < heap_keys[index]) {
            HeapSwap(parent, index);
            FloatUp(parent);
         } else
            Heapify(index);
      }
   }

   // void HeapSwap(int i, int j)
   //
   // HeapSwap swaps the ith and jth element, and performs all necessary
   // bookeeping on both the heap array and the reverse lookup list.
   void HeapSwap(int i, int j) {
      assert(max(i,j) < Length);
      assert(lookup[heap_rkeys[i]]!=-1);
      assert(lookup[heap_rkeys[j]]!=-1);

      TKey temp1   = heap_keys[i];
      heap_keys[i] = heap_keys[j];
      heap_keys[j] = temp1;

      int temp2     = heap_rkeys[i];
      heap_rkeys[i] = heap_rkeys[j];
      heap_rkeys[j] = temp2;

      lookup[heap_rkeys[i]]=i;
      lookup[heap_rkeys[j]]=j;
   }

   void Heapify(int index) {
      assert(index < Length);

      int largest = index;
      int left    = 2*index+1;
      int right   = 2*index+2;

      if(left < Length && heap_keys[largest] < heap_keys[left])
         largest = left;
      if(right < Length && heap_keys[largest] < heap_keys[right])
         largest = right;

      if(index!=largest) {
         HeapSwap(index, largest);
         Heapify(largest);
      }
   }

   void FloatUp(int index) {
      assert(index < Length);

      if(index) {
         int parent = (index-1)/2;

         if(heap_keys[parent] < heap_keys[index]) {
            HeapSwap(parent, index);
            FloatUp(parent);
         }
      }
   }

   int Max;
   int Length;

   TKey *heap_keys;
   int  *heap_rkeys;
   int  *lookup;
};


#endif