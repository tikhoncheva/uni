%% plot results of matching
% img1, img2    two images to match
% G1, G2        corresponding graphs to match (nV1=|V1|,nV2=|V2|)
% pairs         pairs of points

function plot_matches(img1, G1, img2, G2, pairs, GT, varargin )

if (~isempty(img1) && ~isempty(img2))
    n1 = size(img1,2);                      % width of the first image
    img3 = combine2images(img1,img2);       % plot two concatenated images
    imshow(img3) ; hold on ; axis off;
else
    n1 = max(G1.V(:,1)) + abs(min(G1.V(:,1)));
end

G2.V(:,1) = n1 + G2.V(:,1);


%                      ------------------------------------
%                              plot first graph (G1)

plot(G1.V(:,1), G1.V(:,2), 'yo', 'MarkerFaceColor','y');

edges = G1.E';
edges(end+1,:) = 1;
edges = edges(:);

points = G1.V(edges,:);
points(3:3:end,:) = NaN;

line(points(:,1), points(:,2), 'Color', 'y', 'LineWidth', 2);

%                      ------------------------------------
%                              plot second graph (G2)
plot(G2.V(:,1), G2.V(:,2), 'yo', 'MarkerFaceColor','y');

edges = G2.E';
edges(end+1,:) = 1;
edges = edges(:);

points = G2.V(edges,:);
points(3:3:end,:) = NaN;

line(points(:,1), points(:,2), 'Color', 'y', 'LineWidth', 2);

%                      ------------------------------------
%                                  plot matches
if (~isempty(pairs))
    
    matches = pairs';
    
    nans = NaN * ones(size(matches,2),1) ;
    x = [ G1.V(matches(1,:),1) , G2.V(matches(2,:),1) , nans ] ;
    y = [ G1.V(matches(1,:),2) , G2.V(matches(2,:),2) , nans ] ; 
    line(x', y', 'Color','b','LineWidth', 2) ;
end

%                      ------------------------------------
%                     plot wrong matches

if (~isempty(GT))
    TP = ismember(pairs(:,1:2), GT, 'rows');    % true positive matches
    
    pairs_wrong = pairs(~TP, 1:2);
    
    matches_wrong = pairs_wrong';
    nans = NaN * ones(size(matches_wrong,2),1) ;
    x = [ G1.V(matches_wrong (1,:),1) , G2.V(matches_wrong (2,:),1) , nans ] ;
    y = [ G1.V(matches_wrong (1,:),2) , G2.V(matches_wrong (2,:),2) , nans ] ; 
    line(x', y', 'Color','r','LineWidth', 2) ;
end


%                      ------------------------------------
%                        ADDITIONALLY:  highlight some matches

if (nargin == 7)
    pairs2 = varargin{1};
    matches2 = pairs2';

    if (~isempty(matches2) )
        nans = NaN * ones(size(matches2,2),1) ;
        x = [ G1.V(matches2(1,:),1) , G2.V(matches2(2,:),1) , nans ] ;
        y = [ G1.V(matches2(1,:),2) , G2.V(matches2(2,:),2) , nans ] ; 
        line(x', y', 'Color','b') ;

        if (~isempty(matches_wrong))
            [~,right_matches] = ismember(matches2(1,:), matches_wrong(1,:));
            x = [ G1.V(matches2(1,:),1) , G2.V(matches_wrong(2, right_matches),1) , nans ] ;
            y = [ G1.V(matches2(1,:),2) , G2.V(matches_wrong(2, right_matches),2) , nans ] ; 
            line(x', y', 'Color','b', 'LineStyle', '--');
        end
    end
    
end

hold off;
end