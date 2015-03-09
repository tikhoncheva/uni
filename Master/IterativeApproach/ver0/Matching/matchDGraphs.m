%% Matching of dependency graphs
%
% Input
% DG1, DG2      two graphs with nV1 and nV2 nodes respectively
% AG1, AG2      corresponding anchor graphs
%
% Output
%   objval      riched match score
%  matches      boolean matrix of matches if the size (nV1 x nV2)


function [objval, matches] = matchDGraphs(DG1, DG2, AG1, AG2, AGmatches)

s = numel(find(AG1.U(1,:))>0);

nV1 = size(DG1.V,1);
nV2 = size(DG2.V,1);

% adjacency matrix of the first dependency graph
adjM1 = zeros(nV1, nV1);
E1 = DG1.E;
E1 = [E1; [E1(:,2) E1(:,1)]];
ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
adjM1(ind) = 1;

% adjacency matrix of the second dependency graph
adjM2 = zeros(nV2, nV2);
E2 = DG2.E;
E2 = [E2; [E2(:,2) E2(:,1)]];
ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
adjM2(ind) = 1;

matches = zeros(nV1, nV2);%, s);
% in each step we match points corresponding to the anchor match a1<->a2
for i=1:size(AG1.U,2)
    
    % corresponding points of the anchor a1i
    a1_x = AG1.U(:,i);
    v1 = DG1.V(AG1.U(:,i),:);          % vector adjM(U(:,i), :);
    nV1 = size(v1,2);
    E1cut = E1(a1_x, a1_x');
    
    % corresponding points of the anchor a2i
    a2_x = AG2.U(:, AGmatches(i,:)');
    v2 = DG2.V(a2_x)';
    nV2 = size(v2,2);
    E2cut = E2(a2_x, a2_x');
    
    % correspondence matrix (!!!!!!!!!!!!!!!!!!!!!! now: all-to-all)
    corrMatrix = ones(nV1,nV2);

    % compute initial affinity matrix
    AffMatrix = initialAffinityMatrix2(v1, v2, E1cut, E2cut, corrMatrix);
    
    % conflict groups
    [L12(:,1), L12(:,2)] = find(corrMatrix);
    [ group1, group2 ] = make_group12(L12);

    % run RRW Algorithm 
    tic
    x = RRWM(AffMatrix, group1, group2);
    sprintf('time spent for RRWM: %f sec', toc)

    X = greedyMapping(x, group1, group2);

    objval = x'*AffMatrix * x;
    
    matchesL = zeros(nV1, nV2);
    for j=1:size(L12,1)
        matchesL(L12(j,1), L12(j,2)) = X(j);
    end  
   
    matches(a1_x, a2_x') = matchesL;
end


end