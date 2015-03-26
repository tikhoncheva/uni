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

% Last Modified by GUIDE v2.5 26-Mar-2015 17:56:15

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

%-------------------------------------------------------------------------
%       Before main window is made visible
%-------------------------------------------------------------------------

% --- Executes just before ia1 is made visible.
function ia1_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ia1 (see VARARGIN)

movegui(gcf,'center')
% Choose default command line output for ia1
handles.output = hObject;

handles.img1selected = 0;
handles.img2selected = 0;

handles.AG1isBuilt = 0;
handles.AG2isBuilt= 0;

handles = setParameters(handles);

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

% Graph matching algorithm
addpath(genpath('../../Tools/RRWM_release_v1.22'));
clc;

% Additional functions
addpath(genpath('./DependencyGraph'));
addpath(genpath('./AnchorGraph'));
addpath(genpath('./Matching'));

clc;

% UIWAIT makes ia1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%end



%-------------------------------------------------------------------------
%    Panel1 : select images and extract edge points with corresponding
%    descriptors
%-------------------------------------------------------------------------

% --- Outputs from this function are returned to the command line.
function varargout = ia1_OutputFcn(hObject, ~ , handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%
% Selcet first image
function pbSelect_img1_Callback(hObject, ~, handles)
[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    img1 = imread([pathname filesep filename]);
   
 
    handles.img1 = img1;
%     handles.img1SP = img1SP;   
    handles.img1selected = 1;
    
%     replotaxes(handles.axes1, img1);
    
    % Extract edge points and corresponding descriptors
    [edges, descr] = computeDenseSIFT(img1);

    zerocol_ind = all( ~any(descr), 1);
    descr(:, zerocol_ind) = []; % remove zero columns
    edges(:, zerocol_ind) = []; %  and corresponding points

    % Show it on the axis1
    axes(handles.axes1);cla reset;
    imagesc(img1), axis off; % plot_graph(img1, 'Image 2', DG1);
    
    % Show it on the axis3
    axes(handles.axes3);cla reset;
    imagesc(img1), axis off; % plot_graph(img1, 'Image 2', DG1);
    
    if handles.img2selected
        img3 = combine2images(img1, handles.img2);
        axes(handles.axes5);
        imagesc(img3), axis off;
    end
        
    % update data
    handles.features1.edges = edges;
    handles.features1.descr = descr;
    
    guidata(hObject,handles); 
    
    set(handles.pbBuildGraphs_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    
    set(handles.pbMatch_anchorgraphs, 'Enable', 'off');
    set(handles.pbMatch_dependencygraphs, 'Enable', 'off');

end

%
% Select second image
function pbSelect_img2_Callback(hObject, ~, handles)

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

    % Show it on the axis2 and axis 4 
    axes(handles.axes2);cla reset;
    imagesc(img2), axis off; % plot_graph(img2, 'Image 2', DG2);
    axes(handles.axes4);cla reset;
    imagesc(img2), axis off; %plot_graph(img2, 'Image 2', DG2);
    
    if handles.img1selected
        img3 = combine2images(handles.img1, img2);
        axes(handles.axes5);
        imagesc(img3), axis off;
    end
    

    % update data
    handles.features2.edges = edges;
    handles.features2.descr = descr;
    
    guidata(hObject,handles); 
    
    set(handles.pbBuildGraphs_img2, 'Enable', 'on');
    set(handles.pbLoadAnchors_img2, 'Enable', 'on');
end
%end

%-------------------------------------------------------------------------
%       Panel2 : building coarse graphs (ancor graph) and fine graphs 
%-------------------------------------------------------------------------


% --- Executes on button press in pbBuildGraphs_img1.
function pbBuildGraphs_img1_Callback(hObject, ~ , handles)
    handles.parameters.nAnchors1 = str2double(get(handles.editNAnchors1,'string')); 
    handles.parameters.nNodesProAnchor1 = ones(1,handles.parameters.nAnchors1) * 10;
    guidata(hObject,handles); 
    
    set(handles.pbSaveAnchors_img1, 'Enable', 'off');
    set(handles.pbLoadAnchors_img1, 'Enable', 'off');
    
    axes(handles.axes3);
    imagesc(handles.img1), axis off; % plot_graph(handles.img1, 'Image 1', handles.DG1);
    
    axes(handles.axes3);
    % build coarse (Anchor Graph AG) and fine (Dependency Graph DG) graph    
    [AG1, DG1, img1SP] = buildLowHighLevelGraphs (handles.img1, ...
                                                  handles.features1,...
                                                  handles.parameters.nAnchors1,...
                                                  handles.parameters.nNodesProAnchor1);  
    handles.AG1isBuilt = 1;
    
    % plot anchor graph
    show_DG = get(handles.cbShow_DG, 'Value');
    show_AG = get(handles.cbShow_AG, 'Value');
    cla reset;

    axes(handles.axes3);
%     plot_anchorgraph(handles.img1, handles.DG1, handles.AG1, show_DG, show_AG);
    plot_anchorgraph(img1SP.boundary, DG1, AG1, show_DG, show_AG);

    
    set(handles.pbSaveAnchors_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    
    if handles.AG2isBuilt 
        handles.DGmatches.objval  = 0.;
        handles.DGmatches.matches = zeros(size(DG1.V,1), size(handles.DG2.V,1));
        
        handles.AGmatches.objval  = 0.;
        handles.AGmatches.matches = zeros(size(AG1.V,1), size(handles.AG2.V,1));
   
        axes(handles.axes5);cla reset;
        plot_matches(handles.img1, AG1, handles.img2, handles.AG2, handles.AGmatches.matches);
        
        set(handles.pbMatch_anchorgraphs, 'Enable', 'on');
    end
    
    % update data
    handles.AG1 = AG1;
    handles.DG1 = DG1;
    handles.img1SP = img1SP;
    guidata(hObject,handles); 
    guidata(hObject,handles);     
%end


% --- Executes on button press in pbBuildGraphs_img1.
function pbBuildGraphs_img2_Callback(hObject, ~ , handles)
    handles.parameters.nAnchors2 = str2double(get(handles.editNAnchors2,'string')); 
    handles.parameters.nNodesProAnchor2 = ones(1,handles.parameters.nAnchors2) * 10;
    guidata(hObject,handles); 
    
    set(handles.pbSaveAnchors_img2, 'Enable', 'off');
    set(handles.pbLoadAnchors_img2, 'Enable', 'off');
    
    axes(handles.axes4);
    imagesc(handles.img2); % plot_graph(handles.img1, 'Image 1', handles.DG1);
    
    % build coarse (Anchor Graph AG) and fine (Dependency Graph DG) graph    
    [AG2, DG2, img2SP] = buildLowHighLevelGraphs (handles.img2, ...
                                                  handles.features2,...
                                                  handles.parameters.nAnchors2,...
                                                  handles.parameters.nNodesProAnchor2);  
    handles.AG2isBuilt = 1;
    
    % plot anchor graph
    show_DG = get(handles.cbShow_DG, 'Value');
    show_AG = get(handles.cbShow_AG, 'Value');
    cla reset;

    axes(handles.axes4);
%     plot_anchorgraph(handles.img2, handles.DG2, handles.AG2, show_DG, show_AG);
    plot_anchorgraph(img2SP.boundary, DG2, AG2, show_DG, show_AG);

    
    set(handles.pbSaveAnchors_img2, 'Enable', 'on');
    set(handles.pbLoadAnchors_img2, 'Enable', 'on');
    
    if handles.AG1isBuilt 
        handles.DGmatches.objval  = 0.;
        handles.DGmatches.matches = zeros(size(handles.DG1.V,1), size(DG2.V,1));
        
        handles.AGmatches.objval  = 0.;
        handles.AGmatches.matches = zeros(size(handles.AG1.V,1), size(AG2.V,1));
   
        axes(handles.axes5);cla reset;
        plot_matches(handles.img1, handles.AG1, handles.img2, AG2, handles.AGmatches.matches);
        
        set(handles.pbMatch_anchorgraphs, 'Enable', 'on');
    end
    
    % update data
    handles.AG2 = AG2;
    handles.DG2 = DG2;
    handles.img2SP = img2SP;
    guidata(hObject,handles);  
%end


% --- Executes on button press in pbSaveAnchors_img1.
function pbSaveAnchors_img1_Callback(hObject, ~, handles)

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');

AG = handles.AG1;
m = size(AG.V,1);
kNN = numel(find(AG.U(1,:)>0));

if  filename~=0
    save([pathname filesep filename] , 'm', 'kNN', 'AG');
end
%end

% --- Executes on button press in pbSaveAnchors_img2.
function pbSaveAnchors_img2_Callback(hObject, ~, handles)

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');

AG = handles.AG2;
m = size(AG.V,1);
kNN = numel(find(AG.U(1,:)>0));

if  filename~=0
    save([pathname filesep filename] , 'm', 'kNN', 'AG');
end
%end

% --- Executes on button press in pbLoadAnchors_img1.
function pbLoadAnchors_img1_Callback(hObject, ~, handles)

[filename, pathname] = uigetfile({'*.mat'}, 'File Selector');

if  filename~=0
    % read data from file
    load( [pathname filesep filename] ,'-mat', 'm', 'kNN', 'AG');                     

    set(handles.editNAnchors2,'string', m);
    set(handles.edit_nNodesProAnchor,'string', kNN);

    handles.AG1 = AG;
    handles.AG1isBuilt = 1;
    guidata(hObject, handles);

    %replot AG
    show_DG = get(handles.cbShow_DG, 'Value');
    show_AG = get(handles.cbShow_AG, 'Value');
    axes(handles.axes3);cla reset;
    plot_anchorgraph(handles.img1, handles.DG1, ...
                      handles.AG1, show_DG, show_AG); 

    if handles.AG2isBuilt  
       handles.AGmatches.objval  = 0.;
       handles.AGmatches.matches = zeros(size(handles.AG1.V,1), size(handles.AG2.V,1));

       axes(handles.axes5);cla reset;
       plot_matches(handles.img1, handles.AG1, handles.img2, handles.AG2, handles.AGmatches.matches);

       set(handles.pbMatch_anchorgraphs, 'Enable', 'on');
    end

    guidata(hObject, handles);
end  
%end

% --- Executes on button press in pbLoadAnchors_img2.
function pbLoadAnchors_img2_Callback(hObject, ~, handles)
[filename, pathname] = uigetfile({'*.mat'}, 'File Selector');

if  filename~=0
    % read data from file
    load( [pathname filesep filename] ,'-mat', 'm', 'kNN', 'AG');     

    set(handles.editNAnchors2,'string', m);
    set(handles.edit_nNodesProAnchor,'string', kNN);

    handles.AG2 = AG;
    handles.AG2isBuilt = 1;
    guidata(hObject, handles);

    %replot AG
    show_DG = get(handles.cbShow_DG, 'Value');
    show_AG = get(handles.cbShow_AG, 'Value');
    axes(handles.axes4);cla reset;
    plot_anchorgraph(handles.img2, handles.DG2, ...
                     handles.AG2, show_DG, show_AG);   

    if handles.AG1isBuilt
       handles.AGmatches.objval  = 0.;
       handles.AGmatches.matches = zeros(size(handles.AG1.V,1), size(handles.AG2.V,1));

       axes(handles.axes5);cla reset;
       plot_matches(handles.img1, handles.AG1, handles.img2, handles.AG2, handles.AGmatches.matches);

       set(handles.pbMatch_anchorgraphs, 'Enable', 'on');
    end    

    guidata(hObject, handles);
end
%end

% --- Executes on button press in cbShow_AG.
function cbShow_AG_Callback(hObject, ~, handles)

show_DG = get(handles.cbShow_DG, 'Value');
show_AG = get(handles.cbShow_AG, 'Value');

% replot first anchor graph
if (handles.AG1isBuilt)
    axes(handles.axes3);cla reset;
    plot_anchorgraph(handles.img1SP.boundary, handles.DG1, ...
                  handles.AG1, show_DG, show_AG);
end
% replot second anchor graph              
if (handles.AG2isBuilt)
    axes(handles.axes4);cla reset;
    plot_anchorgraph(handles.img2, handles.DG2, ...
                  handles.AG2, show_DG, show_AG);              
end


% --- Executes on button press in cbShow_DG.
function cbShow_DG_Callback(hObject, ~, handles)

show_DG = get(handles.cbShow_DG, 'Value');
show_AG = get(handles.cbShow_AG, 'Value');

% replot first anchor graph
if (handles.AG1isBuilt)
    axes(handles.axes3);cla reset;
    plot_anchorgraph(handles.img1SP.boundary, handles.DG1, ...
                  handles.AG1, show_DG, show_AG);
end
% replot first second graph       
if (handles.AG2isBuilt)
    axes(handles.axes4);cla reset;
    plot_anchorgraph(handles.img2, handles.DG2, ...
                  handles.AG2, show_DG, show_AG);  
end

%-------------------------------------------------------------------------
%       Panel3 : matching anchor graphs
%-------------------------------------------------------------------------

% --- Executes on button press in pbMatch_anchorgraphs.
function pbMatch_anchorgraphs_Callback(hObject, ~, handles)
%  We use Reweighted Random Walk Algorithm for the graph matching
%   see Minsu Cho, Jungmin Lee, and Kyoung Mu Lee   
%       "Reweighted Random Walks for Graph Matching"

[objval, matches] = matchAnchorGraphs(handles.AG1, handles.AG2);

axes(handles.axes5); cla reset;
plot_matches(handles.img1, handles.AG1, handles.img2, handles.AG2, matches);

axes(handles.axes6); cla reset;
plot_DGmatches(handles.img1, handles.DG1, handles.img2, handles.DG2, handles.DGmatches.matches);

set(handles.pbMatch_dependencygraphs, 'Enable', 'on');
%update data
handles.AGmatches.objval = objval;
handles.AGmatches.matches = matches;

guidata(hObject, handles);

axes(handles.axes5);
set(gca,'ButtonDownFcn', {@axes5_highlightAG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes5_highlightAG, handles}) 
%end

% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, ~, handles)

axes(handles.axes5);
set(gca,'ButtonDownFcn', {@axes5_highlightAG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes5_highlightAG, handles}) 
    
%-------------------------------------------------------------------------
%       Panel4 : matching dependency graphs
%-------------------------------------------------------------------------

% --- Executes on button press in pbMatch_dependencygraphs.
function pbMatch_dependencygraphs_Callback(hObject,  ~ , handles)

[objval, matches] = matchDGraphs(handles.DG1, handles.DG2, ...
                                 handles.AG1, handles.AG2, ...
                                 handles.AGmatches.matches);

%update data
handles.DGmatches.objval = objval;
handles.DGmatches.matches = matches;

%plotting
axes(handles.axes6); cla reset;
plot_DGmatches(handles.img1, handles.DG1, handles.img2, handles.DG2, handles.DGmatches.matches);

% highlithin
axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlightAG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlightAG, handles})   
%end


% --- Executes on mouse press over axes background.
function axes6_ButtonDownFcn(hObject, ~, handles)

gaxes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlightAG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlightAG, handles})   
