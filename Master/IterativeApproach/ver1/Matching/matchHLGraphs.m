%% Matching of anchor graphs
%  We use Reweighted Random Walk Algorithm for the graph matching
%   (see Minsu Cho, Jungmin Lee, and Kyoung Mu Lee "Reweighted Random Walks
%   for Graph Matching")
%
% Input
% HLG1, HLG2      two anchor graphs with nV1 and nV2 nodes respectively
%     HLG.V      coordinates of the nodes (n x 2)
%     HLG.E      list of edges 
%
% Output
%   objval      riched match score
%  matches      boolean matrix of matches if the size (nV1 x nV2)


function [objval, matches] = matchHLGraphs(HLG1, HLG2)

display(sprintf('\n================================================'));
display(sprintf('Match anchor graphs'));
display(sprintf('=================================================='));

try 
    v1 = HLG1.V';  %2xnV1
    v2 = HLG2.V';  %2xnV2
    
    d1 = HLG1.D;   % d x nV1 
    d2 = HLG2.D;   % d x nV2
                   % d - size of vectorized HoG - descriptor around node

    nV1 = size(v1,2);
    nV2 = size(v2,2);

    % adjacency matrix of the first anchor graph
    adjM1 = zeros(nV1, nV1);
    E1 = HLG1.E;
    E1 = [E1; [E1(:,2) E1(:,1)]];
    ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
    adjM1(ind) = 1;

    % adjacency matrix of the second anchor graph
    adjM2 = zeros(nV2, nV2);
    E2 = HLG2.E;
    E2 = [E2; [E2(:,2) E2(:,1)]];
    ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
    adjM2(ind) = 1;

    % correspondence matrix (!!!!!!!!!!!!!!!!!!!!!! now: all-to-all)
    corrMatrix = ones(nV1,nV2);

    % compute initial affinity matrix
    AffMatrix = initialAffinityMatrix2(v1, v2, d1, d2, adjM1, adjM2, corrMatrix);
    % AffMatrix = initialAffinityMatrix3(v1, v2, adjM1, adjM2, HLG1.W, HLG2.W, corrMatrix);

    % conflict groups
    [L12(:,1), L12(:,2)] = find(corrMatrix);
    [ group1, group2 ] = make_group12(L12);

    % run RRW Algorithm 
    tic
    x = RRWM(AffMatrix, group1, group2);
    display(sprintf('  time spent for the RRWM on the anchor graph: %f sec \n', toc));
    display(sprintf('=================================================='));

    X = greedyMapping(x, group1, group2);

    objval = x'*AffMatrix * x;

    matches = zeros(nV1, nV2);
    for i=1:size(L12,1)
        matches(L12(i,1), L12(i,2)) = X(i);
    end  

    matches = logical(matches);
catch ME
    msg = 'Error occurred in Higher Level Graph Matching';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);
    
    rethrow(ME);   
end