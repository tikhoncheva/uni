% SLIC_SUPERPIXELS is a rapid method for superpixel segmentation
% Function is called as follows:
%
%   [num, label, boundary] = SLIC_Superpixels(img, spnum, roundness)
%   
% Input arguments:
%   img - a color or grayscale image or video
%   spnum - desired number of superpixels
%   roundness - shape regularity (10: irregular to 50: very regular)
%
% Output arguments:
%   num - final number of superpixels
%   label - indicator of a superpixel a pixel is assigned to
%   boundary - superpixel boundaries superimposed onto original image (video)