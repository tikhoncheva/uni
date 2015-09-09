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

    % Measure accuracy
%     X_GT = extrapolateGT( invar.LLG1.V,invar.LLG2.V, cand_matchlist, invar.cdata.GT, invar.extrapolation_dist ); % extrapolate the groundtruths
    X_EXT = extrapolateMatchIndicator(invar.LLG1.V, invar.LLG2.V, cand_matchlist_init, X, invar.extrapolation_dist ); % extrapolate the solutions                
    accuracy  = (X_EXT*X_GT')/nnz(X_GT)*100;

    X_EXT_mat = zeros(invar.n1, invar.n2);
    X_EXT_mat(sub2ind(size(X_EXT_mat), ...
              cand_matchlist_init(logical(X_EXT'),1),...
              cand_matchlist_init(logical(X_EXT'),2) )) = 1;
    [matches(:,1), matches(:,2)] = find(X_EXT_mat);  
    
    X = X_EXT;
    score = matching_score(invar.LLG1, invar.LLG2, matches);
      
%     accuracy = (X(:)'*invar.cdata.GTbool(:))/sum(invar.cdata.GTbool);

end


if strcmp(alg, 'wrapper_TwoLevelGM')
    start = tic;
    [X, score, perform_data] = wrapper_TwoLevelGM(invar.LLG1, invar.LLG2, invar.cdata.GT);
    time = toc(start);

    % Measure accuracy
    X_EXT = extrapolateMatchIndicator(invar.LLG1.V,invar.LLG2.V, cand_matchlist_init, X, invar.extrapolation_dist ); % extrapolate the solutions                
    accuracy  = (X_EXT*X_GT')/nnz(X_GT)*100;

    X_EXT_mat = zeros(invar.n1, invar.n2);
    X_EXT_mat(sub2ind(size(X_EXT_mat), ...
              cand_matchlist_init(logical(X_EXT'),1),...
              cand_matchlist_init(logical(X_EXT'),2) )) = 1;
    [matches(:,1), matches(:,2)] = find(X_EXT_mat);  
    
    X = X_EXT;
    score = matching_score(invar.LLG1, invar.LLG2, matches);
    
%     accuracy = (X(:)'*invar.cdata.GTbool(:))/sum(invar.cdata.GTbool);

end    
    
if strcmp(alg, 'wrapper_featureMatching')
    start = tic;
    [score,X, perform_data] = wrapper_featureMatching(invar.LLG1, invar.LLG2, invar.cdata.GT);
    time = toc(start);
    
    X_EXT = extrapolateMatchIndicator(invar.LLG1.V,invar.LLG2.V, cand_matchlist_init, X, invar.extrapolation_dist ); % extrapolate the solutions                
    accuracy  = (X_EXT*X_GT')/nnz(X_GT)*100;

    X_EXT_mat = zeros(invar.n1, invar.n2);
    X_EXT_mat(sub2ind(size(X_EXT_mat), ...
              cand_matchlist_init(logical(X_EXT'),1),...
              cand_matchlist_init(logical(X_EXT'),2) )) = 1;
    [matches(:,1), matches(:,2)] = find(X_EXT_mat);  
    
    X = X_EXT;
    score = matching_score(invar.LLG1, invar.LLG2, matches);
    
%    accuracy = (X(:)'*invar.cdata.GTbool(:))/sum(invar.cdata.GTbool);

end        
end
