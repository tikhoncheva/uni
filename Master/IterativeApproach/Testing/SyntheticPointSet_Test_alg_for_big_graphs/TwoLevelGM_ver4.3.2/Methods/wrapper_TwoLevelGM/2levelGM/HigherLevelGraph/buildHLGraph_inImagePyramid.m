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
%
function [HLG] = buildHLGraph_inImagePyramid(LLG, LLG_prevL, varargin)

fprintf(' - build higher level graph (anchor graph) based on LLG from previous level');
t2 = tic;

% find unmatched nodes in LLG_prev
nV_prev = size(LLG_prevL.V,1);
unmatched_nodes = [];
if (nargin == 3)
    LLGmatches_prevL = varargin{1};
    if isempty(LLGmatches_prevL(end).matched_pairs(:,1))
        error('nothing was matched on the previous level!');
    end
    are_matched = ismember([1:nV_prev]', LLGmatches_prevL(end).matched_pairs(:,1));
    unmatched_nodes = find(are_matched==0);
end


HLG = LLG_prevL;
% delete unmatched nodes, their descriptors and edges to them
HLG.V(unmatched_nodes, :) = []; HLG.V = HLG.V(:,1:2);
HLG.V = HLG.V * 2; 
nA = size(HLG.V,1);     % number of anchors
HLG.D(:,unmatched_nodes) = [];
ind1 = ismember(HLG.E(:,1), unmatched_nodes);
ind2 = ismember(HLG.E(:,2), unmatched_nodes);
HLG.E(ind1|ind2,:) = [];
HLG.E = unique(sort(HLG.E,2), 'rows');  % delete same edges
% after deletion the indexing of nodes in E is probably wrong, so we correct it
old_ind = [1:nV_prev]'; old_ind(unmatched_nodes) = [];
new_ind = zeros(nV_prev,1); new_ind(old_ind) = [1:nA]; 
HLG.E(:,1) = new_ind(HLG.E(:,1));
HLG.E(:,2) = new_ind(HLG.E(:,2));

% correspondences between nodes of LLG and HLG (matrix U);
nV = size(LLG.V,1);     % number of nodes in the LLG
U = false(nV, nA);
[nn, ~] = knnsearch(HLG.V, LLG.V(:,1:2));   %indices of nodes in LLG2.V
ind = sub2ind(size(U), [1:nV]', nn);
U(ind) = true;
HLG.U = U;
% split node between anchors, so that there is no empty anchor

% HLG.F = ones(size(HLG.V,1),1); 
HLG.F = zeros(size(HLG.V,1),1);

% similarity of the anchors
HLG.D_appear = [];
HLG.D_struct = cell(nA,1);   

fprintf('   finished in %f sec\n', toc(t2));
    
end