%% plot results of matching
% img1, img2    two images to match
% G1, G2        corresponding graphs to match (nV1=|V1|,nV2=|V2|)
% pairs         pairs of points

function plot_LLGmatches(img1, G1, img2, G2, anchor_pairs, pairs, pairs_old, varargin )

n1 = size(img1,2);    % width of the first image
G2.V(:,1) = n1 + G2.V(:,1);     % shift x-coordinates of the second graph

%                      ------------------------------------
%                              plot two concatenated images

img3 = combine2images(img1,img2);
imagesc(img3) ; hold on ; axis off;

%                      ------------------------------------
%                              plot first graph (G1)
% plot nodes
plot(G1.V(:,1), G1.V(:,2), 'b*');   

edges = G1.E';
edges(end+1,:) = 1;
edges = edges(:);

points = G1.V(edges,:);
points(3:3:end,:) = NaN;

line(points(:,1), points(:,2), 'Color', 'g');

%                      ------------------------------------
%                              plot second graph (G2)
% plot nodes
plot(G2.V(:,1), G2.V(:,2), 'b*');   
% plot edges
edges = G2.E';
edges(end+1,:) = 1;
edges = edges(:);

points = G2.V(edges,:);
points(3:3:end,:) = NaN;

line(points(:,1), points(:,2), 'Color', 'g');

%                      ------------------------------------
%                        plot subgraphs of selected anchor points
for i=1:size(anchor_pairs)
   
   ai = anchor_pairs(i,1);      % ai<->aj
   aj = anchor_pairs(i,2);
   
   v_ai = find(G1.U(:, ai));          % nodes, that belong to the anchor ai
   v_aj = find(G2.U(:, aj));          % nodes, that belong to the anchor aj
   
   % subgraph 1
   plot(G1.V(v_ai,1), G1.V(v_ai,2), 'ko', 'MarkerSize', 4); 

   edges_ind1 = ismember(G1.E(:,1), v_ai);
   edges_ind2 = ismember(G1.E(:,2), v_ai);
   
   edges_ind = logical( edges_ind1.* edges_ind2);
   
   edges = G1.E(edges_ind,:)';
   edges(end+1,:) = 1;
   edges = edges(:);
   points = G1.V(edges,:);
   points(3:3:end,:) = NaN;

   line(points(:,1), points(:,2), 'Color', 'k');
   
   % subgraph 2
   
   plot(G2.V(v_aj,1), G2.V(v_aj,2), 'ko', 'MarkerSize', 4); 
   
   edges_ind1 = ismember(G2.E(:,1), v_aj);
   edges_ind2 = ismember(G2.E(:,2), v_aj);
   
   edges_ind = logical( edges_ind1.* edges_ind2);
   
   edges = G2.E(edges_ind,:)';
   edges(end+1,:) = 1;
   edges = edges(:);
   points = G2.V(edges,:);
   points(3:3:end,:) = NaN;

   line(points(:,1), points(:,2), 'Color', 'k');
    
end


%                      ------------------------------------
%                                  plot matches

matches = pairs';

if(~isempty(matches))
    nans = NaN * ones(size(matches,2),1) ;
    x = [ G1.V(matches(1,:),1) , G2.V(matches(2,:),1) , nans ] ;
    y = [ G1.V(matches(1,:),2) , G2.V(matches(2,:),2) , nans ] ; 
    line(x', y', 'Color','b') ;
end

%                      ------------------------------------
%                      plot matches of previuos iterations

matches_old = pairs_old';

if(~isempty(matches_old))
    nans = NaN * ones(size(matches_old,2),1) ;
    x = [ G1.V(matches_old(1,:),1) , G2.V(matches_old(2,:),1) , nans ] ;
    y = [ G1.V(matches_old(1,:),2) , G2.V(matches_old(2,:),2) , nans ] ; 
    line(x', y', 'Color','b', 'LineStyle', '--') ;
end


%                      ------------------------------------
%                        ADDITIONALLY:  highlight some matches
if (nargin == 8)
    pairs2 = varargin{1};
    % plot matches
    matches2 = pairs2';

    if(~isempty(matches2))
        nans = NaN * ones(size(matches2,2),1) ;
        x = [ G1.V(matches2(1,:),1) , G2.V(matches2(2,:),1) , nans ] ;
        y = [ G1.V(matches2(1,:),2) , G2.V(matches2(2,:),2) , nans ] ; 
        line(x', y', 'Color','b','LineWidth', 2) ;
        
        [~,right_matches] = ismember(matches2(1,:), matches_old(1,:));
        x = [ G1.V(matches2(1,:),1) , G2.V(matches_old(2, right_matches),1) , nans ] ;
        y = [ G1.V(matches2(1,:),2) , G2.V(matches_old(2, right_matches),2) , nans ] ; 
        line(x', y', 'Color','b', 'LineWidth', 2, 'LineStyle', '--') ;        
    end
    
end

hold off;
end