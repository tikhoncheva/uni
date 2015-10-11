%% Matching Function, which matches descriptors of the nodes of two graphs
function [score, X, perform_data] = wrapper_featureMatching(LLG1, LLG2, GT)

thr = 1.1; % default 1.5 (see vl_feat library)
[matches, ~] = vl_ubcmatch(LLG1.D, LLG2.D, thr);

matches = matches';
score = matching_score(LLG1, LLG2, matches);

X = zeros(size(LLG1.V,1), size(LLG2.V,1));
X(sub2ind(size(X), matches(:,1), matches(:,2))) = 1;
X = X(:);

nCandMatch = size(LLG1.V,1)*size(LLG2.V,1);
nTrue = size(GT,1);
nDetected = nnz(X);
nTP = nnz(ismember(matches, GT, 'rows'));

perform_data = [nCandMatch, nTrue, nDetected, nTP, score];

end