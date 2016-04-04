function varargout = ui2(varargin)
% UI2 MATLAB code for ui2.fig

% Last Modified by GUIDE v2.5 08-Apr-2015 10:26:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ui2_OpeningFcn, ...
                   'gui_OutputFcn',  @ui2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ui2 is made visible.
function ui2_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for ui2
handles.output = hObject;
guidata(hObject,handles); 

% Piotr Dollar toolbox
addpath(genpath('../../Tools/piotr_toolbox_V3.26/'));
display('added path to Piotr Dollar Toolbox');

% Edge extraction
addpath(genpath('../../Tools/edges-master/'));
display('added path to Piotr Dollar Toolbox (Edge Master)');

% VL_Library
addpath(genpath('../../Tools/vlfeat-0.9.20/toolbox/'));
% run vl_setup.m
run vl_setup('quiet')
display('added path to vlFeat Library');
% clc;

% SLIC 
addpath(genpath('../../Tools/SLIC_MATLAB/'));
display('added path to SCIC Library');
% clc;


% Additional functions
%

set(handles.axes1,'XTick',[]);
set(handles.axes1,'YTick',[]);

set(handles.axes2,'XTick',[]);
set(handles.axes2,'YTick',[]);


% --- Outputs from this function are returned to the command line.
function varargout = ui2_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
%
%   open image
%
function OpenImage_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    set(handles.filename1, 'String', filename);
    img = imread([pathname filesep filename]);
    
    % show image
    replotaxes(handles.axes1, img);
    
    % Update data
    handles.img = img;
    handles.img_selected = 1;
    handles.GoSP_build = 0;
    guidata(hObject,handles); 
    
    set(handles.checkboxShowSP, 'enable', 'on');
    set(handles.pbuttonBuildGraph, 'enable', 'on');

end

% --------------------------------------------------------------------
%
%   Build dependency graph
%
function pbuttonBuildGraph_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
 
img = handles.img;
replotaxes(handles.axes1, img);

% Compute features of the image

% Extract edge points and corresponding descriptors
[edges, descr] = computeDenseSIFT(img);

% Build graph of super pixels (GoSP)
nSuperPixels = str2num( get(handles.editSP1, 'String') );
[GoSP, imgSP] = buildGraph(img, edges, descr, nSuperPixels);

% Show it on the axis2
axes(handles.axes2);
if get(handles.checkboxShowSP,'Value')
    draw_graph(imgSP.boundary, 'Image 1', GoSP);              
else
    draw_graph(img, 'Image 1', GoSP);
end

% Update data
handles.edges = edges;
handles.edgeDescr = descr;
handles.imgSP = imgSP;   
handles.GoSP = GoSP;
handles.GoSP_build = 1;

set(handles.pb_Recalc, 'Enable', 'On');
guidata(hObject,handles);


% --- Executes on button press in checkboxShowSP.
function checkboxShowSP_Callback(hObject, eventdata, handles)

if handles.GoSP_build

    handles = guidata(hObject);
    
    img = handles.img;
    imgSP = handles.imgSP;
    GoSP = handles.GoSP;

    checked = get(hObject,'Value');

    axes(handles.axes2);
    if checked 
        draw_graph(imgSP.boundary, 'Image 1', GoSP);              
    else
        draw_graph(img, 'Image 1', GoSP);
    end
end


% --- Executes on button press in pb_Recalc.
%
% Recalculate super pixel of the image and build new dependency graph
%
function pb_Recalc_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
img = handles.img;
edges = handles.edges;
descr = handles.edgeDescr;

% Build graph of super pixels (GoSP)
nSuperPixels = str2num( get(handles.editSP1, 'String') );
[GoSP, imgSP] = buildGraph(img, edges, descr, nSuperPixels);

% Show it on the axis2
axes(handles.axes2);
if get(handles.checkboxShowSP,'Value')
    draw_graph(imgSP.boundary, 'Image 1', GoSP);              
else
    draw_graph(img, 'Image 1', GoSP);
end

% Save all data
handles.imgSP = imgSP;   
handles.GoSP = GoSP;
handles.GoSP_build = 1;

guidata(hObject,handles);
