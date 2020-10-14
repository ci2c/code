// LeakDetect.h
//
// This file contains simple overloaded new and delete operators useful for
// detecting leaks.  These routines are not efficient and are only included
// if the LEAK_DETECT macro is defined.  If you allocate lots of small pieces of
// memory, these routines will TAKE FOREVER so beware.
//
// Dependencies:         none
// Author:               James Bremer (james.bremer@yale.edu)
// 

#if !defined(LEAKDETECT__H)
#define LEAKDETECT__H
#if defined(LEAK_DETECT)

#include <stdio.h>
#include <list>

typedef struct
{
   void   *address;
   size_t  bytes;
   int     lineno;
   char    file[128];


}MemoryBlock;

class MemoryBlockList : public std::list<MemoryBlock *>
{
public:
   MemoryBlockList() : std::list<MemoryBlock *>() {
   }

   ~MemoryBlockList() {
#if !defined(MATLAB_MEX_FILE)
      DetectLeaks();
#endif
   }

   void DetectLeaks() {
      bool found=false;
      printf("\nChecking for memory leaks ... ");

      for(iterator i=begin(); i != end(); i++) {
         MemoryBlock *mb = *i;

         if(!found)
            printf("\n");
         printf("   %d byte block at %08X allocated in '%s' at line %d\n",
            mb->bytes, mb->address, mb->file, mb->lineno);

         free(mb->address);
         free(mb);
         found = true;
      }

      if(!found)
         printf("none detected.\n");

      clear();
   }

   void BlockAllocated(void *address, size_t bytes, int lineno, char *file) {
      MemoryBlock *mb = (MemoryBlock *)malloc(sizeof(MemoryBlock));
      mb->address = address;
      mb->bytes   = bytes;
      mb->lineno  = lineno;
      strncpy(mb->file, file, 127);

      insert(end(), mb);
   }

   void BlockDeleted(void *address) {

      iterator i=begin();
      while(i!=end()) {
         MemoryBlock *mb = *i;
         if(mb->address==address) {
            erase(i);
            break;
         }
         i++;
      }

   }

};

MemoryBlockList __mbl;

void *operator new(size_t bytes, int line_no, char *file)
{
   void *address = malloc(bytes);
   __mbl.BlockAllocated(address, bytes, line_no, file);
   return address;
}

void *operator new[](size_t bytes, int line_no = __LINE__, char *file = __FILE__)
{
   void *address = malloc(bytes);
   __mbl.BlockAllocated(address, bytes, line_no, file);
   return address;
}

void operator delete(void *address)
{
   __mbl.BlockDeleted(address);
   free(address);
}

void operator delete[](void *address)
{
   __mbl.BlockDeleted(address);
   free(address);
}

#define  new  new (__LINE__, __FILE__)
#endif

#endif
