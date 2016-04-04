function plotFeatures(Img1, Img2, x1, x2)

[m1,n1,k1]=size(Img1) ;
[m2,n2,k2]=size(Img2) ;

if (k1~=k2)
    error('Images must have the same format');
end;

    
% combine two images in one by putting them one next to the other
m3 = max(m1, m2);
n3 = n1+n2;
Img3 = zeros(m3, n3, k1);

Img3(1:m1, 1:n1,:) = Img1;
Img3(1:m2, n1+(1:n2),:) = Img2 ;

% f = figure ;
imshow(Img3) ; hold on ;

end