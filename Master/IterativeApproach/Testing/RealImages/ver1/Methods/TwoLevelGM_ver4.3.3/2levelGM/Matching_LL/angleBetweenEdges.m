%% Calculate pairwise similarity between node descriptors
% assume, that two given sets of nodes define two fully conencted graphs,
% compute cosine of the angle (0..pi) between each edge of the first graph
% and all edges of the second graph
%
% Input
%       x1: 2 x n1 set of n1 vectors
%       x2: 2 x n2 set of n2 vectors
%
% Output
%      M: matrix containing the cosine of the angle between pairs of edges

function [M] = angleBetweenEdges(x1, x2)

    n1 = size(x1, 2);
    n2 = size(x2, 2);
    
    G1 = squareform(pdist(x1', 'euclidean'));
    G1x = abs(repmat(x1(1,:), n1,1) - repmat(x1(1,:)', 1, n1) );
    G1y = abs(repmat(x1(2,:), n1,1) - repmat(x1(2,:)', 1, n1) );

    cA1 = G1x./G1;      % cosine of edges slote in the first graph
    sA1 = G1y./G1;      % sine of edges slote in the first graph
    
    
    G2 = squareform(pdist(x2', 'euclidean'));
    G2x = abs(repmat(x2(1,:), n2,1) - repmat(x2(1,:)', 1, n2) );
    G2y = abs(repmat(x2(2,:), n2,1) - repmat(x2(2,:)', 1, n2) );

    cA2 = G2x./G2;      % cosine of edges slote in the second graph
    sA2 = G2y./G2;      % sine of edges slote in the second graph 
    
    McA1 = repmat(cA1, n2, n2);
    MsA1 = repmat(sA1, n2, n2);
    
    McA2 = kron(cA2,ones(n1));
    MsA2 = kron(sA2,ones(n1));
    
    M = McA1.*McA2 + MsA1.*MsA2; % cos(a-b) = cos(a)cos(b)+sin(a)sin(b)

    M(isnan(M)) = 0;
    
end
