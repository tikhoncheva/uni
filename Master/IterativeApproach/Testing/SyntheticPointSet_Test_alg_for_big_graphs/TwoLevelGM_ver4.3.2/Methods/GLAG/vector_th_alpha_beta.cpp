#include <matrix.h>
#include <mex.h>   
#include <math.h>

#if !defined(MAX)
#define    MAX(A, B)    ((A) > (B) ? (A) : (B))
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    mxArray *c_out_m, *d_out_m;
    const mwSize *dims;
    double *a, *b, *c, *d;
    double norm, lambda;
    int dimx, dimy, numdims;
    int i,j;

    dims = mxGetDimensions(prhs[0]);
    numdims = mxGetNumberOfDimensions(prhs[0]);
    dimy = (int)dims[0]; dimx = (int)dims[1];

    c_out_m = plhs[0] = mxCreateDoubleMatrix(dimy,dimx,mxREAL);
    d_out_m = plhs[1] = mxCreateDoubleMatrix(dimy,dimx,mxREAL);

    a = mxGetPr(prhs[0]);
    b = mxGetPr(prhs[1]);
    lambda = mxGetScalar(prhs[2]);
    c = mxGetPr(c_out_m);
    d = mxGetPr(d_out_m);

    for(i=0;i<dimx;i++)
    {
        for(j=0;j<dimy;j++)
        {
 	   norm = sqrt(a[i*dimy+j]*a[i*dimy+j] + b[i*dimy+j]*b[i*dimy+j]);
	   if (norm > 0)
		{
		   c[i*dimy+j] = MAX(0,1-lambda/norm)*a[i*dimy+j];
		   d[i*dimy+j] = MAX(0,1-lambda/norm)*b[i*dimy+j];
		}
        }
    }

    return;
}
