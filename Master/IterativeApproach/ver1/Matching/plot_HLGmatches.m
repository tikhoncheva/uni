%% plot results of matching
% img1, img2    two images to match
% G1, G2        corresponding graphs to match (nV1=|V1|,nV2=|V2|)
% corrmatrix             correspondes matrix (nV1 x nV2)

function plot_HLGmatches(img1, G1, img2, G2, corrmatrix, varargin )

n1 = size(img1,2);    % width of the first image
G2.V(:,1) = n1 + G2.V(:,1);

%                      ------------------------------------
%                              plot two concatenated images
img3 = combine2images(img1,img2);
imagesc(img3) ; hold on ; axis off;

%                      ------------------------------------
%                              plot first graph (G1)

plot(G1.V(:,1), G1.V(:,2), 'yo','MarkerSize', 7, 'MarkerFaceColor','y');

edges = G1.E';
edges(end+1,:) = 1;
edges = edges(:);

points = G1.V(edges,:);
points(3:3:end,:) = NaN;

line(points(:,1), points(:,2), 'Color', 'y', 'LineWidth', 3);

% % for i=1:size(G1.E, 1)
% %     line([G1.V(G1.E(i,1),1) G1.V(G1.E(i,2),1) ],...
% %          [G1.V(G1.E(i,1),2) G1.V(G1.E(i,2),2) ], 'Color', 'y', 'LineWidth', 3);  
% % end

%                      ------------------------------------
%                              plot second graph (G2)
plot(G2.V(:,1), G2.V(:,2), 'yo','MarkerSize', 7, 'MarkerFaceColor','y');

edges = G2.E';
edges(end+1,:) = 1;
edges = edges(:);

points = G2.V(edges,:);
points(3:3:end,:) = NaN;

line(points(:,1), points(:,2), 'Color', 'y', 'LineWidth', 3);

% % for i=1:size(G2.E, 1)
% %     line([G2.V(G2.E(i,1),1) G2.V(G2.E(i,2),1) ],...
% %          [G2.V(G2.E(i,1),2) G2.V(G2.E(i,2),2) ], 'Color', 'y', 'LineWidth', 3);  
% % end

%                      ------------------------------------

[i, j] = find(corrmatrix);
matches = [i,j]';


%                      ------------------------------------
%                  highlight matches subgraph in the second graph;

for i=1:size(G2.E, 1)
    
    if (ismember(G2.E(i,1), matches(2,:)) && ismember(G2.E(i,2), matches(2,:))  )
        line([G2.V(G2.E(i,1),1) G2.V(G2.E(i,2),1) ],...
             [G2.V(G2.E(i,1),2) G2.V(G2.E(i,2),2) ], 'Color', 'w', 'LineWidth', 3);  
    end
end



%                      ------------------------------------
%                                  plot matches

nans = NaN * ones(size(matches,2),1) ;
x = [ G1.V(matches(1,:),1) , G2.V(matches(2,:),1) , nans ] ;
y = [ G1.V(matches(1,:),2) , G2.V(matches(2,:),2) , nans ] ; 
line(x', y', 'Color','g') ;


%                      ------------------------------------
%                        ADDITIONALLY:  highlight some matches

if (nargin == 6)
    M2 = varargin{1};
    % plot matches
    [i, j] = find(M2);
    matches2 = [i,j]';

    nans = NaN * ones(size(matches2,2),1) ;
    x = [ G1.V(matches2(1,:),1) , G2.V(matches2(2,:),1) , nans ] ;
    y = [ G1.V(matches2(1,:),2) , G2.V(matches2(2,:),2) , nans ] ; 
    line(x', y', 'Color','g','LineWidth', 4) ;
    
end

hold off;
end