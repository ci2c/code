#include "mex.h"
#include "MexUtility.h"
#include "ANN.h"


void usage()
{
   printf("                                                                              \n");
   printf("  function [count, idxs, dists] = ANNsearch(pointset, query_pts,  NN, radius, \n");
   printf("    [tolerance])                                                              \n");
   printf("                                                                              \n");
   printf("  ANNRSEARCH is a wrapper for approximate range searches via the ANN package  \n");
   printf("  of Mount, et al.                                                            \n");
   printf("                                                                              \n");
   printf(" In:                                                                          \n");
   printf("    pointset  = MxN double matrix of N points in R^M specifying the pointset  \n");
   printf("    query_pts = MxL matrix of L points in R^M specifying the set of query points\n");
   printf("    NN        = maximum number of neighbors (0 for no limit)                  \n");
   printf("    radius    = SQUARED radius for range search                               \n");
   printf("    tolerance = (optional) search tolerance                                   \n");
   printf("                                                                              \n");
   printf(" Out:                                                                         \n");
   printf("    count     = row vector giving the number of neighbors for each query point\n");
   printf("    idxs      = 1xL cell array, the jth entry of which is a vector giving the \n");
   printf("                list of neighbors for the jth query point                     \n");
   printf("    dists     = 1xL cell array, the jth entry of which is a vector giving the \n");
   printf("                list of SQUARED distances for the jth query point             \n");
   printf("                                                                              \n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   double Radius;                 // radius for searches
   double Tolerance = .001;       // tolerance for NN search
   int NN;                        // largest number of neighbors to examine

   /* process input arguments */

   // display help information and exit if there are no arguments
   if(nrhs==0) {
      usage();
      return;
   }

   if(nrhs < 4 || nrhs > 5) {
      printf("ANNsearch: incorrect usage; type 'ANNSearch' for help information.\n");
      return;
   }

   // find out how many neighbors we are looking for
   if(!GetDouble(prhs[3], &Radius)) {
      printf("ANNsearch: radius argument must be an integer.\n");
      return;
   }

   // find out how many neighbors we are looking for
   if(!GetInteger(prhs[2], &NN)) {
      printf("ANNsearch:  argument must be an integer.\n");
      return;
   }

   // optional tolerance argument
   if(nrhs==5)
      if(!GetDouble(prhs[4], &Tolerance)) {
         printf("ANNsearch: epsilon argument must be type double.\n");
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

   ANNpointArray Pts;
   ANNpoint      queryPt;
   Pts = annAllocPts(N, dim);

   for(int j=0; j < N; j++) {
      memcpy(Pts[j], pointset_pr+(j*dim), sizeof(double)*dim);
   }

   ANNkd_tree *searchtree = new ANNkd_tree(Pts, N, dim);

   /* do a little bit of processing */
   if(NN==0)
      NN = N;

   //Radius = Radius*Radius;


   /* allocate output arrays */
   //mxArray *idxs  = mxCreateNumericMatrix(NN, L, mxINT32_CLASS, mxREAL);
   //mxArray *dists = mxCreateDoubleMatrix(NN, L, mxREAL);
   mxArray *count = mxCreateNumericMatrix(1, L, mxINT32_CLASS, mxREAL);
   mxArray *dists = mxCreateCellMatrix(1, L);
   mxArray *idxs  = mxCreateCellMatrix(1, L);

   int *count_data = (int *)mxGetData(count);

   int *ANNidxs = new int[N];
   double *ANNdists = new double[N];

   /* perform the nearest neighhors searches */
   queryPt = annAllocPt(dim);

   for(int j=0; j < L; j++) {
      // copy the jth query point into queryPt
      memcpy(queryPt, querypts_pr+(j*dim), sizeof(double)*dim);


      int num = min(searchtree->annkFRSearch(queryPt, Radius, NN, ANNidxs, ANNdists), NN);
      count_data[j] = num;

      // create a MATLAB array to hold the indexes and stick it into the idxs cell array
      mxArray *tempidxs = mxCreateNumericMatrix(num, 1, mxINT32_CLASS, mxREAL);
      int *tempidxs_data = (int *)mxGetData(tempidxs);
      for(int i=0; i < num; i++)
         tempidxs_data[i] = (int)ANNidxs[i]+1;
      mxSetCell(idxs, j, tempidxs);


      // create a MATLAB array to hold the distances and stick it into the dists cell array
      mxArray *tempdists = mxCreateNumericMatrix(num, 1, mxDOUBLE_CLASS, mxREAL);
      double *tempdists_data = (double *)mxGetData(tempdists);
      memcpy(tempdists_data, ANNdists, sizeof(double)*num);
      mxSetCell(dists, j, tempdists);
   }

   plhs[0] = count;

   if(nlhs > 1)
      plhs[1] = idxs;
   else {
      //for(int j=0; j <
      mxDestroyArray(idxs);
   }

   if(nlhs > 2)
      plhs[2] = dists;
   else
      mxDestroyArray(dists);


   /* clean up and return */
   delete searchtree;
   annDeallocPts(Pts);
   annDeallocPt(queryPt);
   delete ANNidxs;
   delete ANNdists;
   annClose(); // deallocate any temporary structures used by ANN
}