 %% Initialization function for setting the iterative graph matching
 %
 %
 
function [corrmatrix, affmatrix] = initialization_LLGM(LLG1, LLG2, varargin)

display(sprintf('\n================================================'));
display(sprintf('Initialization for Lower Level Graph Matching (LLGM)'));
display(sprintf('=================================================='));



try
    tic 
    
    nV1 = size(LLG1.V,1);
    nV2 = size(LLG2.V,1);

    % adjacency matrix of the first dependency graph
    adjM1 = zeros(nV1, nV1);
    E1 = LLG1.E;
    E1 = [E1; [E1(:,2) E1(:,1)]];
    ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
    adjM1(ind) = 1;

    % adjacency matrix of the second dependency graph
    adjM2 = zeros(nV2, nV2);
    E2 = LLG2.E;
    E2 = [E2; [E2(:,2) E2(:,1)]];
    ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
    adjM2(ind) = 1;  
 
    
    % correspondence matrix 
    display(sprintf('all-to-all correspondences\n'));
    corrmatrix = ones(nV1,nV2);                                   % !!!!!!!!!!!!!!!!!!!!!! now: all-to-all
    % affinity matrix
    affmatrix = initialAffinityMatrix2(LLG1.V', LLG2.V', LLG1.D, LLG2.D, adjM1, adjM2, corrmatrix);

catch ME
    msg = 'Error occurred in Lower Level Graph Matching in parallel pool';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);

    rethrow(ME);
end


display(sprintf('Summary %f sec', toc));
display(sprintf('=================================================='));


end