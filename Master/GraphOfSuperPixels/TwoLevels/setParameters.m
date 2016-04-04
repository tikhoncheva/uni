function [handles] = setParameters(handles)
    
    parameters.nSuperPixels_hl = 5;
    
    parameters.nSuperPixels_ll = [10, 10, 10, 10, 10];
    
    handles.parameters = parameters;

end