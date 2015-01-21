// SLIC_Supervoxels.cpp: MATLAB wrapper for the SLIC class.
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
	int ndims, width, height, depth, channels, sz, pos, i, d, numlabels, step;  
	unsigned int r, g, b;
	double compactness;
	const int *dim_array = NULL;
	int dims[4];
	unsigned char *video_input = NULL, *video_frame = NULL, *video_output = NULL; 
	unsigned int **ubuffvec = NULL; 
	int **labelsvec = NULL, *numlabels_output = NULL, *labels_output = NULL, *labels_frame = NULL;
	SLIC slic;
	
	ndims = mxGetNumberOfDimensions(prhs[0]);
	dim_array = mxGetDimensions(prhs[0]);
	height = dim_array[0];
	width = dim_array[1];
	channels = (ndims == 4) ? dim_array[2] : 1;
	depth = (ndims == 4) ? dim_array[3] : dim_array[2];	
	sz = height * width;
	video_input = (unsigned char *) mxGetData(prhs[0]);
	ubuffvec = new unsigned int*[depth];
	labelsvec = new int*[depth];
	for (d = 0; d < depth; d++) {
		ubuffvec[d] = new unsigned int[sz];
		labelsvec[d] = new int[sz];
	}
	step = mxGetScalar(prhs[1]);
	compactness = mxGetScalar(prhs[2]);

	for (d = 0; d < depth; d++) {
		video_frame = video_input + d * sz * channels;
		for (i = 0; i < sz; i++) {
 			b = g = r = video_frame[i];
			if (channels == 3) {
				g = video_frame[i + sz];
				b = video_frame[i + 2 * sz];
			}
			pos = (i % height) * width + (i / height);
			ubuffvec[d][pos] = b + (g << 8) + (r << 16);
		}
	}
	
	slic.DoSupervoxelSegmentation((const unsigned int**)ubuffvec, width, height, depth, labelsvec, numlabels, step, compactness);

	for (d = 0; d < depth; d++)
		slic.DrawContoursAroundSegments(ubuffvec[d], labelsvec[d], width, height, (unsigned int)0xFF << 8);

	dims[0] = dims[1] = 1;
	plhs[0] = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
	numlabels_output = (int *) mxGetData(plhs[0]);
	*numlabels_output = numlabels;

	dims[0] = height; dims[1] = width; dims[2] = depth;
	plhs[1] = mxCreateNumericArray(3, dims, mxINT32_CLASS, mxREAL);
	labels_output = (int *) mxGetData(plhs[1]);

	dims[0] = height; dims[1] = width; dims[2] = 3; dims[3] = depth;
	plhs[2] = mxCreateNumericArray(4, dims, mxUINT8_CLASS, mxREAL);
	video_output = (unsigned char *) mxGetData(plhs[2]);

	for (d = 0; d < depth; d++) {
		video_frame = video_output + d * sz * 3;
		labels_frame = labels_output + d * sz;	
		for (i = 0; i < sz; i++) {
			pos = (i % height) * width + (i / height);
			labels_frame[i] = labelsvec[d][pos];
			video_frame[i] = ubuffvec[d][pos] >> 16;
		 	video_frame[i + sz] = ubuffvec[d][pos] >> 8; 
			video_frame[i + 2 * sz] = ubuffvec[d][pos];
		}

	}
}                    
