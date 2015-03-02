function varargout = ia1(varargin)
% IA1 MATLAB code for ia1.fig
%      IA1, by itself, creates a new IA1 or raises the existing
%      singleton*.
%
%      H = IA1 returns the handle to a new IA1 or the handle to
%      the existing singleton*.
%
%      IA1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IA1.M with the given input arguments.
%
%      IA1('Property','Value',...) creates a new IA1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ia1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ia1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ia1

% Last Modified by GUIDE v2.5 02-Mar-2015 17:26:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ia1_OpeningFcn, ...
                   'gui_OutputFcn',  @ia1_OutputFcn, ...
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


% --- Executes just before ia1 is made visible.
function ia1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ia1 (see VARARGIN)

% Choose default command line output for ia1
handles.output = hObject;

handles.img1selected = 0;
handles.img2selected = 0;

% Update handles structure
guidata(hObject, handles);


% Piotr Dollar toolbox
addpath(genpath('../../Tools/piotr_toolbox_V3.26/'));

% Edge extraction
addpath(genpath('../../Tools/edges-master/'));


% VL_Library
addpath(genpath('../../Tools/vlfeat-0.9.20/toolbox/'));
run vl_setup.m
clc;

% SLIC 
addpath(genpath('../../Tools/SLIC_MATLAB/'));
clc;


% Additional functions
addpath(genpath('./DependencyGraph'));
addpath(genpath('./AnchorGraph'));
clc;

% UIWAIT makes ia1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%end



% --- Outputs from this function are returned to the command line.
function varargout = ia1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%
% Selcet first image
function pbSelect_img1_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    img1 = imread([pathname filesep filename]);
    
    [img1SP.num, ... 
     img1SP.label, ...
     img1SP.boundary] = SLIC_Superpixels(im2uint8(img1),1000, 20);
 
    handles.img1 = img1;
    handles.img1SP = img1SP;   
    handles.img1selected = 1;
    
%     replotaxes(handles.axes1, img1);
    
    % Extract edge points and corresponding descriptors
    [edges, descr] = computeDenseSIFT(img1);

    zerocol_ind = all( ~any(descr), 1);
    descr(:, zerocol_ind) = []; % remove zero columns
    edges(:, zerocol_ind) = []; %  and corresponding points

    % build dependency graph
    DG1 = buildDGraph(edges, descr, img1SP);

    % Show it on the axis2
    axes(handles.axes1);
    draw_graph(img1, 'Image 2', DG1);
    axes(handles.axes3);
    draw_graph(img1, 'Image 2', DG1);
    if handles.img2selected
        img3 = combine2images(img1, handles.img2);
        axes(handles.axes5);
        imagesc(img3)
    end
        
    % update data
    handles.features1.edges = edges;
    handles.features1.descr = descr;
    handles.DG1 = DG1;
    
    guidata(hObject,handles); 
    
    set(handles.pbSelectAnchors_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');

end

%
% Select second image
function pbSelect_img2_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    img2 = imread([pathname filesep filename]);
    
    [img2SP.num, ... 
     img2SP.label, ...
     img2SP.boundary] = SLIC_Superpixels(im2uint8(img2),1000, 20);
 
    handles.img2 = img2;
    handles.img2SP = img2SP;   
    handles.img2selected = 1;
    
    replotaxes(handles.axes2, img2);

    % Extract edge points and corresponding descriptors
    [edges, descr] = computeDenseSIFT(img2);

    zerocol_ind = all( ~any(descr), 1);
    descr(:, zerocol_ind) = []; % remove zero columns
    edges(:, zerocol_ind) = [];

    % build dependency graph
    DG2 = buildDGraph(edges, descr, img2SP);

    % Show it on the axis2 and axis 4 
    axes(handles.axes2);
    draw_graph(img2, 'Image 2', DG2);
    axes(handles.axes4);
    draw_graph(img2, 'Image 2', DG2);
    
    if handles.img1selected
        img3 = combine2images(handles.img1, img2);
        axes(handles.axes5);
        imagesc(img3)
    end
    

    % update data
    handles.features2.edges = edges;
    handles.features2.descr = descr;
    handles.DG2 = DG2;
    
    guidata(hObject,handles); 
    
    set(handles.pbSelectAnchors_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img2, 'Enable', 'on');
end
%end


% --- Executes on button press in pbSelectAnchors_img1.
function pbSelectAnchors_img1_Callback(hObject, eventdata, handles)
    handles.nAnchors = 5; %str2double(get(handles.editNAnchors,'string'));
    handles.AG1.coord = [];
    
    guidata(hObject,handles); 
    
    set(handles.pbSaveAnchors_img1, 'Enable', 'off');
    set(handles.pbLoadAnchors_img1, 'Enable', 'off');
    
    axes(handles.axes3);
    draw_graph(handles.img1, 'Image 1', handles.DG1);
    set(gca,'ButtonDownFcn', {@axes3_SelectAnchors, handles})
    set(get(gca,'Children'),'ButtonDownFcn', {@axes3_SelectAnchors, handles})
%end


% --- Executes on button press in pbSelectAnchors_img1.
function pbSelectAnchors_img2_Callback(hObject, eventdata, handles)
    handles.nAnchors = str2double(get(handles.editNAnchors,'string'));
    handles.AG2.coord = [];
    
    guidata(hObject,handles); 
    
    set(handles.pbSaveAnchors_img2, 'Enable', 'off');
    set(handles.pbLoadAnchors_img2, 'Enable', 'off');
    
    axes(handles.axes4);
    draw_graph(handles.img2, 'Image 2', handles.DG2);
    set(gca,'ButtonDownFcn', {@axes4_SelectAnchors, handles})
    set(get(gca,'Children'),'ButtonDownFcn', {@axes4_SelectAnchors, handles})
%end


% --- Executes on button press in pbSaveAnchors_img1.
function pbSaveAnchors_img1_Callback(hObject, eventdata, handles)

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');

if  filename~=0
    save([pathname filesep filename] ,'handles.AG1');
end
%end

% --- Executes on button press in pbSaveAnchors_img2.
function pbSaveAnchors_img2_Callback(hObject, eventdata, handles)

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');

if  filename~=0
    save([pathname filesep filename] ,'handles.AG2');
end
%end

% --- Executes on button press in pbLoadAnchors_img1.
function pbLoadAnchors_img1_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadAnchors_img1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbLoadAnchors_img2.
function pbLoadAnchors_img2_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadAnchors_img2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbShow_AG.
function cbShow_AG_Callback(hObject, eventdata, handles)

show_DG = get(handles.cbShow_DG, 'Value');
show_AG = get(handles.cbShow_AG, 'Value');

% replot first anchor graph
axes(handles.axes3);cla reset;
plot_anchor_graph(handles.img1, handles.DG1, ...
                  handles.AG1, show_DG, show_AG);
% replot second anchor graph              
axes(handles.axes4);cla reset;
plot_anchor_graph(handles.img2, handles.DG2, ...
                  handles.AG2, show_DG, show_AG);              


% --- Executes on button press in cbShow_DG.
function cbShow_DG_Callback(hObject, eventdata, handles)

show_DG = get(handles.cbShow_DG, 'Value');
show_AG = get(handles.cbShow_AG, 'Value');

% replot first anchor graph
axes(handles.axes3);cla reset;
plot_anchor_graph(handles.img1, handles.DG1, ...
                  handles.AG1, show_DG, show_AG);
% replot first second graph              
axes(handles.axes4);cla reset;
plot_anchor_graph(handles.img2, handles.DG2, ...
                  handles.AG2, show_DG, show_AG);  
