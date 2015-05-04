function [ laffmatrices_LLG ] = reweight_LLGraph(LLG1, LLG2, laffmatrices_LLG, HLGmatches_it)

affmatrix_HLG = HLGmatches_it.affmatrix;
[nVA1, ~] = size(HLGmatches_it.corrmatrix);            % number of nodes (anchors)  in the first HLG
matched_pairs_HLG = HLGmatches_it.matched_pairs;       % matched pairs of anchor graphs

npairs = size(matched_pairs_HLG, 1);


% % adjacency matrix of the first dependency graph
% adjM1 = zeros(nV1, nV1);
% E1 = LLG1.E;
% E1 = [E1; [E1(:,2) E1(:,1)]];
% ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
% adjM1(ind) = 1;
% 
% % adjacency matrix of the second dependency graph
% adjM2 = zeros(nV2, nV2);
% E2 = LLG2.E;
% E2 = [E2; [E2(:,2) E2(:,1)]];
% ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
% adjM2(ind) = 1;  



for k = 1:npairs % for each match ai<->aj on the High Level
    
    ai = matched_pairs_HLG(k,1);
    aj = matched_pairs_HLG(k,2);
    
    laffmatrix = laffmatrices_LLG{k};       % local affinity matrix between the subgraphs
    
    % reweight diagonal elements
    ind_ai_aj = nVA1 * (aj-1) + ai;
    laffmatrix(1:(length(laffmatrix)+1):end) = affmatrix_HLG(ind_ai_aj, ind_ai_aj)...
                                             * laffmatrix(1:(length(laffmatrix)+1):end);
                                         
    % reweight non-diagonal elements
    ind_adj_edges = find( affmatrix_HLG(ind_ai_aj,:) );
    
    for i=1:numel(ind_adj_edges)    % ai<->aj, ak<->al
        
        ind_ak_al = ind_adj_edges(i);
        al = floor(ind_ak_al/nVA1) + 1;
        ak = ind_ak_al - (al-1)*nVA1;
        
        if (~ismember([ak, al], matched_pairs_HLG, 'rows') || (ak==ai && al == aj))
           continue 
        end
        
        vi = find(LLG1.U(:,ai)>0);        % nodes that belongs to the anchor ai
        nV1 = numel(vi);
        vi_ak = find(LLG1.U(vi, ak));     % nodes that also belongs to the anchor ak
        
        
        vj = find(LLG1.U(:,aj)>0);        % nodes that belongs to the anchor aj
        nV2 = numel(vj);
        vj_al = find(LLG1.U(vj, al));     % nodes that also belongs to the anchor al
        
        
        [grid1,grid2] = meshgrid([1:nV1], [1:nV2]);
        c = [grid1', grid2'];
        vi_vj = reshape(c,[],2);
        
        [grid1,grid2] = meshgrid(vi_ak, vj_al);
        c = [grid1', grid2'];
        vk_vl = reshape(c,[],2);
        
        
        for p=1: (size(vi_vj,1) * size(vk_vl,1) )
            
            p1 = mod(p-1, size(vi_vj,1) ) + 1;
            p2 = mod(p-1, size(vk_vl,1) ) + 1;
            
            ind_vi_vj = nV1 * (vi_vj(p1,2)-1) + vi_vj(p1,1);
            ind_vl_vk = nV1 * (vk_vl(p2,2)-1) + vk_vl(p2,1);
            
            laffmatrix(ind_vi_vj, ind_vl_vk) = affmatrix_HLG(ind_ai_aj, ind_ak_al)...
                                             * laffmatrix(ind_vi_vj, ind_vl_vk);
        end             
        
        
    end
    
    
    % save results
    laffmatrices_LLG{k} = laffmatrix;
    
end % for k



end

