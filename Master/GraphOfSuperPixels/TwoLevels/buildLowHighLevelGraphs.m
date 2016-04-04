%% Two-Level approach for Graph Construction
% Higher Level Graph: Graph of Superpixels based on superpixel segmentation
%                     of the entire image
% Lower Level Graph:  Union of the Subgraphs. Each subgraph
%                     represents Graph of Superpixels built on the area around
%                     one superpixel from the previous level. The matrix U
%                     of Lower Level Graph contains the information about
%                     correspondences between Subgraphs and nodes(anchors)
%                     of the Higher Level Grpah
%
% Input 
%   img         given image
%   features   extracted edge points of the image and their descriptors
%   features = [edges, descriptors]
%   nSP_hl      number of superpixels for the higher level segmentation
%   nSP_ll      number of superpixels for the lower level segmentation
%
function [ HLGraph, LLGraph, SP_hl, SP_ll ] = buildLowHighLevelGraphs( img, features, nSP_hl, nSP_ll)

    display(sprintf('--------------------------------------------------'));
    display(sprintf('Two-level graph structure for the given image...'));
    display(sprintf('--------------------------------------------------'));
    t0 = tic ;
    
    display(sprintf('--------------------------------------------------'));
    display(sprintf('- build higher level graph (anchor graph)'));
    
    t1 = tic ;
    [HLGraph, SP_hl, SP_rectangles]   = buildHLGraph(img, features.edges, nSP_hl);
    display(sprintf(' finished in %f sec', toc(t1)));
    
   
    display(sprintf('--------------------------------------------------'));
    display(sprintf('- build lower level graph'));

    t2 = tic;
    [LLGraph, SP_ll] = buildLLGraph(img, features.edges, features.descr, SP_hl, SP_rectangles, nSP_ll);
    display(sprintf(' finished in %f sec', toc(t2)));
    
    % ASSERT: lower level graph should contain exactly the same number of nodes as
    % number of extracted edge points
    assert(size(LLGraph.V, 1) == size(features.edges,2), 'Lower level graph has wrong number of nodes');
    
    display(sprintf('--------------------------------------------------'));
    display(sprintf('Summary (%f sec) ', toc(t0)));
    display(sprintf('--------------------------------------------------'));
end

