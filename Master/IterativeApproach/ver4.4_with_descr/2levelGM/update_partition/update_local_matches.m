%% update local matches using voting algorithm from ProgGM (Minsu Cho, 2012)
% code is a modified part of wrapper_ProgGM.m, Minsu Cho, 2012

function [matchList_GM_new] = update_local_matches(LLG1, LLG2, matchScore_GM, matchList_GM)
    nV1 = size(LLG1.V,1);
    nV2 = size(LLG2.V,1);
    
    nM = size(matchList_GM,1);
    
    k_neighbor1 = 25;
    k_neighbor2 = 5;
    
%     matchScore_GM = Xraw(matchIdx_GM);
    matchScore_GM = matchScore_GM./sum(matchScore_GM);
    
    %% Growing candidate matches!
    kdtreeNS1 = kdtree_build(LLG1.V(:,1:2));%KDTreeSearcher(all_feat1(:,1:2));
    kdtreeNS2 = kdtree_build(LLG2.V(:,1:2));%KDTreeSearcher(all_feat2(:,1:2));
    
  
% sparse voting matrix, to be modified for multiple types of features
    voting_space = sparse(nV1, nV2);
    nVote = 0;
    for iter_i = 1:nM % for each match
        

        scoreAnchor = matchScore_GM(iter_i);
        matchAnchor = matchList_GM(iter_i,:);
        
        % Ti1: transform from normalized domain to region R1 of match i
        Ti1 = reshape(LLG1.affMatrix(matchAnchor(1),:),[3 3])';
        Ti2 = reshape(LLG2.affMatrix(matchAnchor(2),:),[3 3])';

%         inv_Ti1 = inv(Ti1);    inv_Ti2 = inv(Ti2);
        % Ti21: transform from R1 to R2,   Ti12: transform from R2 to R1
%             Ti21 = Ti2*[ 1 0 0; 0 -1 0; 0 0 1 ]*inv_Ti1;
%             Ti12 = Ti1*[ 1 0 0; 0 -1 0; 0 0 1 ]*inv_Ti2;
        Ti21 = Ti2*[ 1 0 0; 0 -1 0; 0 0 1 ]/Ti1;
        Ti12 = Ti1*[ 1 0 0; 0 -1 0; 0 0 1 ]/Ti2;

        % forward voting
        ptAnchor1 = LLG1.V(matchAnchor(1),1:2);
        [ voting, nAddedVote ]= voteCandidate( kdtreeNS1, kdtreeNS2, LLG1.V(:,1:2), LLG2.V(:,1:2), ...
            matchList_GM, scoreAnchor, ptAnchor1, Ti21, k_neighbor1, k_neighbor2);
        
        voting_space = voting_space + voting;
        nVote = nVote + nAddedVote;
        
        % backward voting
        ptAnchor2 = LLG2.V(matchAnchor(2),1:2);
        [ voting, nAddedVote ]= voteCandidate( kdtreeNS2, kdtreeNS1, LLG2.V(:,1:2), LLG1.V(:,1:2),...
            matchList_GM(:,[2 1]), scoreAnchor, ptAnchor2, Ti12, k_neighbor1, k_neighbor2);
        voting_space = voting_space + voting';
        nVote = nVote + nAddedVote;
    end
    kdtree_delete(kdtreeNS1);
    kdtree_delete(kdtreeNS2);
    
    X = greedyMapping(voting_space(:), group1, group2);
    [matchList_GM_new(:,1), matchList_GM_new(:,2)] = find(reshape(X, nV1, nV2)); 
    
%     [~, maxpos] = max(voting_space, [], 2);
%     matchList_GM_new = [(1:nV1)', maxpos];
    
%     % make sure that the current GM matches are included
%     for iter_i = 1:length(matchIdx_GM) % for each match        
%         matchAnchor = matchList_GM(iter_i,:);
%         voting_space(matchAnchor(1),matchAnchor(2)) = Inf;
%     end
    
    % collect new candidate matches from the voting space
%     matchlist_new = selectCandidateMatch( voting_space, ...
%                     cdata.view(1).feat, cdata.view(1).desc,...
%                     cdata.view(2).feat, cdata.view(2).desc,...
%                     max_candidates, threshold_dissim, cdata.mparam );

end