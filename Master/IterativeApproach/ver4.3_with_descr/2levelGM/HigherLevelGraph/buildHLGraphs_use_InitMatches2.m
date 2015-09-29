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

function [HLG1, HLG2] = buildHLGraphs_use_InitMatches2(LLG1, LLG2, InitialMatches, agparam)

fprintf(' - build higher level graphs (anchor graph)\n');
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

list = InitialMatches.list;
affMatrix = InitialMatches.affM;

list_V1 = LLG1.V(list(:,1),1:2);
list_V2 = LLG2.V(list(:,2),1:2);

ind_V1 = (1:nV1)'; ind_V1(list(:,1),:) = [];
rest_V1 = LLG1.V(ind_V1,1:2);
ind_V2 = (1:nV2)'; ind_V2(list(:,2),:) = [];
rest_V2 = LLG2.V(ind_V2,1:2);

[NcutDiscrete,~,~] = ncutW(affMatrix,nA);

HLG1.U(list(:,1),:) = NcutDiscrete;
HLG2.U(list(:,2),:) = NcutDiscrete;

[indx1,D1] = knnsearch(list_V1, rest_V1);
[indx2,D2] = knnsearch(list_V2, rest_V2);

HLG1.U(ind_V1,:) = HLG1.U(list(indx1,1),:);
HLG2.U(ind_V2,:) = HLG2.U(list(indx2,2),:);

%%
assert(sum(HLG1.U(:))==nV1, 'not all nodes were assigned to the anchors');
assert(sum(HLG2.U(:))==nV2, 'not all nodes were assigned to the anchors');

%% build anchor graphs
HLG1.V = zeros(nA,2);
HLG2.V = zeros(nA,2);
for i = 1:nA
    HLG1.V(i,1:2) = mean(LLG1.V(HLG1.U(:,i),1:2));
    HLG2.V(i,1:2) = mean(LLG2.V(HLG2.U(:,i),1:2));
end

HLG1.E = [repmat((1:nA)',nA,1), kron((1:nA)', ones(nA,1))];
HLG1.E(HLG1.E(:,1)==HLG1.E(:,2),:) = [];
HLG1.E = unique(sort(HLG1.E,2), 'rows');  % delete same edges

HLG2.E = [repmat((1:nA)',nA,1), kron((1:nA)', ones(nA,1))];
HLG2.E(HLG2.E(:,1)==HLG2.E(:,2),:) = [];
HLG2.E = unique(sort(HLG2.E,2), 'rows');  % delete same edges


%%
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