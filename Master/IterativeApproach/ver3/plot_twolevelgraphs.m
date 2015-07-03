% function for plotting of the anchor graph 
% Input:
% img       given imHLGe
%
% HLGraph =      higher level graph
%  {     V,    coordinates of the anchors (m x 2)
%        U,    matrix of the nearest anchors for each point v_i \in V
%  }
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

function plot_twolevelgraphs(img, LLG, HLG, show_LLG, show_HLG, varargin)

    if (ndims(img)>1)
        imagesc(img);
    end
    
    hold on ;
    axis off;
    
    cmap = hsv(size(HLG.V,1));
    cmap = [cmap; [0.0 0.0 0.0]];
    
%                      ------------------------------------
%                            initial graph       
    % edges between vertices
    if show_LLG
        edges = LLG.E';
        edges(end+1,:) = 1;
        edges = edges(:);

        points = LLG.V(edges,:);
        points(3:3:end,:) = NaN;

        line(points(:,1), points(:,2), 'Color', 'g');
    end
    

    % vertices (color nodes in each subgraph in different color)
    col_mapping = size(cmap,1)*ones(1,size(HLG.V,1))    ;
    if (nargin == 7) % assign same color to the nodes in matched subgraphs
        matching = varargin{1};
        col = varargin{2};
        col_mapping(matching(:,2)) = matching(:,1);
        if col==2
            col_mapping(matching(:,2)) = matching(:,1);
        end
        if col==1
            col_mapping(matching(:,1)) = matching(:,1);
        end
    end
    
    for i=1:numel(col_mapping)
        Vi_ind = HLG.U(:,i);
        plot(LLG.V(Vi_ind,1), LLG.V(Vi_ind,2), 'ko', 'MarkerFaceColor', cmap(col_mapping(i),:));       
    end
    
%                      ------------------------------------
%                             anchor graph
    % edges between anchors
    if show_HLG
        matchesInd = HLG.E';

        nans = NaN * ones(size(matchesInd,2),1) ;
        xInit = [ HLG.V(matchesInd(1,:),1) , HLG.V(matchesInd(2,:),1) , nans ] ;
        yInit = [ HLG.V(matchesInd(1,:),2) , HLG.V(matchesInd(2,:),2) , nans ] ;

        line(xInit', yInit', 'Color','y', 'LineStyle', '-', 'LineWidth', 3) ;
    end
    % anchors
    plot(HLG.V(:,1), HLG.V(:,2), 'bo','MarkerSize', 9, 'MarkerFaceColor','y');

%                      ------------------------------------
%                             edges connecting two levels  
    [i, j] = find(HLG.U);
    matchesInd = [i,j]';

    nans = NaN * ones(size(matchesInd,2),1) ;
    xInit = [ LLG.V(matchesInd(1,:),1) , HLG.V(matchesInd(2,:),1) , nans ] ;
    yInit = [ LLG.V(matchesInd(1,:),2) , HLG.V(matchesInd(2,:),2) , nans ] ;
    line(xInit', yInit', 'Color','m', 'LineStyle', '--', 'LineWidth', 0.5) ;

    
    hold off; 

end