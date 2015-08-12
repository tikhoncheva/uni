% Construction of Higher Level Graph (HLGraph) of a given image
% each of the given superpixels from superpixel segmentation of the image 
% represents a node of HLGraph
% Each node is a center of mass of the edge points inside corresponding 
% superpixel
% Two nodes are connected with an edge if the corresponding superpixels
% have a common edge
%
% Input 
%  LLG      initial graph
%  agparam  parameters for the anchor graph construction
% 
%
% Output
% HLG = (V, D, E) Higher Level Graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies (HoG)
%       E  list of the edges
%       U  matrix of correspondences between initial graph and anchor graph
%       F  0/1 vector with the size equal number of anchors
%          shows, wheter the anchors where changed cmparing to previous
%          iteration (0) or remain unchanged(1)
function [HLG] = buildHLGraph(ID, LLG, agparam)

fprintf(' - build higher level graph (anchor graph)');
t2 = tic;

nV = size(LLG.V,1);     % number of nodes in the LLG
% p = agparam.nA(ID);
% nA = round(p*nV);       % number of anchors
nA = min(nV, agparam.nA(ID));

alg = agparam.coarsAlg{agparam.coarsAlgInd};

switch alg
    case 'LEM_coarsen_2'
        HLG = LEM_coarsen_2(LLG, nA);
    case 'HEM_coarsen_2'
        HLG = HEM_coarsen_2(LLG, nA);
    otherwise
        error('please select valid algorithm for the graph coarsening');
end

% HLG.F = ones(size(HLG.V,1),1); 
HLG.F = zeros(size(HLG.V,1),1);

% similarity of the anchors
HLG.D_appear = [];
HLG.D_struct = cell(nA,1);   

fprintf('   finished in %f sec\n', toc(t2));
    

end