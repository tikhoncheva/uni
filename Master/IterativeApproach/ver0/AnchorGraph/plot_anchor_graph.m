% function for plotting of the anchor graph 
% Input:
% img       given image
% DG =      dependency graph
%  {    V,  coordinates of the vertices (n x 2)
%       E,  edges
%       D  descriptors of the vertices
%  }
%
% AG =      anchor graph 
%  { coord,    coordinates of the anchors (m x 2)
%        U,    matrix of the nearest anchors for each point v_i \in V
%  }
%
% show_AG   show edges of the AG
% show_DG   show edges of the DG

function plot_anchor_graph(img, DG, AG, show_DG, show_AG)

    if (ndims(img)>1)
        imagesc(img) ;
    end
    
    hold on ;
    axis off;
    
    n = size(DG.V, 1);
    m = size(AG.coord,1);
    
    % edges between vertives and anchors
    [i, j] = find(AG.U);
    matchesInd = [i,j]';

    nans = NaN * ones(size(matchesInd,2),1) ;
    xInit = [ DG.V(matchesInd(1,:),1) , AG.coord(matchesInd(2,:),1) , nans ] ;
    yInit = [ DG.V(matchesInd(1,:),2) , AG.coord(matchesInd(2,:),2) , nans ] ;
    
    line(xInit', yInit', 'Color','b', 'LineStyle', '--') ;
      
    % vertices
    plot(DG.V(:,1), DG.V(:,2), 'b*');
    
    % edges between vertices
    if show_DG
        for i=1:size(DG.E, 1)
        line([DG.V(DG.E(i,1),1) DG.V(DG.E(i,2),1) ],...
             [DG.V(DG.E(i,1),2) DG.V(DG.E(i,2),2) ], 'Color', 'g');  
        end
    end
    
    % anchors
    plot(AG.coord(:,1), AG.coord(:,2), 'ys','MarkerSize', 9, 'MarkerFaceColor','y');
    
    % edges between anchors
    if show_AG
        [i, j] = find(ones(m, m));
        matchesInd = [i,j]';

        nans = NaN * ones(size(matchesInd,2),1) ;
        xInit = [ AG.coord(matchesInd(1,:),1) , AG.coord(matchesInd(2,:),1) , nans ] ;
        yInit = [ AG.coord(matchesInd(1,:),2) , AG.coord(matchesInd(2,:),2) , nans ] ;

        line(xInit', yInit', 'Color','y', 'LineStyle', '-') ;
    end
    
    
    hold off; 

 
 
end