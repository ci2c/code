#include "mex.h"
#include <math.h>
#include <malloc.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
int nx, ny, x, y, i, Length, L_V, j, k, l, Max_M, Min_M, L_Choice, *Prob_Choice, Temp, V1, V0, V00, R, *Choice, *V;
double *V_Seq, *Out1, *Out2;
double *Rand_w, *Image, *Min, *M_select, *ptr;
void *newptr;

if (nrhs != 2)
mexErrMsgTxt("Must have two inputs");
if (nlhs != 3)
mexErrMsgTxt("Must have three outputs");

nx = mxGetM(prhs[0]);
ny = mxGetN(prhs[0]);
srand(time(NULL));
x = rand() % nx;
y = rand() % ny;

Image = mxGetPr(prhs[0]);
Min = mxGetPr(prhs[1]);

plhs[2] = mxCreateDoubleMatrix(nx*ny, 1, mxREAL);
M_select = mxGetPr(plhs[2]);

Length = 4;
i = 0;
V0 = -1;
V00 = -1;

Rand_w = mxRealloc(NULL, Length*sizeof(double));
V_Seq = mxRealloc(NULL, Length*sizeof(double));

V = NULL;
Prob_Choice = NULL;
Choice = NULL;

while (1)
{
	if (i >= Length) {
		Min_M = Min[0];
		for (j=0;j<nx*ny;j++) {
			if (M_select[j] < Min_M)
				Min_M = M_select[j];
		}
		if (Min_M >= Min[0])
			break;
		
		Length *= 2;
		Rand_w = mxRealloc(Rand_w, Length*sizeof(double));
		V_Seq = mxRealloc(V_Seq, Length*sizeof(double));
	}
	
	if ((x > 0) && (y > 0) && (x < nx-1) && (y < ny -1))
	{
		V = mxRealloc(V, 8*sizeof(int));
		V[0] = nx*(y-1) + x - 1;
		V[1] = nx*(y-1) + x;
		V[2] = nx*(y-1) + x + 1;
		V[3] = nx*y + x - 1;
		V[4] = nx*y + x + 1;
		V[5] = nx*(y+1) + x - 1;
		V[6] = nx*(y+1) + x;
		V[7] = nx*(y+1) + x + 1;
		L_V = 8;
	}
	else {
	if (x * y == 0) {
		if ((x == 0) && (y == 0)) {
			V = mxRealloc(V, 3*sizeof(int));
			V[0] = nx;
			V[1] = 1;
			V[2] = nx + 1;
			L_V = 3;
		}

		if ((x == 0) && (y == ny-1)) {
			V = mxRealloc(V, 3*sizeof(int));
			V[0] = nx*(y-1);
			V[1] = nx*y + 1;
			V[2] = nx*(y-1) + 1;
			L_V = 3;
		}
		
		if ((x == 0) && (y > 0) && (y < ny - 1)) {
			V = mxRealloc(V, 5*sizeof(int));
			V[0] = nx*(y-1);
			V[1] = nx*(y+1);
			V[2] = nx*y + 1;
			V[3] = nx*(y-1)+1;
			V[4] = nx*(y+1)+1;
			L_V = 5;
		}
		
		if ((y == 0) && (x == nx - 1)) {
			V = mxRealloc(V, 3*sizeof(int));
			V[0] = x - 1;
			V[1] = nx + x;
			V[2] = nx + x-1;
			L_V = 3;
		}
		
		if ((y == 0) && (x > 0) && (x < nx-1)) {
			V = mxRealloc(V, 5*sizeof(int));
			V[0] = x - 1;
			V[1] = x + 1;
			V[2] = nx + x - 1;
			V[3] = nx + x;
			V[4] = nx + x + 1;
			L_V = 5;
		}
	}
	else {
		if ((x == nx - 1) && (y == ny - 1)) {
			V = mxRealloc(V, 3*sizeof(int));
			V[0] = nx*y + x - 1;
			V[1] = nx*(y-1) + x;
			V[2] = nx*(y-1) + x-1;
			L_V = 3;
		}
		else {
			if (x == nx - 1) {
				V = mxRealloc(V, 5*sizeof(int));
				V[0] = nx * y + x - 1;
				V[1] = nx * (y-1) + x-1;
				V[2] = nx * (y-1) + x;
				V[3] = nx * (y+1) + x;
				V[4] = nx * (y+1) + x-1;
				L_V = 5;
			}
			if (y == ny - 1) {
				V = mxRealloc(V, 5*sizeof(int));
				V[0] = nx * y + x - 1;
				V[1] = nx * y + x + 1;
				V[2] = nx * (y-1) + x - 1;
				V[3] = nx * (y-1) + x;
				V[4] = nx * (y-1) + x+1;
				L_V = 5;
			}
		}
	}
	}
	
	Max_M = -1;
	for (j=0;j<L_V;j++) {
		if (M_select[V[j]] > Max_M)
			Max_M = M_select[V[j]];
	}

	Prob_Choice = mxRealloc(Prob_Choice, L_V*sizeof(int));
	L_Choice = 0;
	for (j=0;j<L_V;j++) {
		Temp = Max_M - M_select[V[j]];
		Temp = 1 << Temp;
		Prob_Choice[j] = Temp;
		L_Choice += Temp;
	}
	
	Choice = mxRealloc(Choice, L_Choice*sizeof(int));
	l = 0;
	for (j=0;j<L_V;j++) {
		for (k=0;k<Prob_Choice[j]; k++) {
			Choice[l] = V[j];
			l++;
		}
	}
	
	R = rand() % L_Choice;
	V1 = Choice[R];
	
	if (V1 != V00) {
		V_Seq[i] = V1;
		Rand_w[i] = Image[V1];
		M_select[V1]++;
		V00=V0;
		V0=V1;
		y = floor(V1 / nx);
		x = V1 - nx * y;
		i++;
	}
}

plhs[0] = mxCreateDoubleMatrix(Length, 1, mxREAL);
plhs[1] = mxCreateDoubleMatrix(Length, 1, mxREAL);
Out1 = mxGetPr(plhs[0]);
Out2 = mxGetPr(plhs[1]);
for (j=0;j<Length;j++) {
	Out1[j] = Rand_w[j];
	Out2[j] = V_Seq[j];
}

}
