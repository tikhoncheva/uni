function draw_graph(img, imgName, frames, adjMatrix, varargin)

    [v1,v2] = find(adjMatrix);
    
    %f1 = figure ; 
        imagesc(img) ;    
        colormap(gray); 
        hold on ;
        axis off;
       
        for j = 1 : size(v1,1)
            line([frames(1,v1(j)) frames(1,v2(j)) ],...
                 [frames(2,v1(j)) frames(2,v2(j)) ],... % edges
                                                            'Color', 'b');  
        end
        plot(frames(1,:),frames(2,:), 'y*')
    hold off;     
    
    % optionaly: save the image
    if nargin == 7 && strcmp(varargin{2}, 'true')
        print(f1, '-r80', '-dtiff', fullfile(['.' filesep 'graphs'], ...
                                      sprintf('%s',imgName)));
    end
end