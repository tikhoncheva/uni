%% plot results of matching
% img1, img2    two images to match
% G1, G2        corresponding graphs to match (nV1=|V1|,nV2=|V2|)
% pairs         pairs of points

function plot_LLGmatches(img1, G1, HLG1, img2, G2, HLG2, LL_matches, HL_matches, GT, varargin )

if (~isempty(img1) && ~isempty(img2))
    n1 = size(img1,2);                      % width of the first image
    img3 = combine2images(img1,img2);       % plot two concatenated images
    imagesc(img3) ; hold on ; axis off;
else
    n1 = max(G1.V(:,1)) + abs(min(G1.V(:,1)));
end

G2.V(:,1) = n1 + G2.V(:,1);	% shift x-coordinates of the second graphs



%                      ------------------------------------
%                              plot first graph (G1)

cmap = hsv(size(HLG1.V,1));
cmap = [cmap; [0.0 0.0 0.0]];
    
% % % edges = G1.E'; edges(end+1,:) = 1; edges = edges(:);
% % % points = G1.V(edges,:); points(3:3:end,:) = NaN;
% % % line(points(:,1), points(:,2), 'Color', 'g');

% plot nodes
% plot(G1.V(:,1), G1.V(:,2), 'b*');   

% vertices (color nodes in each subgraph in different color)
col_mapping = size(cmap,1)*ones(1,size(HLG1.V,1))    ;
col_mapping(HL_matches(:,1)) = HL_matches(:,1);
for i=1:numel(col_mapping)
    Vi_ind = HLG1.U(:,i);
    plot(G1.V(Vi_ind,1), G1.V(Vi_ind,2), 'ko', 'MarkerFaceColor', cmap(col_mapping(i),:));       
end
    


%                      ------------------------------------
%                              plot second graph (G2)
% % % plot edges
% % edges = G2.E'; edges(end+1,:) = 1; edges = edges(:);
% % points = G2.V(edges,:); points(3:3:end,:) = NaN;
% % line(points(:,1), points(:,2), 'Color', 'g');

% plot nodes
% plot(G2.V(:,1), G2.V(:,2), 'b*');   
col_mapping = size(cmap,1)*ones(1,size(HLG2.V,1))    ;
col_mapping(HL_matches(:,2)) = HL_matches(:,1);
for i=1:numel(col_mapping)
    Vi_ind = HLG2.U(:,i);
    plot(G2.V(Vi_ind,1), G2.V(Vi_ind,2), 'ko', 'MarkerFaceColor', cmap(col_mapping(i),:));       
end
    

%                      ------------------------------------
%                                  plot matches
col_mapping = size(cmap,1)*ones(1,size(HLG1.V,1)) ;
col_mapping(HL_matches(:,1)) = HL_matches(:,1);

if(~isempty(LL_matches))
    for i=1:size(HL_matches,1)
        ind = LL_matches(:,3) == i;
        
        nans = NaN * ones(size(LL_matches(ind,:),1),1) ;
        x = [ G1.V(LL_matches(ind,1),1) , G2.V(LL_matches(ind,2),1) , nans ] ;
        y = [ G1.V(LL_matches(ind,1),2) , G2.V(LL_matches(ind,2),2) , nans ] ; 
        line(x', y', 'Color', cmap(col_mapping(HL_matches(i,1)),:), 'LineWidth', 2) ;
    end
end

%                      ------------------------------------
%                                ground truth

if(~isempty(GT))
    nans = NaN * ones(size(GT,1),1) ;
    x = [ G1.V(GT(:,1),1) , G2.V(GT(:,2),1) , nans ] ;
    y = [ G1.V(GT(:,1),2) , G2.V(GT(:,2),2) , nans ] ; 
    line(x', y', 'Color','b', 'LineStyle', '--') ;
end


%                      ------------------------------------
%                        ADDITIONALLY:  highlight some matches
if (nargin == 10)
    matches_hl = varargin{1};
    if (~isempty(matches_hl))
        
        nans = NaN * ones(size(matches_hl,1),1) ;
        x = [ G1.V(matches_hl(:,1),1) , G2.V(matches_hl(:,2),1) , nans ] ;
        y = [ G1.V(matches_hl(:,1),2) , G2.V(matches_hl(:,2),2) , nans ] ; 
        line(x', y', 'Color','w','LineWidth', 2) ;
        
        if (~isempty(GT) )
            [~,right_matches] = ismember(matches_hl(:,1), GT(:,1));
            x = [ G1.V(matches_hl(:,1),1) , G2.V(GT(right_matches,2),1) , nans ] ;
            y = [ G1.V(matches_hl(:,1),2) , G2.V(GT(right_matches,2),2) , nans ] ; 
            line(x', y', 'Color','w', 'LineWidth', 2, 'LineStyle', '--') ;        
        end
    end
    
end

hold off;
end