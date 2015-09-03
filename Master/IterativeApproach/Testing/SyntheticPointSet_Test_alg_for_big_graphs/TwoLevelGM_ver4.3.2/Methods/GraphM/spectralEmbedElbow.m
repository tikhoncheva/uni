function [XA, XB] = spectralEmbedElbow(A, B, numdim)

% embed A
[XA, svalA, ~] = svds(A, min([numdim+2, length(A)]) );
% find the "elbow" in the curve
d1 = diff(diag(svalA));
d2_A = diff(d1)';
[~, dim]  = max(d2_A);
% find second elbow
d2_A(dim) = 0;
[~, dim2] = max(d2_A(dim:end));
%% find third elbow
%d2_A(dim2) = 0;
%[~, dim3] = max(d2_A(dim+dim2-1:end));
dimA = dim+dim2;
%dimA = dim+1;

% embed B
[XB, svalB, ~] = svds(B, min([numdim+2, length(B)]) );
% find the "elbow" in the curve
d1 = diff(diag(svalB));
d2_B = diff(d1)';
[~, dim] = max(d2_B);
% find second elbow
d2_B(dim) = 0;
[~, dim2] = max(d2_B(dim:end));
%% find second elbow
%d2_B(dim2) = 0;
%[~, dim3] = max(d2_B(dim+dim2-1:end));
dimB = dim+dim2;
%dimB = dim+1;

% use max of 2 elbows
dim = max(dimA, dimB);


% Embed both
XA = XA(:,1:dim)*sqrt(svalA(1:dim,1:dim));
XB = XB(:,1:dim)*sqrt(svalB(1:dim,1:dim));

% project to sphere
XA = XA *diag(sum(XA.^2).^(-.5));
XB = XB *diag(sum(XB.^2).^(-.5));
