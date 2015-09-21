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

function [HLG1, HLG2] = buildHLGraphs_use_InitMatches(LLG1, LLG2, InitialMatches, agparam)

fprintf(' - build higher level graphs (anchor graph)');
t2 = tic;

nA = agparam.nA;            % number of anchors is given
fprintf('Number of Anchors %d', nA );

nV1 = size(LLG1.V,1);                 % number of nodes in the LLG1
nV2 = size(LLG2.V,1);                 % number of nodes in the LLG2

HLG1.V = zeros(nA,2);
HLG1.E = [];
HLG1.U = false(nV1, nA);      % matrix of correspondences between nodes and anchors

HLG2.V = zeros(nA,2);
HLG2.E = [];
HLG2.U = false(nV2, nA);      % matrix of correspondences between nodes and anchors

%% find nodes, that have similar affine transformation
V1_Labels = zeros(nV1,1);
V2_Labels = zeros(nV2,1);
it = 1;
nMaxIt = nV1/5;
list = InitialMatches;
list_V1 = LLG1.V(list(:,1),1:2);
list_V2 = LLG2.V(list(:,2),1:2);
while size(list,1)>3 && it<nMaxIt
%    [~,inlier1,inlier2] = estimateGeometricTransform(list_V1, list_V2, 'affine');
%    [~, ind_v1] = ismember(inlier1, LLG1.V(:,1:2), 'rows');
%    [~, ind_v2] = ismember(inlier2, LLG2.V(:,1:2), 'rows'); 

   [~, inlier] = ransacfitaffine(list_V1', list_V2', 0.001);
   ind_v1 = list(inlier,1);
   ind_v2 = list(inlier,2);

   V1_Labels(ind_v1, 1) = it;
   V2_Labels(ind_v2, 1) = it;
   
   ind_same_v1 = ismember(list(:,1), ind_v1);
   ind_same_v2 = ismember(list(:,2), ind_v2);
   list(ind_same_v1|ind_same_v2,:) = [];
   list_V1 = LLG1.V(list(:,1),1:2);
   list_V2 = LLG2.V(list(:,2),1:2);
   it = it + 1;
end
V1_Labels(list(:,1), 1) = it;
V2_Labels(list(:,2), 1) = it;

nClusters = it;
%% distance matrix between the clusters
dist = zeros(it,it);
for l1 = 1:nClusters
    ind_C1 = V1_Labels==l1;
    C1 = LLG1.V(ind_C1,1:2);
    
    for l2 = l1+1:nClusters
        ind_C2 = V1_Labels==l2;
        C2 = LLG1.V(ind_C2,1:2);
        
        d = pdist2(C1,C2);
        dist(l1,l2) = mean(d(:)); 
    end
end
dist = dist + dist';
dist(1:nClusters+1:end) = Inf;

%% do agglomerative clustering
Labels = (1:nClusters);
for it = 1:nClusters-nA
   % find clusters with smallest distance 
   [min_columns, minpos_j] = min(dist,[],2);
   [~, minpos_i] = min(min_columns);
   
   i = minpos_i;
   j =  minpos_j(i);
   
   l1 = Labels(i);
   l2 = Labels(j);
   
   % merge clusters in the first graph
   ind_l2 = V1_Labels==l2;
   V1_Labels(ind_l2) = l1;
   % merge clusters in the second graph
   ind_l2 = V2_Labels==l2;
   V2_Labels(ind_l2) = l1;
   
   dist(j,:) = [];
   dist(:,j) = [];

   Labels(j) = [];
   
   % update distance between new merged cluster and all others
   ind_l1 = V1_Labels==l1;
   C1 = LLG1.V(ind_l1,1:2);
    
    for j = 1:numel(Labels)
        l2 = Labels(j);
        ind_C2 = V1_Labels==l2;
        C2 = LLG1.V(ind_C2,1:2);
        
        d = pdist2(C1,C2);
        
        dist(i,j) = mean(d(:));
    end    
    dist(:,i) = dist(i,:);
    dist(i,i) = Inf;
end

%% build anchor graphs
HLG1.V = zeros(nA,2);
HLG2.V = zeros(nA,2);
for i = 1:nA
    ind_V1 = V1_Labels==Labels(i);
    ind_V2 = V2_Labels==Labels(i);
    
    HLG1.U(ind_V1,i) = true;
    HLG2.U(ind_V2,i) = true;
    
    HLG1.V(i,1:2) = mean(LLG1.V(ind_V1,1:2));
    HLG2.V(i,1:2) = mean(LLG2.V(ind_V2,1:2));
end
HLG1.E = [repmat((1:nA)',nA,1), kron((1:nA)', ones(nA,1))];
HLG1.E(HLG1.E(:,1)==HLG1.E(:,2),:) = [];
HLG1.E = unique(sort(HLG1.E,2), 'rows');  % delete same edges

HLG2.E = [repmat((1:nA)',nA,1), kron((1:nA)', ones(nA,1))];
HLG2.E(HLG2.E(:,1)==HLG2.E(:,2),:) = [];
HLG2.E = unique(sort(HLG2.E,2), 'rows');  % delete same edges

%% for all unclustered nodes assign next lying anchor
ind_V1_unclustered = V1_Labels==0;
dist_to_anchors = pdist2(LLG1.V(ind_V1_unclustered,1:2), HLG1.V);
[~, next_anchor] = min(dist_to_anchors, [], 2);
ind = sub2ind(size(HLG1.U), find(ind_V1_unclustered), next_anchor);
HLG1.U(ind) = true;

ind_V2_unclustered = V2_Labels==0;
dist_to_anchors = pdist2(LLG2.V(ind_V2_unclustered,1:2), HLG2.V);
[~, next_anchor] = min(dist_to_anchors, [], 2);
ind = sub2ind(size(HLG2.U), find(ind_V2_unclustered), next_anchor);
HLG2.U(ind) = true;

assert(sum(HLG1.U(:))==nV1, 'not all nodes were assigned to the anchors');
assert(sum(HLG2.U(:))==nV2, 'not all nodes were assigned to the anchors');


HLG1.F = zeros(size(HLG1.V,1),1); % mark all subgraphs as new
HLG2.F = zeros(size(HLG2.V,1),1); % mark all subgraphs as new

% similarity of the anchors
HLG1.D_appear = [];
HLG2.D_appear = [];

HLG1.D_struct = cell(nA,1);   
HLG2.D_struct = cell(nA,1);   

HLG1.H = [];
HLG2.H = [];

fprintf('   finished in %f sec\n', toc(t2));
    
end