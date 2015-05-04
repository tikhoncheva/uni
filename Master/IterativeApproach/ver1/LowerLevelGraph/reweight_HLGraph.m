
% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching
% HLGmatches    result of higher level graaph matching
% matches       result of matching this two graphs
%
% new_affmatrix_HLG   updated affinity matrix for matching problem on the Higher Level

function [new_affmatrix_HLG] = reweight_HLGraph(LLG1, LLG2, LLGmatches_it, HLGmatches_it, it)

affmatrix = HLGmatches_it.affmatrix;
[nVA1, ~] = size(HLGmatches_it.corrmatrix);     % number of nodes (anchors)  in the first HLG
matched_pairs = HLGmatches_it.matched_pairs;       % matched pairs of anchor graphs

npairs = size(LLGmatches_it.subgraphsNodes,1);
assert(npairs==size(matched_pairs,1));

nV1 = size(LLG1.V,1);               % number of nodes in the first LLG
nV2 = size(LLG2.V,1);               % number of nodes in the second LLG

LLG_matches_weights = max(LLGmatches_it.lweights, [], 1);
LLG_matches_weights = reshape(LLG_matches_weights, nV1,nV2);


% update non-diagonal elements of the affmatrix

nEdges1 = size(LLG1.E,1);
nEdges2 = size(LLG2.E,1);

thres = 0.75;

for i = 1:nEdges1       % for all edges in the first LLGraph
    vk_I = LLG1.E(i,1);
    vl_I = LLG1.E(i,2);
    
    vk_II = LLGmatches_it.matched_pairs( LLGmatches_it.matched_pairs(:,1) == vk_I, 2);
    vl_II = LLGmatches_it.matched_pairs( LLGmatches_it.matched_pairs(:,1) == vl_I, 2);
    
    assert(numel(vk_II)<=1, 'Error in reweight_HLGraph: 1-to-many matching');
    assert(numel(vl_II)<=1, 'Error in reweight_HLGraph: 1-to-many matching');
    
    if (numel(vk_II)==0 || numel(vl_II)==0) % if one of the points wasn't matched - skip the iteration
        continue;
    end
    
    ind_vk_I_vl_I = nV1*(vl_I-1) + vk_I;
    ind_vk_II_vl_II = nV1*(vl_II-1) + vk_II;
    
%     w = affmatrix_LLG(ind_vk_I_vl_I, ind_vk_II_vl_II);
%     d1 = sqrt(sum( (LLG1.V(vk_I,:) - LLG1.V(vl_I,:)).^2));
% %     d2 = sqrt(sum( (LLG2.V(vk_II,:) - LLG2.V(vl_II,:)).^2));
%     
%     w = LLG_matches_weights(vk_I, vk_II) * LLG_matches_weights(vl_I, vl_II);
%     
%     if (w<thres) % if the edges (vk_I, vl_I) and (vk_II, vl_II) are dissimilar
%         
%         ak_I = find(LLG1.U(vk_I,:));  % anchors, the node vk_I belongs to 
%         al_I = find(LLG1.U(vl_I,:));  % anchors, the node vl_I belongs to 
%         
%         ak_II = find(LLG2.U(vk_II,:));  % anchors, the node vk_II belongs to 
%         al_II = find(LLG2.U(vl_II,:));  % anchors, the node vl_II belongs to 
%         
%         
%         % all possible combinations between anchors of the nodes ak_I and ak_II
%         [grid1,grid2] = meshgrid(ak_I,ak_II);
%         c = [grid1', grid2'];
%         ak_I_II = reshape(c,[],2);
%         % all possible combinations between anchors of the nodes al_I and al_II
%         [grid1,grid2] = meshgrid(al_I,al_II);
%         c = [grid1', grid2'];
%         al_I_II = reshape(c,[],2);       
%         
%         % update the weights of the affinity matrix on the Higher Level
%         for j=1:(size(ak_I_II,1) * size(al_I_II,1))
%             j1 = mod(j-1, size(ak_I_II,1) ) + 1;
%             j2 = mod(j-1, size(al_I_II,1) ) + 1;
%             
%             affmatrix( nVA1 * (ak_I_II(j1,2)-1) + ak_I_II(j1,1) , ...
%                        nVA1 * (al_I_II(j2,2)-1) + al_I_II(j2,1)) ... 
%             = w * affmatrix(nVA1 * (ak_I_II(j1,2)-1) + ak_I_II(j1,1), ...
%                             nVA1 * (al_I_II(j2,2)-1) + al_I_II(j2,1)) ;
%         end
%         
%     end
%     
%     
% end


% update diagonal elements of the affmatrix


assert( npairs == size(matched_pairs,1), 'number of matched subgraphs is differ from number of matched anchors');

for k=1:npairs
    IkJk = (matched_pairs(k,2)-1)*nVA1 + matched_pairs(k,1);    % index of pair (ai, aj) in the affinity matrix
    affmatrix(IkJk, IkJk) = affmatrix(IkJk, IkJk) * LLGmatches_it.lobjval(k) / LLGmatches_it.objval ;
end

new_affmatrix_HLG = affmatrix;
end