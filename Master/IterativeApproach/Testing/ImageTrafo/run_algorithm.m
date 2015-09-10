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
accuracy = (X(:)'*invar.cdata.GTbool(:))/sum(invar.cdata.GTbool);

end
