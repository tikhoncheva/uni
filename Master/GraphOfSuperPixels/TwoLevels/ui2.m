function varargout = ui2(varargin)
% UI2 MATLAB code for ui2.fig

% Last Modified by GUIDE v2.5 08-Apr-2015 16:37:03

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


% -----------------------------------------------------------------------
% Select image
% -----------------------------------------------------------------------

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
    handles.HLGraph_build = 0;
    handles.LLGraph_build = 0;
    
    guidata(hObject,handles); 
    
    set(handles.chbox_Show_HLGraph, 'enable', 'on');
    set(handles.chbox_Show_LLGraph, 'enable', 'on');
    
    set(handles.chbox_ShowSP_HL, 'enable', 'on');
    set(handles.chbox_ShowSP_LL, 'enable', 'on');
    
    set(handles.pbuttonBuildGraph, 'enable', 'on');

end

% -----------------------------------------------------------------------
% Build two-level graph structure
% -----------------------------------------------------------------------

function pbuttonBuildGraph_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
 
img = handles.img;
replotaxes(handles.axes1, img);

% Compute features of the image

% Extract edge points and corresponding descriptors
features.edges = [];
features.descr = [];
[features.edges, features.descr] = computeDenseSIFT(img);

% number of SP to build Higher Leverl Graph
nSP_hl = str2num( get(handles.editSP_HL, 'String') );
% number of SP to build Lover Level Graph based on Higher Level Graph
nSP_ll = str2num( get(handles.editSP_LL, 'String') );

% HLG - Higher Level Graph
% LLG - Lower Level Graph
[ HLGraph, LLGraph, imgSP ] = buildLowHighLevelGraphs(img, features, nSP_hl, nSP_ll);


% Show result on the axis2
showHLG = get(handles.chbox_Show_HLGraph,'Value');
showLLG = get(handles.chbox_Show_LLGraph,'Value');
axes(handles.axes2);
plot_twolevelgraphs(img, HLGraph, LLGraph, showHLG, showLLG);

% Update data
handles.features = features;

handles.imgSP = imgSP; 

handles.HLGraph = HLGraph;
handles.LLGraph = LLGraph;

handles.HLGraph_build = 1;
handles.LLGraph_build = 1;

guidata(hObject,handles);


set(handles.pb_Recalc_HL, 'Enable', 'On');
set(handles.pb_Recalc_LL, 'Enable', 'On');

%

% -----------------------------------------------------------------------
% Show graphs on the different levels
% -----------------------------------------------------------------------

% --- Executes on button press in chbox_Show_HLGraph.
function chbox_Show_HLGraph_Callback(hObject, eventdata, handles)
if handles.HLGraph_build

    handles = guidata(hObject);
    
    img = handles.img;

    HLGraph = handles.HLGraph;
    LLGraph = handles.LLGraph;

    % Show result on the axis2
    showHLG = get(handles.chbox_Show_HLGraph,'Value');
    showLLG = get(handles.chbox_Show_LLGraph,'Value');
    axes(handles.axes2);
    plot_twolevelgraphs(img, HLGraph, LLGraph, showHLG, showLLG);
    
end
%

% --- Executes on button press in chbox_Show_LLGraph.
function chbox_Show_LLGraph_Callback(hObject, eventdata, handles)
if handles.LLGraph_build

    handles = guidata(hObject);
    
    img = handles.img;

    HLGraph = handles.HLGraph;
    LLGraph = handles.LLGraph;

    % Show result on the axis2
    showHLG = get(handles.chbox_Show_HLGraph,'Value');
    showLLG = get(handles.chbox_Show_LLGraph,'Value');
    axes(handles.axes2);
    plot_twolevelgraphs(img, HLGraph, LLGraph, showHLG, showLLG);
    
end
%

% -----------------------------------------------------------------------
% Show Super Pixel, if this option was selected
% -----------------------------------------------------------------------

% --- Executes on button press in chbox_ShowSP_HL.
function chbox_ShowSP_HL_Callback(hObject, eventdata, handles)
if handles.HLGraph_build

    handles = guidata(hObject);
    
    img = handles.img;

    HLGraph = handles.HLGraph;
    LLGraph = handles.LLGraph;

    % Show result on the axis2
    showHLG = get(handles.chbox_Show_HLGraph,'Value');
    showLLG = get(handles.chbox_Show_LLGraph,'Value');
    axes(handles.axes2);
    plot_twolevelgraphs(img, HLGraph, LLGraph, showHLG, showLLG);
end

% --- Executes on button press in chbox_ShowSP_LL.
function chbox_ShowSP_LL_Callback(hObject, eventdata, handles)
if handles.LLGraph_build

    handles = guidata(hObject);
    
    img = handles.img;

    HLGraph = handles.HLGraph;
    LLGraph = handles.LLGraph;

    % Show result on the axis2
    showHLG = get(handles.chbox_Show_HLGraph,'Value');
    showLLG = get(handles.chbox_Show_LLGraph,'Value');
    axes(handles.axes2);
    plot_twolevelgraphs(img, HLGraph, LLGraph, showHLG, showLLG);
    
end
%



% -----------------------------------------------------------------------
% Recalculate graphs, if number of SP on some level was changed
% -----------------------------------------------------------------------

function pb_Recalc_HL_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
img = handles.img;
features = handles.features;

% number of SP to build Higher Leverl Graph
nSP_hl = str2num( get(handles.editSP_HL, 'String') );
% number of SP to build Lover Level Graph based on Higher Level Graph
nSP_ll = str2num( get(handles.editSP_LL, 'String') );

% HLG - Higher Level Graph
% LLG - Lower Level Graph
[ HLGraph, LLGraph, imgSP ] = buildLowHighLevelGraphs(img, features, nSP_hl, nSP_ll);


% Show result on the axis2
showHLG = get(handles.chbox_Show_HLGraph,'Value');
showLLG = get(handles.chbox_Show_LLGraph,'Value');
axes(handles.axes2);
plot_twolevelgraphs(img, HLGraph, LLGraph, showHLG, showLLG);

% Update data
handles.features = features;

handles.imgSP = imgSP; 

handles.HLGraph = HLGraph;
handles.LLGraph = HLLGraph;

handles.HLGraph_build = 1;
handles.LLGraph_build = 1;

guidata(hObject,handles);


% --- Executes on button press in pb_Recalc_LL.
function pb_Recalc_LL_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
img = handles.img;
features = handles.features;

% number of SP to build Higher Leverl Graph
nSP_hl = str2num( get(handles.editSP_HL, 'String') );
% number of SP to build Lover Level Graph based on Higher Level Graph
nSP_ll = str2num( get(handles.editSP_LL, 'String') );

% HLG - Higher Level Graph
% LLG - Lower Level Graph
[ HLGraph, LLGraph, imgSP ] = buildLowHighLevelGraphs(img, features, nSP_hl, nSP_ll);


% Show result on the axis2
showHLG = get(handles.chbox_Show_HLGraph,'Value');
showLLG = get(handles.chbox_Show_LLGraph,'Value');
axes(handles.axes2);
plot_twolevelgraphs(img, HLGraph, LLGraph, showHLG, showLLG);

% Update data
handles.features = features;

handles.imgSP = imgSP; 

handles.HLGraph = HLGraph;
handles.LLGraph = HLLGraph;

handles.HLGraph_build = 1;
handles.LLGraph_build = 1;

guidata(hObject,handles);

