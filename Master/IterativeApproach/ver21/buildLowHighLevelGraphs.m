%% Two-Level approach for Graph Construction
% Higher Level Graph: Graph of Superpixels based on superpixel segmentation
%                     of the entire image
% Lower Level Graph:  kNN - graph based on the extracted edge points
%
% Input 
%   img         given image
%   features   extracted edge points of the image and their descriptors
%   features = [edges, descriptors]
%   nSP_hl      number of superpixels for the higher level segmentation
%
function [ HLGraph, LLGraph, SP_hl] = buildLowHighLevelGraphs( img, features, nSP_hl)

    display(sprintf('=================================================='));
    display(sprintf('Two-level graph structure for the given image...'));
    display(sprintf('=================================================='));
    t0 = tic ;    
   
    display(sprintf('\n - build lower level graph'));
    t1 = tic;
    LLGraph = buildLLGraph(features.edges, features.descr);
    display(sprintf('   finished in %f sec', toc(t1)));
    
    display(sprintf('\n - build higher level graph (anchor graph)'));
    t2 = tic;
    [HLGraph, SP_hl, SP_rect]   = buildHLGraph(img, features.edges, nSP_hl);  
%     [HLGraph, LLGraph.U]   = buildHLGraph2(img, features.edges(1:2,:)', nSP_hl);  
    display(sprintf('   finished in %f sec', toc(t2)));
    
    
    display(sprintf('\n - correspondences between two levels'));
    t3 = tic;
    LLGraph.U  = connect2levels(LLGraph, HLGraph, SP_rect);
    display(sprintf('   finished in %f sec', toc(t3)));
    
%     SP_hl.boundary = img;
    display(sprintf('--------------------------------------------------'));
    display(sprintf('Summary (%f sec) ', toc(t0)));
    display(sprintf('--------------------------------------------------'));
end

