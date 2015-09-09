function [accuracy, score, time, X, perform_data] = run_algorithm(alg, invar)

if strcmp(alg, 'wrapper_ProgGM')
    start = tic;
    [score, X, Xraw, cand_matchlist, perform_data ]=...
            wrapper_ProgGM( invar.pparam, invar.method, invar.cdata, invar.extrapolation_dist);
    time = toc(start);
    
    % Measure accuracy
%     X_GT = extrapolateGT( cdata.view, cand_matchlist, cdata.GT, mparam.extrapolation_dist ); % extrapolate the groundtruths
%     X_EXT = extrapolateMatchIndicator( cdata.view, cand_matchlist, X{i}, mparam.extrapolation_dist ); % extrapolate the solutions                
    
    Xfull = zeros(invar.n1, invar.n2);
    Xfull(sub2ind(size(Xfull), cand_matchlist(logical(X),1),cand_matchlist(logical(X),2) )) = 1;
    X = Xfull(:);  
    accuracy = (X(:)'*invar.cdata.GTbool(:))/sum(invar.cdata.GTbool);

end


if strcmp(alg, 'wrapper_TwoLevelGM')
    start = tic;
    [X, score, perform_data] = wrapper_TwoLevelGM(invar.LLG1, invar.LLG2, invar.cdata.GT);
    time = toc(start);

    % Measure accuracy
%     X_GT = extrapolateGT( cdata.view, cand_matchlist, cdata.GT, mparam.extrapolation_dist ); % extrapolate the groundtruths
%     X_EXT = extrapolateMatchIndicator( cdata.view, cand_matchlist, X{i}, mparam.extrapolation_dist ); % extrapolate the solutions                
    
%     X_GT = inpuvar.cdata.GTbool;
%     X_list =  X';
    
    accuracy = (X(:)'*invar.cdata.GTbool(:))/sum(invar.cdata.GTbool);
%     accuracy  = (X_list*X_GT')/nnz(X_GT)*100;

end    
    
if strcmp(alg, 'wrapper_featureMatching')
    start = tic;
    [score,X, perform_data] = wrapper_featureMatching(invar.LLG1, invar.LLG2, invar.cdata.GT);
    time = toc(start);
    
    accuracy = (X(:)'*invar.cdata.GTbool(:))/sum(invar.cdata.GTbool);
%     accuracy  = (X_list*X_GT')/nnz(X_GT)*100;

end        
end
