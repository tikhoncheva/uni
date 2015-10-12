%%
function plot_twolevelgraphs(img, fG, cG)

   if (ndims(img)>1)
        imshow(img, []) ;
    end
    
    hold on ;
    axis off;
      
    %% Fine Graph fG
    
    % edges between vertices
    edges = fG.E';
    edges(end+1,:) = 1;
    edges = edges(:);

    points = fG.V(edges,:);
    points(3:3:end,:) = NaN;

    line(points(:,1), points(:,2), 'Color', 'g');
    
    % Nodes
    plot(fG.V(:,1), fG.V(:,2), 'bo', 'MarkerFaceColor','b');
    
    %% Coarse Graph cG
    
    % edges between anchors
    edges = cG.E';
    edges(end+1,:) = 1;
    edges = edges(:);

    points = cG.V(edges,:);
    points(3:3:end,:) = NaN;

    line(points(:,1), points(:,2), 'Color','y', 'LineWidth', 2);

    % nodes
    plot(cG.V(:,1), cG.V(:,2), 'yo','MarkerSize', 8, 'MarkerFaceColor','y');
    
    % edges between vertises on two levels
    [i, j] = find(fG.U);
    matchesInd = [i,j]';

    nans = NaN * ones(size(matchesInd,2),1) ;
    xInit = [ fG.V(matchesInd(1,:),1) , cG.V(matchesInd(2,:),1) , nans ] ;
    yInit = [ fG.V(matchesInd(1,:),2) , cG.V(matchesInd(2,:),2) , nans ] ;
    line(xInit', yInit', 'Color','m', 'LineStyle', '--', 'LineWidth', 0.5) ;    
    
    hold off; 

end