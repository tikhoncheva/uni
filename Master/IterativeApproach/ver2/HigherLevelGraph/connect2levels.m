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

    n = size(LLG.V , 1);  % number of nodes in the lower level graph LLG
    m = size(SPrect, 1);  % number of nodes in the higher level graph HLG

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

    U = logical(U);
end
