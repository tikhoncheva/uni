twoLevelGM

There are no anchor descriptors. The similarity of the anchors is computed based on the matching score between their underlying subgraphs.

ver 4.3.3: based on the changes in IterativeApproach/ver4.3 from 09.09.2015
           use RRW to calculate similarity between edges
           use new function (weighNodes_3.m) to estimate transformations between subgraphs based on the RANSAC idea
           
           same version is used currently to test on real image data sets (img_trafo, house_seq)
           


ver4.3.2:  use grid to initialize anchors
           use update_subgraphs_3.m to update graph clusters
           do not use simulated annealing
	   do not eliminate small subgraphs (nV<4)
           use edge similarity between anchors
           use CPD (Coherent Point Drift) to estimate affine transformation between the clusters