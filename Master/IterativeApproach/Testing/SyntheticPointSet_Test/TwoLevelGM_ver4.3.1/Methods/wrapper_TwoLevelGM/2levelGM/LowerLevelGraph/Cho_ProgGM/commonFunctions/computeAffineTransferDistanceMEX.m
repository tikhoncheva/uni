function [ distance flip ] = computeAffineTransferDistanceMEX( viewInfo, matchlist , bReflective  )
%%   Compute the mutual affine transfer errors between two views
%   Output
%           distance: matrix of error distances
%           flip    : binary matrix notifying flips for matching 
%                     (non-zero only if single view matching)

% Minsu Cho Nov 25, 2010 
% Final revision: April 3, 2011
if nargin < 3,  bReflective = 0;    end

if length(viewInfo) == 1
    bSingle = 1;  view1 = 1;  view2 = 1;
else
    bSingle = 0;  view1 = 1;  view2 = 2;
end

%% Image Pair, No reflective case
[distance flip] = affineTransferDistanceMEX(int32(matchlist), viewInfo(view1).affMatrix, viewInfo(view2).affMatrix, bSingle, bReflective);
flip = logical(flip);