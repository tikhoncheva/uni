%% define correspondences between graphs on higher and lower level
% A node v of Lower Level Graph correpondes to an anchor a from Higher
% Level Graph, if v is inside defined region around a
%
% Input
%   LLG     lower level graph, LLG = (V,D,E,U)
%   HLG     higher level graph, HLG = (V,D,E)
%   SPrect rectangles, that an affinity area around each node of HLG
%
% Output
%   U       correspondence matrix

function [U] = connect2levels(LLG, HLG, SPrect)

    n = size(LLG.V, 1);  % number of nodes in the lower level graph LLG
    m = size(HLG.V, 1);  % number of nodes in the higher level graph HLG
    assert(m==size(SPrect,1));
    
    U = zeros(n, m);
    
    for j=1:m

        % rectangle around superpixel i in the higher level segmentation
        xmin = SPrect(j,1);
        ymin = SPrect(j,2);
        width = SPrect(j,3);
        height = SPrect(j,4);

        % select edge points inside selected region
        ind1 = LLG.V(:, 1) >= xmin;
        ind2 = LLG.V(:, 1) <= xmin + width;
        ind3 = LLG.V(:, 2) >= ymin;
        ind4 = LLG.V(:, 2) <= ymin + height;

        ind = logical(ind1.*ind2.*ind3.*ind4);
        
        % connect selected nodes with anchor a_i
        U(ind, j) = 1;
    end
    
    % 02.06. if one node belongs to  more than one anchor, select the
    % closest anchor
    
    diffx = repmat(LLG.V(:,1), 1, m) - repmat(HLG.V(:,1)', n, 1);
    diffy = repmat(LLG.V(:,2), 1, m) - repmat(HLG.V(:,2)', n, 1);
    dist = sqrt(diffx.^2 + diffy.^2);

    U1 = U.*dist;
    U1(U1==0) = NaN;
    
    [~, minpos] = min(U1,[], 2);
    
    U = false(n,m);
    
    ind = sub2ind([n,m], [1:n]', minpos);
    
    U(ind) = true;

    U = logical(U);
end
