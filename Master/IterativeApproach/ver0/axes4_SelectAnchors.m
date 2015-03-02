%% select anchor points on the first image 
% image is given through axis it is plotted on
%
% output: coordinates of the anchor points of the image
function axes4_SelectAnchors(hObject, eventdata, handles)
    
    nAnchors = handles.nAnchors;
    count = size(handles.AG2.coord,1);
    
    if (count < nAnchors)
        % get current position of the mouse
        cP = get(gca,'Currentpoint');
        x = cP(1,1);
        y = cP(1,2);

        handles.AG2.coord = [handles.AG2.coord; [x,y]];
        count = count + 1;
        
        % plot new anchor on the image
        axes(handles.axes4);
        rectangle('Position',[x-3,y-3, 5, 5],'FaceColor','y');
        
        set(gca,'ButtonDownFcn', {@axes4_SelectAnchors, handles})
        set(get(gca,'Children'),'ButtonDownFcn', {@axes4_SelectAnchors, handles})
    end
    
    % build anchor graph
    if (count == nAnchors)
        kNN = str2double(get(handles.edit_kNN,'string'));
        
        handles.AG2.U = nearest_anchors(handles.DG2.V, handles.AG2.coord, kNN);
                                    
        % plot anchor graph
        show_DG = get(handles.cbShow_DG, 'Value');
        show_AG = get(handles.cbShow_AG, 'Value');
        
        axes(handles.axes4);cla reset;
        plot_anchor_graph(handles.img2, handles.DG2, ...
                          handles.AG2, show_DG, show_AG);
        
        set(handles.pbSaveAnchors_img2, 'Enable', 'on');
        set(handles.pbLoadAnchors_img2, 'Enable', 'on');
    end
    
    guidata(hObject,handles); 
end