// SLIC_Superpixels.cpp: MATLAB wrapper for the SLIC class.
//===========================================================================
// This MEX code acts as an interfaces between SLIC class and MATLAB.
//
//===========================================================================
// Copyright (c) 2011 Borislav Antic [Uni-Heidelberg]. All rights reserved.
//===========================================================================
// Email: borislav.antic@iwr.uni-heidelberg.de
//////////////////////////////////////////////////////////////////////

#include <string.h>
#include "mex.h"
#include "SLIC.h"

void mexFunction(int nlhs, mxArray *plhs[ ],int nrhs, const mxArray *prhs[ ]) 
{
	int ndims, width, height, channels, sz, pos, i, numlabels, spcount;  
	unsigned int r, g, b;
	double compactness;
	const int *dim_array = NULL;
	int dims[3];
	unsigned char *img_input = NULL, *img_output = NULL; 
	unsigned int *ubuff = NULL; 
	int *labels = NULL, *numlabels_output = NULL, *labels_output = NULL;
	SLIC slic;
	
	ndims = mxGetNumberOfDimensions(prhs[0]);
	dim_array = mxGetDimensions(prhs[0]);
	height = dim_array[0];
	width = dim_array[1];
	channels = (ndims == 3) ? dim_array[2] : 1;	
	sz = height * width;
	img_input = (unsigned char *) mxGetData(prhs[0]);
	ubuff = (unsigned int *) mxCalloc(sz, sizeof(unsigned int));
	labels = (int *) mxCalloc(sz, sizeof(int));
	spcount = mxGetScalar(prhs[1]);
	compactness = mxGetScalar(prhs[2]);

	for (i = 0; i < sz; i++) {
		b = g = r = img_input[i];
		if (channels == 3) {
			g = img_input[i + sz];
			b = img_input[i + 2 * sz];
		}
		pos = (i % height) * width + (i / height);
		ubuff[pos] = b + (g << 8) + (r << 16);
	}
	
	slic.DoSuperpixelSegmentation_ForGivenK(ubuff, width, height, labels, numlabels, spcount, compactness);
	slic.DrawContoursAroundSegments(ubuff, labels, width, height, 0xFF << 8);

	dims[0] = dims[1] = 1;
	plhs[0] = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
	numlabels_output = (int *) mxGetData(plhs[0]);
	*numlabels_output = numlabels;

	dims[0] = height; dims[1] = width;
	plhs[1] = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
	labels_output = (int *) mxGetData(plhs[1]);
	
	dims[0] = height; dims[1] = width; dims[2] = 3;
	plhs[2] = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);	
	img_output = (unsigned char *) mxGetData(plhs[2]);

	for (i = 0; i < sz; i++) {
		pos = (i % height) * width + (i / height);
		labels_output[i] = labels[pos];
		img_output[i] = ubuff[pos] >> 16;
		img_output[i + sz] = ubuff[pos] >> 8; 
		img_output[i + 2 * sz] = ubuff[pos];
	}

}                    
