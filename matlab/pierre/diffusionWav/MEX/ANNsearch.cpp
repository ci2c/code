#include "mex.h"
#include "MexUtility.h"
#include "ANN.h"


void usage()
{
   printf("                                                                              \n");
   printf("  function [idxs, dists] = ANNsearch(pointset, query_pts,  k, [tolerance])    \n");
   printf("                                                                              \n");
   printf("  ANNSEARCH is a wrapper for approximate nearest neighbors searches via the   \n");
   printf("  ANN package of Mount, et al.                                                \n");
   printf("                                                                              \n");
   printf(" In:                                                                          \n");
   printf("    pointset  = an MxN double matrix containing the N points in R^M which     \n");
   printf("                comprise the point set                                        \n");
   printf("    query_pts = MxL matrix of L points in R^M specifying the set of query     \n");
   printf("                query points                                                  \n");
   printf("    k         = number of nearest neighbors to find per query point           \n");
   printf("    tolerance = (optional) search tolerance                                   \n");
   printf("                                                                              \n");
   printf(" Out:                                                                         \n");
   printf("    idxs      = kxL matrix containing the indices of the nearest neighbors.   \n");
   printf("                The jth column contains the k indices of the jth query point's\n");
   printf("                nearest neighbors                                             \n");
   printf("    dists     = kxL matrix containing the SQUARE of the distances to the      \n");
   printf("                nearest neighbors. Again, the jth column contains the distance\n");
   printf("                to the neighbors of the jth query point.                      \n");
   printf("                                                                              \n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   int NN;                         // number of nearest neigbhors
   double Tolerance = .00001;       // tolerance for NN search

   /* process input arguments */

   // display help information and exit if there are no arguments
   if(nrhs==0) {
      usage();
      return;
   }

   if(nrhs < 3 || nrhs > 4) {
      printf("ANNsearch: incorrect usage; type 'ANNSearch' for help information.\n");
      return;
   }

   // find out how many neighbors we are looking for
   if(!GetInteger(prhs[2], &NN)) {
      printf("ANNSearch: k argument must be an integer.\n");
      return;
   }

   // optional tolerance argument
   if(nrhs==4)
      if(!GetDouble(prhs[3], &Tolerance)) {
         printf("ANNSearch: epsilon argument must be type double.\n");
         return;
      }

   if(!mxIsDouble(prhs[0]) || mxIsSparse(prhs[0]) || mxIsComplex(prhs[0])) {
      printf("ANNSearch: pointset argument must be a full array of doubles.\n");
      return;
   }

   if(!mxIsDouble(prhs[1]) || mxIsSparse(prhs[1]) || mxIsComplex(prhs[1])) {
      printf("ANNSearch: query_pts argument must be a full array of doubles.\n");
      return;
   }


   /* prepare the pointset and query_pts for input into ANN */
   double *pointset_pr = mxGetPr(prhs[0]);
   int dim = mxGetM(prhs[0]);                // dimension of points
   int N   = mxGetN(prhs[0]);                // number of points

   double *querypts_pr = mxGetPr(prhs[1]);
   int L = mxGetN(prhs[1]);                  // number of query points
   if(mxGetM(prhs[1])!=dim) {
      printf("ANNsearch: query points must have the same dimension as the dataset\n");
      return;
   }

//   printf("dim = %d, N = %d, L = %d\n", dim, N, L);

   if(NN > N) {
      printf("ANNsearch: NN reset to N=%d\n", N);
      NN = N;
   }

   ANNpointArray Pts;
   ANNpoint      queryPt;
   Pts = annAllocPts(N, dim);

   for(int j=0; j < N; j++) {
      memcpy(Pts[j], pointset_pr+(j*dim), sizeof(double)*dim);
   }

   ANNkd_tree *searchtree = new ANNkd_tree(Pts, N, dim);

   /* allocate output matrices */
   mxArray *idxs  = mxCreateNumericMatrix(NN, L, mxINT32_CLASS, mxREAL);
   mxArray *dists = mxCreateDoubleMatrix(NN, L, mxREAL);

   int *idxs_pr = (int *)mxGetData(idxs);
   double *dists_pr = mxGetPr(dists);

   /* perform the nearest neighhors searches */
   queryPt = annAllocPt(dim);

   for(int j=0; j < L; j++) {
      // copy the jth query point into queryPt
      memcpy(queryPt, querypts_pr+(j*dim), sizeof(double)*dim);

      // perform the search
      searchtree->annkSearch(queryPt, NN, (ANNidxArray)(idxs_pr+(j*NN)),
         (ANNdistArray)(dists_pr+(j*NN)), Tolerance);

      // we have to add one to the indices (doh!)
      for(int i=0; i < NN; i++)
         idxs_pr[i+(j*NN)]++;
   }

   plhs[0] = idxs;

   if(nlhs > 1)
      plhs[1] = dists;
   else
      mxDestroyArray(dists);


   /* clean up and return */
   delete searchtree;
   annDeallocPts(Pts);
   annDeallocPt(queryPt);
   annClose(); // deallocate any temporary structures used by ANN
}