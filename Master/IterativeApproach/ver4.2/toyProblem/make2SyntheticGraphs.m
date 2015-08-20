% based on Minsu Cho, makePointMatchingProblem, MPM_release_v1

%% make 2 synthetic graphs for testing graph matching algorithm
% Output
%   G1 = (V,D,E) first graph;  NOTE: D = []
%   G2 = (V,D,E) second graph; NOTE: D = []
%   GT = (LLpairs) ground thruth for matching on each of two
%                           levels

function [img1, img2, G1, G2, GT] = make2SyntheticPointSets()

    rng('default');
    
    % create two empty images
    s = 6;                                      % size of the images
    img1 = repmat(ones(s,s),1,1,3);
    img2 = repmat(ones(s,s),1,1,3);
    
    
    setParameters_synthetic_graphs;
    
    if bOutBoth
      n1 = nIn + nOut;		% number of nodes in the first set
    else
      n1 = nIn;
    end       
    n2 = nIn + nOut;    % number of nodes in the second set
    
    % Generate two graphs
    
    if bPermute
      seq = randperm(n2);
    else 
      seq = 1:n1;
    end
 
    % Generate graph 1
    G1 = tril(rand(n1),-1); % lower triangular graph
    G1 = G1+G1';
    P = tril(rand(n1),-1);
    P = P+P';
    P = P > ratioFill;
    G1(P) = NaN;
    
    N = deformation*tril(randn(n2),-1);
    N = N+N';
    
    % Generate graph 2
    G2 = tril(rand(nP2),-1);
    G2 = G2+G2';
    P = tril(rand(nP2),-1);
    P = P+P';
    P = P > ratioFill;
    G2(P) = NaN;
    G2(seq(1:nInlier),seq(1:nInlier)) = G1(1:nInlier,1:nInlier);
    G2 = G2+N;

    
    %% Ground Truth
    GT.LLpairs = [ [1:n1]'  , seq(1:n1)'];
    GT.HLpairs = [];

    
    
end