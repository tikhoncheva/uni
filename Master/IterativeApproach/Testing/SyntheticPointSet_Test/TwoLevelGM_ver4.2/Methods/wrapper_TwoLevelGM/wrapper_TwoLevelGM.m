%% Two Level Graph Matching 
function [X, score] = wrapper_TwoLevelGM(LLG1, LLG2)

HLGmatches = struct('objval', 0, 'matched_pairs', []);
LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);  
affTrafo = [];

%% perform graph matching
[~, ~, LLGmatches, ~, ~, time, it] = ...
    twoLevelGM(1, LLG1, LLG2, [], [], LLGmatches, HLGmatches, affTrafo);

%%
pairs = LLGmatches(it).matched_pairs;
nV1 = size(LLG1.V,1); nV2 = size(LLG2.V,1);
ind = sub2ind([nV1, nV2], pairs(:,1), pairs(:,2));

X = zeros(nV1, nV2);
X(ind) = 1;

X = X(:);
score = LLGmatches(it).objval;


end