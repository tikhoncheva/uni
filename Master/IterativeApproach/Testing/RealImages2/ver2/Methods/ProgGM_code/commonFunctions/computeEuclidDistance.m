function [ distance, flip ] = computeEuclidDistance( viewInfo, matchlist , bReflective  )
%%   Compute the mutual affine transfer errors between two views
%   Output
%           distance: matrix of error distances
%           flip    : binary matrix notifying flips for matching 
%                     (non-zero only if single view matching)

% E.Tikhoncheva, 08.09.2015

nMatches = size(matchlist,1);

V1 = viewInfo(1).feat(:,1:2);
V2 = viewInfo(2).feat(:,1:2);

%% Distance Matrix
% [group1 group2 ] = make_group12(matchlist(:,1:2));
L1 = [repmat(matchlist(:,1), nMatches,1), kron(matchlist(:,1), ones(nMatches,1))];
L2 = [repmat(matchlist(:,2), nMatches,1), kron(matchlist(:,2), ones(nMatches,1))];

G1 = V1(L1(:,1),:)-V1(L1(:,2),:);
G2 = V2(L2(:,1),:)-V2(L2(:,2),:);
G1 = sqrt(G1(:,1).^2+G1(:,2).^2);
G2 = sqrt(G2(:,1).^2+G2(:,2).^2);
G1 = reshape(G1, [nMatches nMatches]);
G2 = reshape(G2, [nMatches nMatches]);

distance = (G1-G2).^2;

flip = false(nMatches,nMatches);