function [accuracy1, accuracy2, accuracy3, ...
             score1, score2, time, ...
          X1, X2, perform_data] = run_algorithm_house_seq(alg, invar)

cand_matchlist_init = invar.cdata.cand_matchlist_init;
X_GT = invar.cdata.GT_EXTbool;

if strcmp(alg, 'wrapper_ProgGM')
    start = tic;
%     [score2, X, Xraw, cand_matchlist, perform_data ]=...
%             wrapper_ProgGM( invar.pparam, invar.method, invar.cdata, invar.extrapolation_dist);
    [score_tmp, X1, ~, cand_matchlist, ~] =  ...
              wrapper_ProgGM_lite( invar.pparam, invar.method, invar.cdata);
    perform_data = [];
              
    Xfull = zeros(invar.n1, invar.n2);
    Xfull(sub2ind(size(Xfull), cand_matchlist(logical(X1),1),cand_matchlist(logical(X1),2) )) = 1;
    X1 = Xfull(:);  
    
%     X_EXT = extrapolateMatchIndicator(invar.LLG1.V, invar.LLG2.V, cand_matchlist_init, X, invar.extrapolation_dist ); % extrapolate the solutions                
%     X = X_EXT';
    
    time = toc(start);
end


if strcmp(alg, 'wrapper_TwoLevelGM')
    start = tic;
    [score_tmp, X1, perform_data] = wrapper_TwoLevelGM(invar.LLG1, invar.LLG2, invar.cdata.GT);
    time = toc(start);
end  

    
if strcmp(alg, 'wrapper_featureMatching')
    start = tic;
    [score_tmp, X1, perform_data] = wrapper_featureMatching(invar.LLG1, invar.LLG2, invar.cdata.GT);
    time = toc(start);
end      

% solution
X_EXT = X1';

% Measure accuracy
accuracy1  = (X_EXT*X_GT')/nnz(X_GT)*100;
matches1 = cand_matchlist_init(logical(X_EXT'),1:2);
score1 = matching_score(invar.LLG1, invar.LLG2, matches1);

% ext_solution
X_EXT = extrapolateMatchIndicator(invar.LLG1.V, invar.LLG2.V, cand_matchlist_init, X1, invar.extrapolation_dist ); % extrapolate the solutions                
X2 = X_EXT';
accuracy2  = (X_EXT*X_GT')/nnz(X_GT)*100;
matches2 = cand_matchlist_init(logical(X_EXT'),1:2);
score2 = matching_score(invar.LLG1, invar.LLG2, matches2);

%% detected correspondences from the provided GT
 TP = ismember(matches2(:,1:2), invar.cdata.GT, 'rows');
 TP = sum(TP(:));
 accuracy3 = TP/ size(invar.cdata.GT,1)*100;                        % recall ???

end
