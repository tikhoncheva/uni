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
corrmatrix = ones(nV1,nV2);                                                 %  !!!!!!!!!!!!!!!!!!!!!! now: all-to-all

% compute initial affinity matrix
[affmatrix, HLG1, HLG2] = initialAffinityMatrix(LLG1, LLG2, HLG1, HLG2, corrmatrix);


% % add affine transformation similarity of the anchors
% if (nargin == 3)
%     affmatrix(1:(length(affmatrix)+1):end) = affmatrix(1:(length(affmatrix)+1):end) + varargin{1};
% end
    

% display(sprintf('Summary %f sec', toc));
% display(sprintf('=================================================='));


end