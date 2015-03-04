% Construct anchor graph of an image according to given dependeny graph and
% coordinates of the selected anchors

% Wei Liu, Junfeng He, Shih-Fu Chang Large 
% "Graph construction for scalable semi-supervised learning"

% 
% DG        given dependency graph
% acoord    coordinates of the selected anchors
% kNN       number of nearest neighbors
%
% AG = {    anchor graph
%       V,  coordinates of the vertices
%       E,  list of the edges
%       U,  correspondences between vertices of the DG and anchor points
%       Z,  regression matrix (weights of the correspondences between vertices of
%           the initial graph DG and anchors)
%       W   weights of the edges}

% !!!!!!!!!!!!!! anchor graph is a complete graph !!!!!!!!!!!!!!
function AG = buildAGraph(DG, acoord, kNN)

    m = size(acoord, 1);  % number of anchor points
    n = size(DG.V, 1);    % number of initial edges
    
    % coordinates of the anchor points
    AG.V = acoord;
    
    % edges between the anchor points
    [v1,v2] = meshgrid(1:m, 1:m);
    AG.E = [v1(:) v2(:)];
    
    % correspondences to the vertices of the initial graph
    AG.U = nearest_anchors(DG.V, AG.V, kNN);
    
    % regression matrix
    AG.Z = LocalAnchorEmbedding(DG.V, AG.U, AG.A);  % Local Anchor Embedding    
    
    
end