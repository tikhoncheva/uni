function [XA, XB] = spectralEmbedElbowProj(A, B, numdim)

% spectral project the points
[XA, XB] = spectralEmbedElbow(A, B, numdim);

% project to sphere
XA = XA *diag(sum(XA.^2).^(-.5));
XB = XB *diag(sum(XB.^2).^(-.5));
