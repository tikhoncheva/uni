
% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching
% HLGmatches    result of higher level graaph matching
% matches       result of matching this two graphs
%
% new_affmatrix_HLG   updated affinity matrix for matching problem on the Higher Level

function [new_affmatrix_HLG] = reweight_HLGraph(LLG1, LLG2, LLGmatches, HLGmatches, it)

affmatrix = HLGmatches.affmatrix;


[L12(:,1), L12(:,2)] = find(HLGmatches.corrmatrix);

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
% % update diagonal elements of the affmatrix
% for i=1:size(affmatrix,1)
%    affmatrix(i, i) =  affmatrix(i, i) * LLGmatches.loptsol(i,1)/ LLGmatches.objval(1,it+1);
% end






new_affmatrix_HLG = affmatrix;
end