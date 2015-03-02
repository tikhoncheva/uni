%% select anchor points on the first image 
% image is given through axis it is plotted on
%
% output: coordinates of the anchor points of the image
function axes3_SelectAnchors(hObject, eventdata, handles)
   

    nAnchors = handles.nAnchors;
    count = size(handles.AG1.coord,1);
    
    if (count < nAnchors)
        % get current position of the mouse
        cP = get(gca,'Currentpoint');
        x = cP(1,1);
        y = cP(1,2);

        handles.AG1.coord = [handles.AG1.coord; [x,y]];
        count = count + 1;
        
        % plot new anchor on the image
        axes(handles.axes3);
        rectangle('Position',[x-3,y-3, 5, 5],'FaceColor','y');
        
        set(gca,'ButtonDownFcn', {@axes3_SelectAnchors, handles})
        set(get(gca,'Children'),'ButtonDownFcn', {@axes3_SelectAnchors, handles})
    end
    
    % build anchor graph
    if (count == nAnchors)
        kNN = str2double(get(handles.edit_kNN,'string'));
        
        handles.AG1.U = nearest_anchors(handles.DG1.V, handles.AG1.coord, kNN);
                                    
        % plot anchor graph
        show_DG = get(handles.cbShow_DG, 'Value');
        show_AG = get(handles.cbShow_AG, 'Value');
        
        axes(handles.axes3);cla reset;
        plot_anchor_graph(handles.img1, handles.DG1, ...
                          handles.AG1, show_DG, show_AG);
        
        set(handles.pbSaveAnchors_img1, 'Enable', 'on');
        set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    end
    
    guidata(hObject,handles); 
end