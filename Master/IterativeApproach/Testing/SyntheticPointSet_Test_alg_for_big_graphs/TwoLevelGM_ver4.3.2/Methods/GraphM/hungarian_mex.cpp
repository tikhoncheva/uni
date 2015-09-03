/*********************************************************************
 * Demo.cpp
 *
 * This file shows the basics of setting up a mex file to work with
 * Matlab.  This example shows how to use 2D matricies.  This may
 * 
 * Keep in mind:
 * <> Use 0-based indexing as always in C or C++
 * <> Indexing is column-based as in Matlab (not row-based as in C)
 * <> Use linear indexing.  [x*dimy+y] instead of [x][y]
 *
 * For more information, see my site: www.shawnlankton.com
 * by: Shawn Lankton
 *
 ********************************************************************/
#include <matrix.h>
#include <mex.h>   
#include <math.h>
#include <gsl/gsl_heapsort.h>
#include <gsl/gsl_matrix.h>
#include "hungarian.h"
#include <gsl/gsl_blas.h>
#include <gsl/gsl_permutation.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_eigen.h>


/* Definitions to keep compatibility with earlier versions of ML */
#ifndef MWSIZE_MAX
typedef int mwSize;
typedef int mwIndex;
typedef int mwSignedIndex;

#if (defined(_LP64) || defined(_WIN64)) && !defined(MX_COMPAT_32)
/* Currently 2^48 based on hardware limitations */
# define MWSIZE_MAX    281474976710655UL
# define MWINDEX_MAX   281474976710655UL
# define MWSINDEX_MAX  281474976710655L
# define MWSINDEX_MIN -281474976710655L
#else
# define MWSIZE_MAX    2147483647UL
# define MWINDEX_MAX   2147483647UL
# define MWSINDEX_MAX  2147483647L
# define MWSINDEX_MIN -2147483647L
#endif
#define MWSIZE_MIN    0UL
#define MWINDEX_MIN   0UL
#endif

#if !defined(MAX)
#define    MAX(A, B)    ((A) > (B) ? (A) : (B))
#endif

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  mxArray *a_in_m, *c_out_m;
  const mwSize *dims;
  int dimx, dimy, numdims;
    int i,j;
  double *c;

  dims = mxGetDimensions(prhs[0]);
  numdims = mxGetNumberOfDimensions(prhs[0]);
  dimy = (int)dims[0]; dimx = (int)dims[1];
  plhs[0] = mxCreateDoubleMatrix(dimx,dimy,mxREAL);
//  plhs[0] =   mxCreateNumericMatrix(dimx, dimy, mxSINGLE_CLASS, 0);

  gsl_matrix * D = gsl_matrix_alloc(dimx,dimy);
  D->data = mxGetPr(prhs[0]);
  gsl_matrix * E = gsl_matrix_alloc(dimx,dimy);
//  gsl_matrix * E;;

  c_out_m = plhs[0];
//  c = (float*)mxGetPr(c_out_m);
  c = mxGetPr(c_out_m);

 
//  E->data = mxGetPr(plhs[0]);
  E->data = mxGetPr(c_out_m);
  //E = gsl_matrix_hungarian(D);
  gsl_matrix_hungarian(D,E);

   for(i=0;i<dimx;i++)
    {
        for(j=0;j<dimy;j++)
        {
//            mexPrintf("element[%d][%d] = %f  %f \n",j,i,D->data[i*dimy+j],E->data[i*dimy+j]);
//            mexPrintf("element[%d][%d] = %f  %f \n",j,i,D->data[i*dimy+j],E->data[i*dimy+j],c[i*dimy+j]);
//              mexPrintf("element[%d][%d] = %f  %f \n",j,i,D->data[i*dimy+j]);
//              mexPrintf("element[%d][%d] = %f  %f \n",j,i,E->data[i*dimy+j]);
		c[i*dimy+j] = E->data[i*dimy+j];
//            mexPrintf("element[%d][%d] = %f\n",j,i,a[i*dimy+j]);
        }
    }


  gsl_matrix_free(E);
  gsl_matrix_free(D);

    return;
}
