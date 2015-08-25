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

function [HLG] = buildHLGraph_grid(ID, LLG, agparam)

fprintf(' - build higher level graph (anchor graph)');
t2 = tic;

nr = agparam.grid_nr;       % number of rows in the grid
nc = agparam.grid_nc;       % number of columns in the grid

nA = nr*nc;                 % each grid cell is represented by the anchor
fprintf('Number of Anchors %d', nA );

nV = size(LLG.V,1);                 % number of nodes in the LLG

HLG.V = zeros(nA,2);
HLG.E = [];
HLG.U = false(nV, nA);      % matrix of correspondences between nodes and anchors


hbound = linspace(min(LLG.V(:,1))-0.1, max(LLG.V(:,1))+0.1, nc+1);
vbound = linspace(min(LLG.V(:,2))-0.1, max(LLG.V(:,2))+0.1, nr+1);

for j = 1:nc
    ind_Vj = LLG.V(:,1)>hbound(j) & LLG.V(:,1)<hbound(j+1);
    
    for i = 1:nr
       % find nodes in the current grid cell
       ind_Vi = LLG.V(:,2)>=vbound(i) & LLG.V(:,2)<vbound(i+1);
       ind_Vij = ind_Vi & ind_Vj;
       
       aij = (j-1)*nr+i;
       HLG.V(aij,:) = [ (hbound(j+1)+hbound(j))/2, (vbound(i+1)+vbound(i))/2];
%        HLG.V(aij,:) = mean(LLG.V(ind_Vij, 1:2));
       HLG.U(ind_Vij, aij) = 1;
       
       aij_r = (min(j+1,nc)-1)*nr+i;
       aij_b = (j-1)*nr+min(i+1, nr);
       
       HLG.E = [HLG.E; [aij aij_r]; [aij aij_b]];
    end 
end
assert(sum(HLG.U(:))==nV, 'not all nodes were assigned to the anchors');

% eliminate subgraphs with less than 4 nodes
sum_nodes_in_subG = sum(HLG.U);
sum_nodes_in_subG(sum_nodes_in_subG==0) = inf;
ind_subG_to_del = sum_nodes_in_subG>0 & sum_nodes_in_subG<=3; % also subgraph with 3 nodes is is too small
while sum(ind_subG_to_del)>0
    
    [~, minpos] = min(sum_nodes_in_subG);
    a = minpos;
    
    ind_Va = find(HLG.U(:,a));
    Va = LLG.V(ind_Va,1:2);      % coordinates of the nodes in the subgraph G_a
    
    ind_feas_anchors = (1:nA);
    ind_feas_anchors(a) = []; ind_feas_anchors(sum_nodes_in_subG==0) = [];
    
    U_cut = HLG.U(:,ind_feas_anchors);
    [ind_feas_neighb, ~]= find(U_cut);
    ind_feas_neighb = unique(ind_feas_neighb);

    nn_Va = knnsearch(LLG.V(ind_feas_neighb,1:2), Va, 'K', 1);   %indices of nodes in LLG2.V
    nn_Va = ind_feas_neighb(nn_Va);
    HLG.U(ind_Va, :) = HLG.U(nn_Va, :);
    
    
    sum_nodes_in_subG = sum(HLG.U);
    sum_nodes_in_subG(sum_nodes_in_subG==0) = inf;
    ind_subG_to_del = sum_nodes_in_subG>0 & sum_nodes_in_subG<=3;
end


HLG.E(HLG.E(:,1)==HLG.E(:,2),:) = [];
HLG.E = unique(sort(HLG.E,2), 'rows');  % delete same edges

HLG.F = zeros(size(HLG.V,1),1); % mark all subgraphs as new

% similarity of the anchors
HLG.D_appear = [];
HLG.D_struct = cell(nA,1);   

fprintf('   finished in %f sec\n', toc(t2));
    

end