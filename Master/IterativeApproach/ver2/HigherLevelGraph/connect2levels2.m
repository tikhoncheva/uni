%% define correspondences between graphs on higher and lower level
% A node v of Lower Level Graph correpondes to an anchor a from Higher
% Level Graph, if v is inside defined region around a
%
% Input
%   LLG     lower level graph, LLG = (V,D,E,U)
%   HLG     higher level graph, HLG = (V,D,E)
%     T     list of local transformation matrices estimated for each anchor node
%  gamma    parameter
% Output
%   U       correspondence matrix

function [U] = connect2levels2(LLG1, HLG1, LLG2, T, gamma)

    n = size(LLG1.V, 1);  % number of nodes in the lower level graph LLG
    m = size(HLG1.V, 1);  % number of nodes in the higher level graph HLG

    U1 = zeros(n, m);
    U2 = zeros(n, m);
    
    % for each node calculate it's distance to the nearest anchor
    diffx = repmat(LLG1.V(:,1), 1, m) - repmat(HLG1.V(:,1)', n, 1);
    diffy = repmat(LLG1.V(:,2), 1, m) - repmat(HLG1.V(:,2)', n, 1);
    dist = sqrt(diffx.^2 + diffy.^2);
    
    U1 = dist;
%     [minval, minpos] = min(dist, [], 2);
%     U1(sub2ind([n,m], [1:n]', minpos)) = minval;

    if (~isempty(T))
        tmpU2 = [];
        % for each anchor find nodes that have similar transformations as defined by the anchor 
        for j=1:m
            % T(j) is a [6x1] row-vector
            A = reshape(T(j, 1:4), 2, 2);
            b = T(j, 5:6)';
            fV = A * LLG1.V' + repmat(b,1,n);
            
            diffx = LLG2.V(:,1) - fV(:,1)';
            diffy = LLG2.V(:,2) - fV(:,2)';
            dist = sqrt(diffx.^2 + diffy.^2);         %      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            tmpU2 = [tmpU2, dist];
        end
        
        [minval, minpos] = min(tmpU2);
        
        
        
    end
    
    U = gamma*U1 + (1-gamma)*U2;
    
    [~, minpos] = min(U, [], 2);
    U = zeros(n,m);
    U(sub2ind([n,m], [1:n]', minpos)) = 1;
    
    U = logical(U);
end
