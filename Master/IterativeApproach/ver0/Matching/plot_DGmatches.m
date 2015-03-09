%% plot results of matching
% img1, img2    two images to match
% G1, G2        corresponding graphs to match (nV1=|V1|,nV2=|V2|)
% M             correspondes matrix (nV1 x nV2)

function plot_DGmatches(img1, G1, img2, G2, M, varargin )

n1 = size(img1,2);    % width of the first image

img3 = combine2images(img1,img2);

G2.V(:,1) = n1 + G2.V(:,1);

% plot image
imagesc(img3) ; hold on ; axis off;

% plot graphs
%G1
plot(G1.V(:,1), G1.V(:,2), 'b*');
for i=1:size(G1.E, 1)
    line([G1.V(G1.E(i,1),1) G1.V(G1.E(i,2),1) ],...
         [G1.V(G1.E(i,1),2) G1.V(G1.E(i,2),2) ], 'Color', 'g');  
end
%G2
plot(G2.V(:,1), G2.V(:,2), 'b*');
for i=1:size(G2.E, 1)
    line([G2.V(G2.E(i,1),1) G2.V(G2.E(i,2),1) ],...
         [G2.V(G2.E(i,1),2) G2.V(G2.E(i,2),2) ], 'Color', 'g');  
end

% plot matches
[i, j] = find(M);
matches = [i,j]';

nans = NaN * ones(size(matches,2),1) ;
x = [ G1.V(matches(1,:),1) , G2.V(matches(2,:),1) , nans ] ;
y = [ G1.V(matches(1,:),2) , G2.V(matches(2,:),2) , nans ] ; 
line(x', y', 'Color','r') ;

% highlight some matchess
if (nargin == 6)
    M2 = varargin{1};
    % plot matches
    [i, j] = find(M2);
    matches2 = [i,j]';

    nans = NaN * ones(size(matches2,2),1) ;
    x = [ G1.V(matches2(1,:),1) , G2.V(matches2(2,:),1) , nans ] ;
    y = [ G1.V(matches2(1,:),2) , G2.V(matches2(2,:),2) , nans ] ; 
    line(x', y', 'Color','g','LineWidth', 2) ;
    
end

hold off;
end