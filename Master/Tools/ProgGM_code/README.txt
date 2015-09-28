%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%    MATLAB demo code of Progressive Graph Matching, CVPR 2012    %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Minsu Cho and Kyoung Mu Lee. 
"Progressive Graph Matching: Making a Move of Graphs via Probabilistic Voting", 
Proc. Computer Vision and Pattern Recognition (CVPR), 2012. 
http://cv.snu.ac.kr/research/~ProgGM/

Minsu Cho, Jungmin Lee and Kyoung Mu Lee. 
"Reweighted Random Walks for Graph Matching", 
Proc.  European Conference on Computer Vision (ECCV), 2010. 
http://cv.snu.ac.kr/research/~RRWM/

Please cite our work if you find this code useful in your research. 

written by Minsu Cho, Seoul National University, Korea
                      INRIA - WILLOW / ENS, Paris, France
                      http://www.di.ens.fr/~mcho/
                      minsu.cho@ens.fr
 
Date: 05/30/2013
Version: 1.0
==================================================================================================

1. Overview

do_demo_CVPR2012.m   : script to evaluate progressive graph matching
As performed in our paper, this script takes an image pair with ground truth data, and 
then evaluate ProgGM with respect to the number of progressive steps.
This code has two image pairs with ground truth. For details, refer to our CVPR 2012 paper. 

do_demo_matching.m   : script for an image matching demo
This script is provided for applications of ProgGM to other image matching problems.
It takes a reference image with a bounding box and then match features in the box to a test image.
To show the result, it sorts final matches w.r.t their matching scores (based on RRWM GM module), 
and visualizes them with jet color map (redish: higher scores, bluish: lower scores).
Any outlier elimination step could be used based on this score, depending on applications.

Note that, 
ProgGM basically aims at assigning the best feature for each feature of the reference image.  
While it updates the candidate matches in its progression steps, some effects of 
eliminating outlier features occur if no candidate is established at a background feature of the ref image.
(especially when # of candidate matches are relatively small. this script uses max 2000.)
However, ProgGM does not explicitly consider outlier elimination among features in the ref image.


compile_mex.m       : script for c-mex compilation.
If c-mex functions are incompatible, re-comple c-mex functions by running this.

setParams.m         : script for settings of parameters of feature extraction and initial matching

setMethods.m        : script for settings of graph matching modules in use
If you want to use other GM modules in ProgGM, three steps are required:
1. Create 'YOUR_ALGORITHM_NAME' folder in 'Methods' folder. Then put your code in it.
2. Add the folder in the script 'setPath.m' so that your method can be called.
3. Modify 'setMethods.m' for your method. Note that you should follow the 'methods' structure. 


2. References

This code includes RRWM and SM algorithms as graph matching modules
M. Cho, J. Lee, and K. M. Lee, Reweighted Random Walks for Graph Matching, ECCV 2010. (default)
M. Leordeanu and M. Hebert, A Spectral Technique for Correspondence Problems Using Pairwise Constraints, ICCV 2005. 

And, we utilized some functions of the following public implementations (Thanks for all authors);

Local feature detectors (MSER, Hessian and Harris Affine, SIFT)
http://www.robots.ox.ac.uk/~vgg/research/affine/
J.Matas, O. Chum, M. Urban, and T. Pajdla, Robust wide baseline stereo from maximally stable extremal regions. BMVC 2002. (default) 
K. Mikolajczyk and C. Schmid, Scale and Affine invariant interest point detectors. IJCV 2004
D. Lowe, Distinctive image features from scale invariant keypoints. IJCV 2004.

KD-tree search algorithm by G. Shechter and A. Tagliasacchi: 
http://www.mathworks.com/matlabcentral/fileexchange/21512-kd-tree-for-matlab

fast brute-force search algorithm by L. Giaccari
