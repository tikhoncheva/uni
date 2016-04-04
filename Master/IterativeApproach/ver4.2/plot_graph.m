% function for plotting of the anchor graph 
% Input:
% img       given imHLGe
%
%
% LLGraph =      lower level graph
%  {    V,  coordinates of the vertices (n x 2)
%       E,  eLLGes
%       D  descriptors of the vertices
%       U, matrix of dependences between nodes of HLGraph and those of LLGraph
%  }
%
%
% show_HLGraphs   show eLLGes of the HLG
% show_LLGraphs   show eLLGes of the LLG

function plot_graph(img, LLG, varargin)

    if (ndims(img)>1)
        imagesc(img);
    end
  
    hold on ;    axis off;

    % edges between vertices
    edges = LLG.E';
    edges(end+1,:) = 1;
    edges = edges(:);
    points = LLG.V(edges,:);
    points(3:3:end,:) = NaN;
    line(points(:,1), points(:,2), 'Color', 'g');
    
    % nodes
    plot(LLG.V(:,1), LLG.V(:,2), 'ko', 'MarkerFaceColor', [0 0 0]);       
    
    hold off; 

end