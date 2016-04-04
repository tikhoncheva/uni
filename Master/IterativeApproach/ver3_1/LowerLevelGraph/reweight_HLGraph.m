
% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching
% HLGmatches    result of higher level graaph matching
% matches       result of matching this two graphs
%
% new_affmatrix_HLG   updated affinity matrix for matching problem on the Higher Level

function [new_affmatrix_HLG] = reweight_HLGraph(LLG1, LLG2, LLGmatches_it, HLGmatches_it, gamma)

affmatrix = HLGmatches_it.affmatrix;
[nVA1, ~] = size(HLGmatches_it.corrmatrix);     % number of nodes (anchors)  in the first HLG
matched_pairs = HLGmatches_it.matched_pairs;       % matched pairs of anchor graphs

npairs = size(LLGmatches_it.subgraphsNodes,1);
assert( npairs == size(matched_pairs,1), 'number of matched subgraphs is differ from number of matched anchors');

nV1 = size(LLG1.V,1);               % number of nodes in the first LLG
nV2 = size(LLG2.V,1);               % number of nodes in the second LLG

LLG_matches_weights = max(LLGmatches_it.lweights, [], 1);
LLG_matches_weights = reshape(LLG_matches_weights, nV1,nV2);


% update non-diagonal elements of the affmatrix

nEdges1 = size(LLG1.E,1);
nEdges2 = size(LLG2.E,1);

thres = 0.75;

% for i = 1:nEdges1       % for all edges in the first LLGraph
%     vi = LLG1.E(i,1);   % edge {vi, vk} in the first graph
%     vk = LLG1.E(i,2);
%     
%     vj = LLGmatches_it.matched_pairs( LLGmatches_it.matched_pairs(:,1) == vi, 2); % corr. edge {vj, vl} in the second graph  
%     vl = LLGmatches_it.matched_pairs( LLGmatches_it.matched_pairs(:,1) == vk, 2);
%     
%     assert(numel(vj)<=1, 'Error in reweight_HLGraph: 1-to-many matching');
%     assert(numel(vl)<=1, 'Error in reweight_HLGraph: 1-to-many matching');
%     
%     if (numel(vj)==0 || numel(vl)==0) % if one of the points wasn't matched - skip the iteration
%         continue;
%     end
%     
%     ind_vi_vj = nV1*(vj-1) + vi;    % indeces of matches in local affinity matrix
%     ind_vk_vl = nV1*(vl-1) + vk;
%     
% %     w = affmatrix_LLG(ind_vi_vj, ind_vk_vl);                % weight
% %     d1 = sqrt(sum( (LLG1.V(vi,:) - LLG1.V(vk,:)).^2));    % length of the edge {vi,vk}
% %     d2 = sqrt(sum( (LLG2.V(vj,:) - LLG2.V(vl,:)).^2));  % length of the edge {vj,vl}
%     
%     w = LLG_matches_weights(vi, vj) * LLG_matches_weights(vk, vl); % weight
%     
%     if (w<thres)    % if the edges (vi, vk) and (vj, vl) are too dissimilar
%         
%         ai = find(LLG1.U(vi,:));  % anchors, the node vi belongs to 
%         ak = find(LLG1.U(vk,:));  % anchors, the node vk belongs to 
%         
%         aj = find(LLG2.U(vj,:));  % anchors, the node vj belongs to 
%         al = find(LLG2.U(vl,:));  % anchors, the node vl belongs to 
%         
%         
%         % all possible combinations between anchors of the nodes ai and aj
%         [grid1,grid2] = meshgrid(ai,aj);
%         c = [grid1', grid2'];
%         ai_aj_pairs = reshape(c,[],2);
%         % all possible combinations between anchors of the nodes ak and al
%         [grid1,grid2] = meshgrid(ak,al);
%         c = [grid1', grid2'];
%         ak_al_pairs = reshape(c,[],2);       
%         
%         % update the weights of the affinity matrix on the Higher Level
%         for j=1:(size(ai_aj_pairs,1) * size(ak_al_pairs,1))
%             j1 = mod(j-1, size(ai_aj_pairs,1) ) + 1;
%             j2 = mod(j-1, size(ak_al_pairs,1) ) + 1;
%             
%             affmatrix( nVA1 * (ai_aj_pairs(j1,2)-1) + ai_aj_pairs(j1,1) , ...
%                        nVA1 * (ak_al_pairs(j2,2)-1) + ak_al_pairs(j2,1)) ... 
%             = w * affmatrix(nVA1 * (ai_aj_pairs(j1,2)-1) + ai_aj_pairs(j1,1), ...
%                             nVA1 * (ak_al_pairs(j2,2)-1) + ak_al_pairs(j2,1)) ;
%         end
%         
%     end
%     
%     
% end


% update diagonal elements of the affmatrix

for k=1:npairs
    IkJk = (matched_pairs(k,2)-1)*nVA1 + matched_pairs(k,1);    % index of pair (ai, aj) in the affinity matrix
    affmatrix(IkJk, IkJk) = gamma*affmatrix(IkJk, IkJk) + (1-gamma) * LLGmatches_it.lobjval(k) / LLGmatches_it.objval ;
end

new_affmatrix_HLG = affmatrix;
end