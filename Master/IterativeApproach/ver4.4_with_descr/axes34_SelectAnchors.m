%% select anchor points on the first image 
% image is given through axis it is plotted on
%
% output: coordinates of the anchor points of the image
function AG = axes34_SelectAnchors(handles, DG)
    
    nAnchors = handles.nAnchors;
    count = 0;
    Acoord = [];
    
    while (count < nAnchors) 
        hold on;
        % get current position of the mouse
        [x,y] = ginput(1);
        plot(x, y, 'ys','MarkerSize', 9, 'MarkerFaceColor','y');
        Acoord = [Acoord; [x,y]];
        count = count + 1;
    end
    
    % build anchor graph
    kNN = str2double(get(handles.edit_kNN,'string'));
    AG = buildAGraph(DG, Acoord, kNN);
end