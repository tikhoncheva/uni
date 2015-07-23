function [affmatrices] = add_affine_transformation_similarity (nV1, nV2, subgraphs_nodes, affmatrices, ...
                                                               HL_matched_pairs, ...
                                                               HL_matched_pairs_prev, ...
                                                               aftr_sim)
    [is_same] = find( ismember(HL_matched_pairs, HL_matched_pairs_prev, 'rows') );
    
    for k=1:size(is_same, 1)

        sV1 = find(subgraphs_nodes(k, 1:nV1) );
        sV2 = find(subgraphs_nodes(k, nV1+1:end) );

        pairs = [repmat(sV1,1, numel(sV2)); kron(sV2, ones(1,numel(sV1)))];
        pairs = pairs';
        ind = (pairs(:,2)-1)*nV1 + pairs(:,1);

        % reweight diagonal elements of laffmatrix
        laffmatrix = affmatrices{k};
        laffmatrix(1:(size(laffmatrix,1)+1):end) = laffmatrix(1:(size(laffmatrix,1)+1):end) ...
                                                 + aftr_sim(ind);
        affmatrices{k} = laffmatrix;                                    
    end    
        
end