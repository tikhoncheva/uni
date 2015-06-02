function [handles] = setParameters(handles)
    
    parameters.nAnchors1 = 5;
    parameters.nAnchors2 = 5;
    
    parameters.nNodesProAnchor1 = 10; %[10, 10, 10, 10, 10];
    parameters.nNodesProAnchor2 = 10; %[10, 10, 10, 10, 10];
    
    handles.parameters = parameters;

end