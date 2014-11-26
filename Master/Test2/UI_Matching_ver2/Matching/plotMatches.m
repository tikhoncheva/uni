function plotMatches(img1, img2, x1, x2, AffM, varargin )

[m1,n1,k1]=size(img1) ;
[m2,n2,k2]=size(img2) ;

if (k1~=k2)
    error('Images must have the same format');
end;

    
% combine two images in one by putting them one next to the other
ihight = max(size(img1,1),size(img2,1));
if size(img1,1) < ihight
  img1(ihight,1,1) = 0;
end
if size(img2,1) < ihight
  img2(ihight,1,1) = 0;
end

img3 = cat(2,img1,img2);
imshow(img3)

x2(:,1) = n1 + x2(:,1);

[i, j] = find(AffM);
matches = [i,j]';

nans = NaN * ones(size(matches,2),1) ;
x = [ x1(matches(1,:),1) , x2(matches(2,:),1) , nans ] ;
y = [ x1(matches(1,:),2) , x2(matches(2,:),2) , nans ] ;


% f = figure ;

imagesc(img3) ; hold on ;

if nargin == 6 
    AffMInit = varargin{1};
    
    [i, j] = find(AffMInit);
    matchesInit = [i,j]';

    nans = NaN * ones(size(matchesInit,2),1) ;
    xInit = [ x1(matchesInit(1,:),1) , x2(matchesInit(2,:),1) , nans ] ;
    yInit = [ x1(matchesInit(1,:),2) , x2(matchesInit(2,:),2) , nans ] ;
    
    line(xInit', yInit', 'Color','b', 'LineStyle', '--') ;
    
end
    
    
    
line(x', y', 'Color','g') ;
plot(x1(:,1), x1(:,2),'b.');
plot(x2(:,1), x2(:,2),'r.');


end