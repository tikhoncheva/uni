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
%       V        coordinates of the anchors
%       D_apper  decriptors of the anchors, based on the appearence of the
%                nodes in the underlying subgraphs
%       D_struc  decriptors of the anchors, based on the geometry of the
%                underlying subgraphs
%       E        list of the edges
%       U        matrix of correspondences between initial graph and anchor graph
%       F        0/1 vector with the size equal number of anchors
%                shows, wheter the anchors where changed cmparing to previous
%                iteration (0) or remain unchanged(1)

function [HLG] = buildHLGraph_use_InitMatches(ID, LLG, ind_InitialMatches, agparam)

fprintf(' - build higher level graph (anchor graph)');
t2 = tic;

nA = agparam.nA;            % number of anchors is given
fprintf('Number of Anchors %d', nA );

nV = size(LLG.V,1);                 % number of nodes in the LLG

HLG.V = zeros(nA,2);
HLG.E = [];
HLG.U = false(nV, nA);      % matrix of correspondences between nodes and anchors

V_InitialMatches = LLG.V(ind_InitialMatches,1:2);

ind_knn = knnsearch(V_InitialMatches, LLG.V(:,1:2));
[ind_anchors,anchor_centers] = kmeans(V_InitialMatches, nA);

HLG.V = anchor_centers;

sub2 = ind_anchors(ind_knn);
ind = sub2ind(size(HLG.U), (1:nV)', sub2);
HLG.U(ind) = true;
assert(sum(HLG.U(:))==nV, 'not all nodes were assigned to the anchors');

HLG.E = [repmat((1:nA)',nA,1), kron((1:nA)', ones(nA,1))];
HLG.E(HLG.E(:,1)==HLG.E(:,2),:) = [];
HLG.E = unique(sort(HLG.E,2), 'rows');  % delete same edges

HLG.F = zeros(size(HLG.V,1),1); % mark all subgraphs as new

% similarity of the anchors
HLG.D_appear = [];
HLG.D_struct = cell(nA,1);   

HLG.H = [];

fprintf('   finished in %f sec\n', toc(t2));
    

end