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
%  {     V,    coordinates of the anchors (m x 2)
%        U,    matrix of the nearest anchors for each point v_i \in V
%  }
%
% show_AG   show edges of the AG
% show_DG   show edges of the DG

function plot_anchorgraph(img, DG, AG, show_DG, show_AG)

    if (ndims(img)>1)
        imagesc(img) ;
    end
    
    hold on ;
    axis off;
    
    n = size(DG.V, 1);
    m = size(AG.V, 1);
    
    % edges between vertives and anchors
%     [i, j] = find(AG.U);
%     matchesInd = [i,j]';
% 
%     nans = NaN * ones(size(matchesInd,2),1) ;
%     xInit = [ DG.V(matchesInd(1,:),1) , AG.V(matchesInd(2,:),1) , nans ] ;
%     yInit = [ DG.V(matchesInd(1,:),2) , AG.V(matchesInd(2,:),2) , nans ] ;
%     line(xInit', yInit', 'Color','m', 'LineStyle', '--', 'LineWidth', 0.5) ;
%       
    % vertices
%     plot(DG.V(:,1), DG.V(:,2), 'b*', 'MarkerSize',50);
    
    % edges between vertices
    if show_DG
%         [i,j, ~] = find(DG.adjM);
%         for k=1:size(i, 1)
%             line([DG.V(i(k),1) DG.V(j(k),1) ],...
%                  [DG.V(i(k),2) DG.V(j(k),2) ], 'Color', 'g');  
%         end

        for i=1:size(DG.E, 1)
            line([DG.V(DG.E(i,1),1) DG.V(DG.E(i,2),1) ],...
                 [DG.V(DG.E(i,1),2) DG.V(DG.E(i,2),2) ], 'Color', 'g');  
        end
    end
    
    % anchors
    plot(AG.V(:,1), AG.V(:,2), 'yo','MarkerSize', 9, 'MarkerFaceColor','y');
    
    % edges between anchors
    if show_AG
        matchesInd = AG.E';

        nans = NaN * ones(size(matchesInd,2),1) ;
        xInit = [ AG.V(matchesInd(1,:),1) , AG.V(matchesInd(2,:),1) , nans ] ;
        yInit = [ AG.V(matchesInd(1,:),2) , AG.V(matchesInd(2,:),2) , nans ] ;

        line(xInit', yInit', 'Color','y', 'LineStyle', '-', 'LineWidth', 3) ;
    end
    
    
    hold off; 

 
 
end