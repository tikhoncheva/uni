function h = plot_graph(img, G)

    if (ndims(img)>1)
        h = imshow(img);
    end
    
    hold on ;
    axis off;
       
    % plot edges
    edges = G.E';
    edges(end+1,:) = 1;
    edges = edges(:);

    points = G.V(edges,:);
    points(3:3:end,:) = NaN;

    line(points(:,1), points(:,2), 'Color', 'g');
          
    % plot vertices
    plot(G.V(:,1),G.V(:,2), 'b*')
    hold off;     
    
end