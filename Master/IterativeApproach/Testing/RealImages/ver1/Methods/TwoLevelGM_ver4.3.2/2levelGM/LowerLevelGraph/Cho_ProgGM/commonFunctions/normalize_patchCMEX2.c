/*
 * normalizedPatch = normalize_patchCMEX( image, tr_matrix, scaling, patchSize ) 
 *
 * Image shoude be MxNx3 matrix, contains color image in double precision.
 * tr_matrix should be 1X9 vector. [a11, a12, x, a21, a22, y, 0, 0, 1]
 * scaling should be scalar value.
 * patchSize should be integer value.
 */
#include <math.h>
#include "mex.h"
/*#include "cv.h"*/
# define ROUND(i) (int)(i+0.5)
# define ROUND_UCHAR(i) (unsigned char)(i+0.5)


void normalizedPatchCMEX(const mxArray *mxImg, double *tr_matrix, double scaling, double patchSize, unsigned char *normalizedRegion, unsigned char *bOutside)
{
    double x, y, sc, h, w, halfSize, dx, dy;
    unsigned char *img;
    int i, j, k, xt, yt, chan;
    int temp;
    
    double matrixA[2][2];
    double matrixPt[2];
    double matrixPts[2];
    
    /* Get pointer from mxImg */
    img = (unsigned char *)mxGetPr(mxImg);
    
    /* Read transform data from tr_matrix, considering scale factor*/
    sc = 2 * scaling/patchSize;
    x = tr_matrix[2];
    y = tr_matrix[5];
    matrixA[0][0] = tr_matrix[0] * sc;
    matrixA[0][1] = tr_matrix[1] * sc;
    matrixA[1][0] = tr_matrix[3] * sc;
    matrixA[1][1] = tr_matrix[4] * sc;
    
    /* Compute half size. Get image size */
    halfSize=floor(patchSize/2);
    h = mxGetDimensions(mxImg)[0];
    w = mxGetDimensions(mxImg)[1];
    chan = mxGetDimensions(mxImg)[2];
    if (chan != 3) chan = 1;
    /*printf("h : %f\n", h);  */
    /*printf("w : %f\n", w);  */
    
    *bOutside = 0;
    for (i=-halfSize ; i<=halfSize ; i++)
    {
        /*printf("i : %d\n", i);      */
        for (j=-halfSize ; j<=halfSize ; j++)
        {
            /*printf("j : %d\n", j);     */
            matrixPt[0] = matrixA[0][0]*(double)i + matrixA[0][1]*(double)j;
            matrixPt[1] = matrixA[1][0]*(double)i + matrixA[1][1]*(double)j;
            
            matrixPts[0] = floor(matrixPt[0]);
            matrixPts[1] = floor(matrixPt[1]);
            
            xt = (int)matrixPts[0];
            yt = (int)matrixPts[1];
            
            dx = matrixPt[0] - matrixPts[0];
            dy = matrixPt[1] - matrixPts[1];
            
            if (ROUND(x+xt)>0 && ROUND(x+xt)+1<w && ROUND(y+yt)>0 && ROUND(y+yt)+1<h)
            {
                for (k=0;k<chan;k++)
                {
                    temp = (int)( (halfSize+1+i-1)*patchSize + (halfSize+1+j) + (k*patchSize*patchSize) -1);
                    /*printf("temp : %d\n", temp);      */
                    normalizedRegion[(int)( (halfSize+1+i-1)*patchSize + (halfSize+1+j) + (k*patchSize*patchSize) -1) ] = 
                        ROUND_UCHAR( img[(int)( ROUND(x+xt-1)*h + ROUND(y+yt) + (k*h*w) - 1) ] * (1-dx) * (1-dy) +
                        img[(int)(ROUND(x+xt-1)*h + ROUND(y+yt+1) + (k*h*w) - 1)] * (1-dx) * (dy) +
                        img[(int)(ROUND(x+xt+1-1)*h + ROUND(y+yt) + (k*h*w) - 1)] * (dx) * (1-dy) +
                        img[(int)(ROUND(x+xt+1-1)*h + ROUND(y+yt+1) + (k*h*w) - 1)] * (dx) * (dy) );
                }
            }
            else
            {
                for (k=0;k<chan;k++)
                {
                    normalizedRegion[(int)((halfSize+1+i-1)*patchSize + (halfSize+1+j) + (k*patchSize*patchSize) -1)] = 0;
                    *bOutside = 1;
                }
            }
        }
    }
    
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *tr_matrix, scaling, patchSize;
    unsigned char *normalizedRegion;
    unsigned char *outside;
    int dims[3];
    int chan;
    
    /* check number of input arguments */
    if (nrhs!=4)
        mexErrMsgTxt("4 inputs required.\n");

    /* define input argrments */
    tr_matrix = mxGetPr(prhs[1]);
    scaling = mxGetScalar(prhs[2]);
    patchSize = mxGetScalar(prhs[3]);
    
    chan = mxGetDimensions(prhs[0])[2];
    if (chan != 3) chan = 1;
    /*printf("%d chan",chan);*/
    dims[0] = (int)patchSize;
    dims[1] = (int)patchSize;
    dims[2] = chan;
    
    /* check image channel */
    /*if (chan != 3)
        mexErrMsgTxt("image should be color image.\n");*/
    /* check tr_matrix */
    if ((mxGetN(prhs[1]) != 9) || (mxGetM(prhs[1])!=1))
        mexErrMsgTxt("tr_matrix should be 1X9 vector.\n");
    
    /* define output argument */
    if ( chan == 1 )
        plhs[0] = mxCreateNumericMatrix( dims[0], dims[1], mxUINT8_CLASS, mxREAL);
    else
        plhs[0] = mxCreateNumericArray(chan, dims, mxUINT8_CLASS, mxREAL);
    
    normalizedRegion = (unsigned char *)mxGetPr(plhs[0]);
    plhs[1] = mxCreateNumericMatrix(1, 1, mxUINT8_CLASS, mxREAL);
    outside = (unsigned char *)mxGetPr(plhs[1]);
    
    normalizedPatchCMEX(prhs[0], tr_matrix, scaling, patchSize, normalizedRegion, outside);
}