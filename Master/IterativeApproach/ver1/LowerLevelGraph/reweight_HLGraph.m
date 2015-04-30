
% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching
% HLGmatches    result of higher level graaph matching
% matches       result of matching this two graphs
%
% new_affmatrix_HLG   updated affinity matrix for matching problem on the Higher Level

function [new_affmatrix_HLG] = reweight_HLGraph(LLG1, LLG2, LLGmatches_it, HLGmatches_it, it)

affmatrix = HLGmatches_it.affmatrix;

npairs = size(LLGmatches_it.subgraphsNodes,1);

[nV1, ~] = size(HLGmatches_it.corrmatrix);
% [L12(:,1), L12(:,2)] = find(HLGmatches.corrmatrix);

% consider first lower level graph LLG1

% % find vertices, that belong to more then one anchor:
% V_sel = []; % n x 2
% I = [];
% for v=1:size(LLG1.U,1)
%     
%     ind_anchors = find(LLG1.U(v,:)>0);
%     
%     if numel(ind_anchors)>1
%         V_sel = [V_sel; LLG1.V(v,:)];
%         I = [I, ind_anchors];
%     end
%     
% end

%% ???????????????????????????????????????????????


% update diagonal elements of the affmatrix
matched_pairs = HLGmatches_it.matched_pairs;       % matched pairs of anchor graphs

assert( npairs == size(matched_pairs,1), 'number of matched subgraphs is differ from number of matched anchors');

for k=1:npairs
    IkJk = (matched_pairs(k,2)-1)*nV1 + matched_pairs(k,1);    % index of pair (ai, aj) in the affinity matrix
    affmatrix(IkJk, IkJk) = affmatrix(IkJk, IkJk) * LLGmatches_it.lobjval(k) / LLGmatches_it.objval ;
end







new_affmatrix_HLG = affmatrix;
end