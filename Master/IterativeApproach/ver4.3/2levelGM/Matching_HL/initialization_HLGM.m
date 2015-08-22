 %% Initial correspondence and affinity matrices for higher level graph matching
 %
 %
 
function [corrmatrix, affmatrix, HLG1, HLG2] = initialization_HLGM(LLG1, LLG2, HLG1, HLG2, varargin)

fprintf('\n---- preprocessing: ');

% initial affinity matrix for matching Higher Level Graphs
% tic

nV1 = size(HLG1.V,1);
nV2 = size(HLG2.V,1);

% correspondence matrix 
if isempty(LLG1.D) || isempty(LLG2.D)
    corrmatrix = ones(nV1,nV2);  %  all-to-all correspondences
else
    corrmatrix = ones(nV1,nV2);                                                 %  !!!!!!!!!!!!!!!!!!!!!! now: all-to-all
    [I, J] = find(corrmatrix);
    cand_matches = [I, J];
    
%     cand_matches = find_cand_anchor_matches(LLG1, LLG2, HLG1, HLG2);
%                                                      
%     ind = sub2ind([nV1, nV2], cand_matches(:,1), cand_matches(:,2));
%     corrmatrix = zeros(nV1,nV2); corrmatrix(ind) = 1;
end

% compute initial affinity matrix
[affmatrix, HLG1, HLG2] = initialAffinityMatrix(LLG1, LLG2, HLG1, HLG2, corrmatrix);

% % % add dummy nodes into affinity matrix
% % dN1 = max(0, nV2-nV1) ; dN2 = max(0, nV1-nV2);
% % affmatrixD = zeros((nV1+dN1)*(nV2+dN2));
% % 
% % I = repmat([1:nV1+dN1]', nV2+dN2, 1);
% % J = kron([1:nV2+dN2]', ones(nV2+dN2, 1));
% % 
% % Io = repmat([1:nV1]', nV2, 1);
% % Jo = kron([1:nV2]', ones(nV1, 1));
% % 
% % [~,ind_same] = ismember([Io,Jo], [I,J], 'rows');
% % [x,y] = meshgrid(ind_same, ind_same);
% % ind = sub2ind(size(affmatrixD), x(:), y(:));
% % 
% % affmatrixD(ind) = affmatrix;
% % affmatrix = affmatrixD;
% % corrmatrix = ones(nV1+dN1, nV2+dN2); 

% display(sprintf('Summary %f sec', toc));
% display(sprintf('=================================================='));

end