function [XA, XB] = spectralEmbed(A, B, numdim)

[XA, sval, ~] = svds(A,numdim);
XA = XA*sqrt(sval);
[XB, sval, ~] = svds(B,numdim);
XB = XB*sqrt(sval);
