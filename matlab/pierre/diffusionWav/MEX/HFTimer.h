// HFTimer.h
//
// Simple class for high frequency timing via the processor time stamp counter.
// This is really only useful for optimizing work while developing code, which
// is why I never bothered to write a portable version.  
//
// Dependencies:   Basic.h
// Platform:       wintel, GNU C++
//
// (c) 2005 James Bremer (james.bremer@yale.edu)


#if !defined(HFTIMER__H)
#define HFTIMER__H

#include "Basic.h"

// class HFTimer
//
// Class for high performance stop-watch style timing via the processor time
// stamp counter.
//
// Note: The first time a HFTimer object is created the clock speed of the
// processor is measured by comparing it to a system timer.  This can take
// a few hundred milliseconds.
//

class HFTimer
{
public:
    HFTimer();          // constructor
    void Reset();       // reset the counter
    void Start();       // start the stopwatch
    void Stop();        // stop the stopwatch
    uint64 GetTicks();  // return the number of clock ticks which have elapsed

    // return the number of milliseconds which have elapsed
    double GetElapsedTime();

    // return the frequnecy of the timer ( = processor clock speed)
    uint64 GetFrequency();

private:
    uint64 ElapsedTicks;
    uint64 StartTick;
};

// HFTimer.cpp
//
// Implementation of HFTimer class.
//
// (c) 2005 James Bremer (james.bremer@yale.edu)

#define x86_32_WINDOWS_MSVC

#include "Basic.h"

// store TSCFrequency as static
static uint64 TSCFrequency = 0;

// uint64 RDTSC()
//
// Read the processor's time stamp counter (TSC) register.
//
// Return:              current value of processor time stamp counter
// Error conditions:    none

#if defined(__MSVC__)
inline uint64 RDTSC()
{
    _asm rdtsc
}

#elif defined(__GNUC__)
inline uint64 RDTSC()
{
    uint32 lo, hi;
    asm("rdtsc" : "=a" (lo), "=d" (hi));   // edx:eax = processor clock speed
    return (uint64)lo+(((uint64)hi)<<32);
    return 0;
}
#endif

// uint64 CalibrateTSC()
//
// Measure the processor's clock speed (which is, course, the frequency of the
// time stamp counter).
//
// Return:              processor clock speed
// Error conditions:    none

#if defined(__MSVC__)

// The windows version of this routines used the high performance counter
// functions which seem to use a system timer other than the TSC ... so
// calibration against them is practical.

// we need windows.h for the "high performance counter"
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

// return the value of the windows performance counter
inline uint64 GetPC() {
   LARGE_INTEGER LI;
   QueryPerformanceCounter(&LI);
   return LI.QuadPart;
}

uint64 CalibrateTSC()
{
   LARGE_INTEGER LI;

   // determine reported frequency of windows high performance counter
   uint64 hp_freq;
   QueryPerformanceFrequency(&LI);
   hp_freq = LI.QuadPart;

   // wait for the counter to turn over
   uint64 pc_start=GetPC();
   uint64 pc_end;
   while((pc_end=GetPC())==pc_start) {;}
   pc_end+=hp_freq/20;

   // now wait for 1/20 of the performance counter frequency (= 50ms)
   uint64 tsc_start = RDTSC();
   while(GetPC()<pc_end) {;}
   uint64 tsc_end   = RDTSC();

   // calculate the TSCFrequency
   return (tsc_end-tsc_start)*20;
}
#elif __GNUC__

#include <sys/time.h>

// return time of day elapsed milliseconds
inline uint64 GetTODUS()
{
   struct timeval tv;
   struct timezone tz;

   gettimeofday(&tv, &tz);
   return tv.tv_usec+tv.tv_sec*1000000;
}
#include <stdio.h>
uint64 CalibrateTSC()
{
   // wait for timer to turn over
   uint64 pc_start=GetTODUS();
   uint64 pc_end;
   while((pc_end=GetTODUS())<pc_start+100000) {;}

   // now wait 200 milliseconds
   pc_end+=200000;
   uint64 tsc_start   = RDTSC();
   while(GetTODUS()<pc_end) {;}
   uint64 tsc_end   = RDTSC();

   // calculate the TSCFrequency
   return (tsc_end-tsc_start)*5;
}

#endif

// class HFTimer
//
// Class for high performance stop-watch style timing via the processor time
// stamp counter.
//

HFTimer::HFTimer()
{
   // if it hasn't already been done, calibrate the time stamp counter
   if(!TSCFrequency)
      TSCFrequency = CalibrateTSC();
   // reset the class variables
   Reset();
}

void HFTimer::Reset()
{
   ElapsedTicks = 0;
}

void HFTimer::Start()
{
   StartTick = RDTSC();
}

void HFTimer::Stop()
{
   ElapsedTicks += (RDTSC()-StartTick);
}

// report the number of elapsed ticks
uint64 HFTimer::GetTicks()
{
   return ElapsedTicks;
}

// report the elasped time in milliseconds
double HFTimer::GetElapsedTime()
{
   return 1e3*(double)ElapsedTicks/(double)TSCFrequency;
}

// report the frequency of the timer
uint64 HFTimer::GetFrequency()
{
   return TSCFrequency;
}


#endif // guard endif