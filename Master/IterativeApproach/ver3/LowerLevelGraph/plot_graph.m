function plot_graph(img, imgName, G, varargin)

    if (ndims(img)>1)
        imagesc(img) ;
    end
    
    colormap(gray);
    hold on ;
    axis off;
       
    % plot edges
%     [i,j, ~] = find(G.adjM);
%     for k=1:size(i, 1)
%         line([G.V(i(k),1) G.V(j(k),1) ],...
%              [G.V(i(k),2) G.V(j(k),2) ], 'Color', 'g');  
%     end

    for i=1:size(G.E, 1)
        line([G.V(G.E(i,1),1) G.V(G.E(i,2),1) ],...
                 [G.V(G.E(i,1),2) G.V(G.E(i,2),2) ], 'Color', 'g');  
    end
   
    % plot vertices
    plot(G.V(:,1),G.V(:,2), 'b*')
    hold off;     
    
    % optionaly: save the image
    if nargin == 7 && strcmp(varargin{2}, 'true')
        print(f1, '-r80', '-dtiff', fullfile(['.' filesep 'graphs'], ...
                                      sprintf('%s',imgName)));
    end
end