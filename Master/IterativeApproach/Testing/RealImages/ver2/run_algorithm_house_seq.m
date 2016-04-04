function [accuracy, score, time, X, perform_data] = run_algorithm(alg, invar)

cand_matchlist_init = invar.cdata.cand_matchlist_init;
X_GT = invar.cdata.GT_EXTbool;

if strcmp(alg, 'wrapper_ProgGM')
    start = tic;
    [score, X, Xraw, cand_matchlist, perform_data ]=...
            wrapper_ProgGM( invar.pparam, invar.method, invar.cdata, invar.extrapolation_dist);
    time = toc(start);

    Xfull = zeros(invar.n1, invar.n2);
    Xfull(sub2ind(size(Xfull), cand_matchlist(logical(X),1),cand_matchlist(logical(X),2) )) = 1;
    X = Xfull(:);  

end


if strcmp(alg, 'wrapper_TwoLevelGM')
    start = tic;
    [score, X, perform_data] = wrapper_TwoLevelGM(invar.LLG1, invar.LLG2, invar.cdata.GT);
    time = toc(start);
end    
    
if strcmp(alg, 'wrapper_featureMatching')
    start = tic;
    [score,X, perform_data] = wrapper_featureMatching(invar.LLG1, invar.LLG2, invar.cdata.GT);
    time = toc(start);
end        

% Measure accuracy
X_EXT = X';
% X_EXT = extrapolateMatchIndicator(invar.LLG1.V, invar.LLG2.V, cand_matchlist_init, X, invar.extrapolation_dist ); % extrapolate the solutions                
% X = X_EXT';
accuracy  = (X_EXT*X_GT')/nnz(X_GT)*100;

X_EXT_mat = zeros(invar.n1, invar.n2);
X_EXT_mat(sub2ind(size(X_EXT_mat), ...
          cand_matchlist_init(logical(X_EXT'),1),...
          cand_matchlist_init(logical(X_EXT'),2) )) = 1;
[matches(:,1), matches(:,2)] = find(X_EXT_mat);  

score = matching_score(invar.LLG1, invar.LLG2, matches);

%% detected correspondences from the provided GT
%  TP = ismember(matches(:,1:2), invar.cdata.GT, 'rows');
%  TP = sum(TP(:));
%  accuracy = TP/ size(invar.cdata.GT,1)*100;                        % recall ???

end
