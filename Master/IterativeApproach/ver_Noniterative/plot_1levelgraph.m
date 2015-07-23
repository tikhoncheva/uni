% function for plotting of the anchor graph 
% Input:
% img       given image
% G =      graph
%  {    V,  coordinates of the vertices (n x 2)
%       E,  eLLGes
%       D  descriptors of the vertices
%  }
%
% show_edges   show edges of G

function plot_1levelgraph(img, G, show_edges)

    if (ndims(img)>1)
        imagesc(img);
    end
    
    hold on ;
    axis off;
    
    if show_edges
        edges = G.E';
        edges(end+1,:) = 1;
        edges = edges(:);

        points = G.V(edges,:);
        points(3:3:end,:) = NaN;

        line(points(:,1), points(:,2), 'Color', 'g');
    end
    
   plot(G.V(:,1), G.V(:,2), 'ko', 'MarkerFaceColor', [0.0 0.0 0.0]); 
    
   hold off; 

end