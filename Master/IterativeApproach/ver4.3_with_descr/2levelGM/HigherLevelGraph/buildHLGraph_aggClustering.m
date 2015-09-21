% Approximative Graph Clustering using a kd-trees
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

function [HLG] = buildHLGraph_aggClustering(ID, LLG, agparam)

fprintf(' - build higher level graph (anchor graph)');
t2 = tic;

nA = agparam.nA;            % number of anchors is given
fprintf('Number of Anchors %d', nA );

nV = size(LLG.V,1);                 % number of nodes in the LLG

HLG.V = zeros(nA,2);
HLG.E = [];
HLG.U = false(nV, nA);      % matrix of correspondences between nodes and anchors
HLG.F = zeros(size(HLG.V,1),1); % mark all subgraphs as new
% similarity of the anchors
HLG.D_appear = [];
HLG.D_struct = cell(nA,1);   
% History
HLG.H = [];

%% construct kNN-graph
Labels = (1:nV);
Clusters = (1:nV)';
Cluster_centers = LLG.V(:,1:2);
dist = pdist2(Cluster_centers, Cluster_centers);
dist(1:nV+1:end) = Inf;

% tree = kdtree_build(LLG.V);

for it = 1:(nV-nA)
    % find clusters with smallest distance 
   [min_columns, minpos_j] = min(dist,[],2);
   [~, minpos_i] = min(min_columns);
   
   i = minpos_i;
   j = minpos_j(i);
   
   c1 = Labels(i);
   c2 = Labels(j);
   
   % merge clusters c1 and c2
   ind_c2 = Clusters==c2;
   Clusters(ind_c2) = c1;
   
   Cluster_centers(i,:) = (Cluster_centers(i,:)+Cluster_centers(j,:))/2;

   dist(j,:) = [];
   dist(:,j) = [];
   Labels(j) = [];
   Cluster_centers(j,:) = [];
   
   % update cluster center and distance to the other clusters   
   dist_vec = pdist2(Cluster_centers(i,:),Cluster_centers);
   dist(i,:) = dist_vec;
   dist(:,i) = dist_vec;
   dist(i,i) = Inf;  
    
end

%% build anchor graphs
HLG.V = Cluster_centers;
for i = 1:nA
    ind_A1 = Clusters==Labels(i);
    HLG.U(ind_A1,i) = true;
end

HLG.E = [repmat((1:nA)',nA,1), kron((1:nA)', ones(nA,1))];
HLG.E(HLG.E(:,1)==HLG.E(:,2),:) = [];
HLG.E = unique(sort(HLG.E,2), 'rows');  % delete same edges

fprintf('   finished in %f sec\n', toc(t2));
    
end