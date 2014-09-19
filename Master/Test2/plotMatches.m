function h=plotMatches(Img1,Img2,x1,x2,AffM, imgName, suffix)

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
x2(:,1) = n1 + x2(:,1);

[i, j] = find(AffM);
matches = [i,j]';

nans = NaN * ones(size(matches,2),1) ;
x = [ x1(matches(1,:),1) , x2(matches(2,:),1) , nans ] ;
y = [ x1(matches(1,:),2) , x2(matches(2,:),2) , nans ] ;


f = figure ;
    axes('Position', [0 0 1 1]) ;
    imagesc(Img3) ; colormap gray ; hold on ; axis image ; axis off ;
    line(x', y', 'Color','g') ;
    
    plot(x1(:,1), x1(:,2),'b.');
    plot(x2(:,1), x2(:,2),'r.');
    print(f, '-r80', '-dtiff', fullfile(['.' filesep 'results' filesep],...
            sprintf('result_%s-%i.jpg', imgName, suffix)));
hold off;

end