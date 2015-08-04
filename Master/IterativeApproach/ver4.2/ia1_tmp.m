 
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

% Last Modified by GUIDE v2.5 04-Aug-2015 15:37:13

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

handles.HLG1isBuilt = 0;
handles.HLG2isBuilt= 0;

% Update handles structure 
guidata(hObject, handles);


% VL_Library
addpath(genpath('../../Tools/vlfeat-0.9.20/toolbox/'));
run vl_setup.m
% clc;

% SLIC 
addpath(genpath('../../Tools/SLIC_MATLAB/'));
% clc;

% Graph matching algorithm
addpath(genpath('../../Tools/RRWM_release_v1.22'));
% clc;

% Export figure
addpath(genpath('../../Tools/altmany_export_fig'));
% clc;

% Additional functions
addpath(genpath('./toyProblem_realimg'));
addpath(genpath('./toyProblem'));
% addpath(genpath('./HigherLevelGraph'));
% addpath(genpath('./LowerLevelGraph'));
% addpath(genpath('./Matching_HL'));
% addpath(genpath('./Matching_LL'));
% addpath(genpath('./ransac'));
% addpath(genpath('./RANSAC2'));
% addpath(genpath('./GraphCoarsening'));
addpath(genpath('./rearrange_subgraphs'));
addpath(genpath('./rearrange_subgraphs_22'));

addpath(genpath('./2levelGM'));

% clc;

set(handles.axes1,'XTick',[]);
set(handles.axes1,'YTick',[]);

set(handles.axes2,'XTick',[]);
set(handles.axes2,'YTick',[]);

set(handles.axes3,'XTick',[]);
set(handles.axes3,'YTick',[]);

set(handles.axes4,'XTick',[]);
set(handles.axes4,'YTick',[]);

set(handles.axes5,'XTick',[]);
set(handles.axes5,'YTick',[]);

set(handles.axes6,'XTick',[]);
set(handles.axes6,'YTick',[]);

% UIWAIT makes ia1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%end


% --- Outputs from this function are returned to the command line.
function varargout = ia1_OutputFcn(~, ~ , handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%-------------------------------------------------------------------------
%   Synthetic Graph Matching
% --------------------------------------------------------------------
% --- Executes on button press in pbToyProblem.
function pbToyProblem_Callback(hObject, ~, handles)   
       
    % two random graphs
    setParameters;
    [img1, img2, LLG1, LLG2, GT] = make2SyntheticGraphs(igparam);
    
    % image pyramid
    IP1 = imagePyramid(img1, ipparam);
    IP2 = imagePyramid(img2, ipparam);
    
    % update dta
    
    handles.IP1 = IP1;
    handles.IP2 = IP2;
    
    handles.img1selected = 0;
    handles.img2selected = 0;
    
    handles.LLG1 = LLG1;
    handles.LLG2 = LLG2;
    handles.GT = GT;                % ground truth
    
    handles.HLG1isBuilt = 0;
    handles.HLG2isBuilt = 0;
    
    handles.IPlevel = 1;
    handles.Iteration = 1;
    handles.SummaryT = 0.; 
    
    handles.HLGmatches = []; 
    handles.LLGmatches = [];
    handles.affTrafo = [];

    guidata(hObject,handles); 
    
    % plot graphs
    axes(handles.axes1);
    plot_graph(img1, LLG1);
    
    axes(handles.axes2);
    plot_graph(img2, LLG2);
    
    axes(handles.axes3);
    plot_graph(img1, LLG1);
    
    axes(handles.axes4);
    plot_graph(img2, LLG2);
    
    img3 = combine2images(img1, img2);  % combine two images
    
    axes(handles.axes5);
    imagesc(img3), axis off;
    
    axes(handles.axes6);
    imagesc(img3), axis off;
                                                                                                                       
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    set(handles.pbBuildGraphs_img1, 'Enable', 'on');
    set(handles.pbBuildGraphs_img2, 'Enable', 'on');
    
    set(handles.pbSaveAnchors_img1, 'Enable', 'off');
    set(handles.pbSaveAnchors_img2, 'Enable', 'off');
    
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img2, 'Enable', 'on');
    
    set(handles.pbMatch_HLGraphs, 'Enable', 'on');
    
    set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
    set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0'));
    set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
    set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));
    
% end


%-------------------------------------------------------------------------
%   Synthetic Graph Matching on a real image
%-------------------------------------------------------------------------

% --- Executes on button press in pbToyProble_realImage.
function pbToyProble_realImage_Callback(hObject, ~, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    
    img2 = imread([pathname filesep filename]);

    setParameters;  
    
    % Image Pyramid
    [IP1, IP2, M] = imagePyramid_imageTr(img2, fparam, ipparam, igparam, agparam);
    

    % Show img1 on the axis1
    axes(handles.axes1);cla reset;
    plot_graph(IP1(1).img, IP1(1).LLG);
    % Show img1 on the axis3
    axes(handles.axes3);cla reset;
    plot_graph(IP1(1).img, IP1(1).LLG); 
    
    % Show img2 on the axis2
    axes(handles.axes2);cla reset;
    plot_graph(IP2(1).img, IP2(1).LLG);
    % Show img2 on the axis4
    axes(handles.axes4);cla reset;
    plot_graph(IP2(1).img, IP2(1).LLG);
    
    img3 = combine2images(IP1(1).img, IP2(1).img); % combine two images
    
    axes(handles.axes5);
    imagesc(img3), axis off;
    
    axes(handles.axes6);
    imagesc(img3), axis off;
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    % update/reset data
    handles.IP1 = IP1;
    handles.IP2 = IP2;
    handles.M = M;                         % Ground Truth 
    
    handles.img1selected= 1;
    handles.img2selected= 1;  
    
    handles.HLG1 = [];
    handles.HLG2 = [];

    handles.HLG1isBuilt = 0;
    handles.HLG2isBuilt = 0;
   
    handles.affTrafo = [];
    
    handles.IPlevel = 1;
    handles.Iteration = 1;
    handles.SummaryT = 0.0;
    
    set(handles.pbBuildGraphs_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');

    set(handles.pbBuildGraphs_img2, 'Enable', 'on');
    set(handles.pbLoadAnchors_img2, 'Enable', 'on');    
    
    set(handles.pb_makeNSteps, 'Enable', 'off');
    set(handles.pbMatch_HLGraphs, 'Enable', 'off');
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');
    
    set(handles.text_IterationCount, 'String', sprintf('Iteration: -'));
    set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0'));
    set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
    set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));
    
    guidata(hObject,handles);     
end
%end




%-------------------------------------------------------------------------
%    Panel1 : select images and extract edge points with corresponding
%    descriptors
%-------------------------------------------------------------------------

%
% Select first image
function pbSelect_img1_Callback(hObject, ~, handles)
[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    display(sprintf('First image:'));
    
    setParameters;
    
    img1 = imread([pathname filesep filename]);
    IP1 = imagePyramid(1, img1, fparam, ipparam, igparam, agparam);

    % Show LLG1 on the axis1
    axes(handles.axes1);cla reset;
    plot_graph(img1, IP1(1).LLG);
    
    % Show LLG1 on the axis3
    axes(handles.axes3);cla reset;
    plot_graph(img1, IP1(1).LLG);
    
    if handles.img2selected
        
        img3 = combine2images(img1, handles.IP2(1).img);
        
        axes(handles.axes5);
        imagesc(img3), axis off;
        
        axes(handles.axes6);
        imagesc(img3), axis off;        
    end

    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    % update/reset data
    handles.IP1 = IP1;
    handles.img1selected = 1;

    handles.affTrafo = [];
    
    handles.IPlevel = 1;
    handles.Iteration = 1;
    handles.SummaryT = 0.0;
    
    set(handles.pbBuildGraphs_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    
    set(handles.pb_makeNSteps, 'Enable', 'off');
    set(handles.pbMatch_HLGraphs, 'Enable', 'off');
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');

    set(handles.text_IterationCount, 'String', sprintf('Iteration: -'));
    set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0')); 
end
guidata(hObject,handles); 
    
%
% Select second image
function pbSelect_img2_Callback(hObject, ~, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    display(sprintf('Second image:'));
    
    setParameters;
    
    img2 = imread([pathname filesep filename]);
    IP2 = imagePyramid(2, img2, fparam, ipparam, igparam, agparam);
       
    % Show it on the axis2 and axis 4 
    axes(handles.axes2);cla reset;
    plot_graph(img2, IP2(1).LLG);
    axes(handles.axes4);cla reset;
    plot_graph(img2, IP2(1).LLG);
    
    if handles.img1selected
        
        img3 = combine2images(handles.IP1(1).img, img2);
        
        axes(handles.axes5);
        imagesc(img3), axis off;
        
        axes(handles.axes6);
        imagesc(img3), axis off;
    end
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    

    % update/reset data
    handles.IP2 = IP2;
    handles.img2selected = 1;

    handles.affTrafo = [];
       
    handles.IPlevel = 1;
    handles.Iteration = 1;
    handles.SummaryT = 0.0;
    
    set(handles.pbBuildGraphs_img2, 'Enable', 'on');
    set(handles.pbLoadAnchors_img2, 'Enable', 'on');
    
    set(handles.pb_makeNSteps, 'Enable', 'off');
    set(handles.pbMatch_HLGraphs, 'Enable', 'off');
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');

    set(handles.text_IterationCount, 'String', sprintf('Iteration: -'));
    set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0'));    
end
guidata(hObject,handles); 
%end

%-------------------------------------------------------------------------
%       Panel2 : building coarse graphs (ancor graph) and fine graphs 
%-------------------------------------------------------------------------


% --- Executes on button press in pbBuildGraphs_img1.
function pbBuildGraphs_img1_Callback(hObject, ~ , handles)

    handles.parameters.nSP1 = str2double(get(handles.edit_NAnchors1,'string')); 
    handles.parameters.nSP2 = handles.parameters.nSP1;
  
    guidata(hObject,handles); 
    
    set(handles.pbSaveAnchors_img1, 'Enable', 'off');
    set(handles.pbLoadAnchors_img1, 'Enable', 'off');
    
    axes(handles.axes3);
    imagesc(handles.img1), axis off; 
    
    % build coarse (Anchor Graph HLG) and fine (Dependency Graph LLG) graph    
    % on the first image
    LLG1 = handles.LLG1;

    
    display(sprintf('\n - build higher level graph (anchor graph)'));
    t2 = tic;
    [HLG1, U1] = HEM_coarsen_2(LLG1, handles.parameters.nSP1);
    HLG1.U  = U1;
    HLG1.F = ones(size(HLG1.V,1),1);     % flags, that show if anchors were changed in previous iteration
    display(sprintf('   finished in %f sec', toc(t2)));
    
    % plot anchor graphs
    show_LLG = get(handles.cbShow_LLG, 'Value');
    show_HLG = get(handles.cbShow_HLG, 'Value');
    cla reset;

    axes(handles.axes3); cla reset;
    plot_2levelgraphs(handles.img1, LLG1, HLG1, show_LLG, show_HLG);
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    set(handles.pbSaveAnchors_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');
    set(handles.pb_Reweight_HLGraph, 'Enable', 'off');

    set(handles.edit_nV1, 'String', size(HLG1.V,1) );    
    
    if  handles.HLG2isBuilt
        
        it = 1;
        handles.Iteration = it;
        handles.SummaryT = 0.0;
        set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
        set(handles.text_SummaryT, 'String', sprintf('Summary time: %d', handles.SummaryT));
        
        handles.HLGmatches = struct('objval', 0, 'matched_pairs', []);
        handles.LLGmatches = struct('objval', 0., 'matched_pairs', [], ...
                                    'lobjval', []);
        handles.affTrafo = [];

        axes(handles.axes5);cla reset;
        plot_HLGmatches(handles.img1, HLG1, handles.img2, handles.HLG2, handles.HLGmatches.matched_pairs, ...
                                                                        handles.HLGmatches.matched_pairs);
        axes(handles.axes6); cla reset;
        img3 = combine2images(handles.img1, handles.img2);
        imagesc(img3), axis off;

        set(handles.pb_makeNSteps, 'Enable', 'on');
        set(handles.pbMatch_HLGraphs, 'Enable', 'on');
        set(handles.pbMatch_LLGraphs, 'Enable', 'off');
        set(handles.pb_Reweight_HLGraph, 'Enable', 'off');    
        
    end
    
    % update data
    handles.HLG1 = HLG1;
    handles.LLG1 = LLG1;
    handles.HLG1isBuilt = 1;
    
    guidata(hObject,handles);     
%end


% --- Executes on button press in pbBuildGraphs_img1.
function pbBuildGraphs_img2_Callback(hObject, ~ , handles)
    handles.parameters.nSP2 = str2double(get(handles.edit_NAnchors2,'string')); 

    guidata(hObject,handles); 
    
    set(handles.pbSaveAnchors_img2, 'Enable', 'off');
    set(handles.pbLoadAnchors_img2, 'Enable', 'off');
    
    
    axes(handles.axes4);
    imagesc(handles.img2); % plot_graph(handles.img1, 'Image 1', handles.LLG1);
    
    % build coarse (Anchor Graph, HLG) and fine (Dependency Graph, LLG) graph    
%     [HLG2, LLG2] = build2LevelGraphs (handles.img2, ...
%                                       handles.features2,...
%                                       handles.parameters.nSP2); 

    LLG2 = handles.LLG2;
%     LLG2.W = ones(size(LLG2.V,1),1)*Inf;
%     LLG2.W = ones(size(LLG2.V,1),1)*NaN;
    
    display(sprintf('\n - build higher level graph (anchor graph)'));
    t2 = tic;
    [HLG2, U2] = HEM_coarsen_2(LLG2, handles.parameters.nSP2);
    HLG2.U  = U2;
    HLG2.F = ones(size(HLG2.V,1),1);     % flags, that show if anchors were changed in previous iteration                                  
    display(sprintf('   finished in %f sec', toc(t2)));
    
    
    % plot anchor graph
    show_LLG = get(handles.cbShow_LLG, 'Value');
    show_HLG = get(handles.cbShow_HLG, 'Value');
    cla reset;

    axes(handles.axes4);
    plot_2levelgraphs(handles.img2, LLG2, HLG2, show_LLG, show_HLG);
    
    set(handles.pbSaveAnchors_img2, 'Enable', 'on');
    set(handles.pbLoadAnchors_img2, 'Enable', 'on');   
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');
    set(handles.pb_Reweight_HLGraph, 'Enable', 'off');
    
    set(handles.edit_nV2, 'String', size(HLG2.V,1) );
    
    if handles.HLG1isBuilt 
        
        it = 1;
        handles.Iteration = it;
        handles.SummaryT = 0.0;
        
        set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
        set(handles.text_SummaryT, 'String', sprintf('Summary time: %d', handles.SummaryT));
       
        handles.HLGmatches = struct('objval', 0, 'matched_pairs', []);
        handles.LLGmatches = struct('objval', 0., 'matched_pairs', [], ...
                                    'lobjval', []);  
        handles.affTrafo = [];

   
        axes(handles.axes5);cla reset;
        plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, HLG2, handles.HLGmatches.matched_pairs,...
                                                                        handles.HLGmatches.matched_pairs);
        axes(handles.axes6); cla reset;
        img3 = combine2images(handles.img1, handles.img2);
        imagesc(img3), axis off;                                                                    
        
        set(handles.pb_makeNSteps, 'Enable', 'on');
        set(handles.pbMatch_HLGraphs, 'Enable', 'on');
        set(handles.pbMatch_LLGraphs, 'Enable', 'off');
        set(handles.pb_Reweight_HLGraph, 'Enable', 'off');    
    end
    
    % update data
    handles.HLG2 = HLG2;
    handles.LLG2 = LLG2;
    handles.HLG2isBuilt = 1;
    guidata(hObject,handles);  
%end


% --- Executes on button press in pbSaveAnchors_img1.
function pbSaveAnchors_img1_Callback(~, ~, handles)

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');
if  filename~=0
    HLG = handles.HLG1;
    LLG =  handles.LLG1;
    m = handles.parameters.nAnchors1;
    save([pathname filesep filename] , 'handles.parameters.nAnchors1', 'handles.HLG1', 'handles.LLG1');
end
%end

% --- Executes on button press in pbSaveAnchors_img2.
function pbSaveAnchors_img2_Callback(~, ~, handles)

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');
if  filename~=0
    m = handles.parameters.nAnchors2;
    HLG = handles.HLG2;
    LLG =  handles.LLG2;
    save([pathname filesep filename] , 'm', 'HLG', 'LLG');
end
%end

% --- Executes on button press in pbLoadAnchors_img1.
function pbLoadAnchors_img1_Callback(hObject, ~, handles)

[filename, pathname] = uigetfile({'*.mat'}, 'File Selector');

if  filename~=0
    % read data from file
    load( [pathname filesep filename] ,'-mat', 'm', 'HLG', 'LLG');                     

    set(handles.edit_NAnchors1, 'string', m);
    set(handles.edit_nV1, 'string', size(HLG.V,1));

    handles.parameters.nAnchors1 = m;
    
    handles.HLG1 = HLG;
    handles.LLG1 = LLG;
    handles.HLG1isBuilt = 1;
    
    guidata(hObject, handles);

    %replot HLG
    show_LLG = get(handles.cbShow_LLG, 'Value');
    show_HLG = get(handles.cbShow_HLG, 'Value');
    axes(handles.axes3);cla reset;
    plot_2levelgraphs(handles.img1, handles.LLG1, handles.HLG1, show_LLG, show_HLG);

    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    
    if handles.HLG2isBuilt  
             
       it = 1;
       handles.Iteration = it;
       handles.SummaryT = 0.0;
       set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
       set(handles.text_SummaryT, 'String', sprintf('Summary time: %d',handles.SummaryT));
       
       handles.HLGmatches = struct('objval', 0, 'matched_pairs', []);
       handles.LLGmatches = struct('objval', 0., 'matched_pairs', [], ...
                                    'lobjval', []); 
       handles.affTrafo = [];

       axes(handles.axes5);cla reset;
       plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, handles.HLGmatches.matched_pairs,...
                                                            handles.HLGmatches.matched_pairs);
       
       axes(handles.axes6); cla reset;
       img3 = combine2images(handles.img1, handles.img2);
       imagesc(img3), axis off;
       
       set(handles.pb_makeNSteps, 'Enable', 'on');
       set(handles.pbMatch_HLGraphs, 'Enable', 'on');
       set(handles.pbMatch_LLGraphs, 'Enable', 'off');
       set(handles.pb_Reweight_HLGraph, 'Enable', 'off');
    end

    guidata(hObject, handles);
end  
%end

% --- Executes on button press in pbLoadAnchors_img2.
function pbLoadAnchors_img2_Callback(hObject, ~, handles)
[filename, pathname] = uigetfile({'*.mat'}, 'File Selector');

if  filename~=0
    % read data from file
    load( [pathname filesep filename] ,'-mat', 'm', 'HLG', 'LLG');     

    set(handles.edit_NAnchors2, 'string', m);
    set(handles.edit_nV2, 'string', size(HLG.V,1));

    handles.parameters.nAnchors2 = m;

    handles.HLG2 = HLG;
    handles.LLG2 = LLG;
    handles.HLG2isBuilt = 1;
    
    guidata(hObject, handles);

    %replot HLG
    show_LLG = get(handles.cbShow_LLG, 'Value');
    show_HLG = get(handles.cbShow_HLG, 'Value');
    axes(handles.axes4);cla reset;
    plot_2levelgraphs(handles.img2, handles.LLG2, handles.HLG2, show_LLG, show_HLG);   

    if handles.HLG1isBuilt
       it = 1;
       handles.Iteration = it;
       handles.SummaryT = 0.0;
       set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
       set(handles.text_SummaryT, 'String', sprintf('Summary time: %d',handles.SummaryT));
       
       handles.HLGmatches = struct('objval', 0, 'matched_pairs', []);
       handles.LLGmatches = struct('objval', 0., 'matched_pairs', [], ...
                                    'lobjval', []);   
       handles.affTrafo = [];

       axes(handles.axes5);cla reset;
       plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, handles.HLGmatches.matched_pairs, ...
                                                                               handles.HLGmatches.matched_pairs);
       axes(handles.axes6); cla reset;
       img3 = combine2images(handles.img1, handles.img2);
       imagesc(img3), axis off;
       
       set(handles.pb_makeNSteps, 'Enable', 'on');
       set(handles.pbMatch_HLGraphs, 'Enable', 'on');
       set(handles.pbMatch_LLGraphs, 'Enable', 'off');
       set(handles.pb_Reweight_HLGraph, 'Enable', 'off');       
    end    

    guidata(hObject, handles);
end
%end

% --- Executes on button press in cbShow_HLG.
function cbShow_HLG_Callback(~, ~, handles)

show_LLG = get(handles.cbShow_LLG, 'Value');
show_HLG = get(handles.cbShow_HLG, 'Value');

% replot first anchor graph
if (handles.HLG1isBuilt)
    axes(handles.axes3);cla reset;
    plot_2levelgraphs(handles.img1, handles.LLG1, handles.HLG1, show_LLG, show_HLG);

end
% replot second anchor graph              
if (handles.HLG2isBuilt)
    axes(handles.axes4);cla reset;
    plot_2levelgraphs(handles.img2, handles.LLG2, handles.HLG2, show_LLG, show_HLG);
           
end


% --- Executes on button press in cbShow_LLG.
function cbShow_LLG_Callback(~, ~, handles)

show_LLG = get(handles.cbShow_LLG, 'Value');
show_HLG = get(handles.cbShow_HLG, 'Value');

% replot first anchor graph
if (handles.HLG1isBuilt)
    axes(handles.axes3);cla reset;
    plot_2levelgraphs(handles.img1, handles.LLG1, handles.HLG1, show_LLG, show_HLG);

end
% replot first second graph       
if (handles.HLG2isBuilt)
    axes(handles.axes4);cla reset;
    plot_2levelgraphs(handles.img2, handles.LLG2, handles.HLG2, show_LLG, show_HLG);

end

%-------------------------------------------------------------------------
%       Panel3 : matching Higher Level Graphs
%-------------------------------------------------------------------------

% --- Executes on button press in pbMatch_HLGraphs.
function pbMatch_HLGraphs_Callback(hObject, ~, handles)
%  We use Reweighted Random Walk Algorithm for the graph matching
%   see Minsu Cho, Jungmin Lee, and Kyoung Mu Lee   
%       "Reweighted Random Walks for Graph Matching"

display(sprintf('=================================================='));
display(sprintf('One Iteration of 2-Level GM...'));
display(sprintf('=================================================='));
    
    
fprintf('\n== Match anchor graphs');

it = handles.Iteration;  % iteration
t = tic;                 % start timer

[corrmatrix, affmatrix] = initialization_HLGM(handles.HLG1, handles.HLG2, ...
                                              handles.LLG1, handles.LLG2);
% [objval, matched_pairs] = matchHLGraphs(corrmatrix, affmatrix);
if (it==1)
    HLMatches = matchHLGraphs(corrmatrix, affmatrix);
else
    HLMatches = matchHLGraphs(corrmatrix, affmatrix, handles.HLG1, handles.HLG2, ...
                              handles.HLGmatches(it-1));
end

handles.SummaryT = handles.SummaryT + toc(t);
handles.HLGmatches(it) = HLMatches;



% plot results of the matching

axes(handles.axes3);
plot_2levelgraphs(handles.img1, handles.LLG1, handles.HLG1, false, false, handles.HLGmatches(it).matched_pairs,1);

axes(handles.axes4);
plot_2levelgraphs(handles.img2, handles.LLG2, handles.HLG2, false, false, handles.HLGmatches(it).matched_pairs,2);

axes(handles.axes5); cla reset;
plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, HLMatches.matched_pairs, ...
                                                                        handles.GT.HLpairs);
axes(handles.axes6);
plot_LLGmatches(handles.img1, handles.LLG1, handles.HLG1, ...
                handles.img2, handles.LLG2, handles.HLG2, ...
                [], ...
                handles.HLGmatches(it).matched_pairs, handles.GT.LLpairs);    

% plot score and accuracy
axes(handles.axes11); plot_score(handles.HLGmatches);
if ~isempty(handles.GT.HLpairs)  % if we know the Ground Truth fot the HL
    axes(handles.axes12); plot_accuracy(handles.HLGmatches, handles.GT.HLpairs);
end
% pb_accuracy_HL_Callback(hObject, [], handles);  % plot score

% chanche GUI
axes(handles.axes5);
set(gca,'ButtonDownFcn', {@axes5_highlight_HLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes5_highlight_HLG, handles}) 


set(handles.text_objval_HLG, 'String', sprintf('Objval: %0.3f', handles.HLGmatches(it).objval));
set(handles.text_SummaryT, 'String', sprintf('Summary time:  %0.3f', handles.SummaryT));

set(handles.pb_makeNSteps, 'Enable', 'off');
set(handles.pbMatch_HLGraphs, 'Enable', 'off');
set(handles.pbMatch_LLGraphs, 'Enable', 'on');

guidata(hObject, handles);

fprintf('\n');
%end

% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(~, ~, handles)

axes(handles.axes5);
set(gca,'ButtonDownFcn', {@axes5_highlight_HLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes5_highlight_HLG, handles}) 
    

% --- Executes on button press in pb_accuracy_LL.
function pb_accuracy_HL_Callback(~, ~, handles)
   
figure; subplot(1,2,1); plot_score(handles.HLGmatches);
% if we know the Ground Truth fot the HL
if ~isempty(handles.GT.HLpairs)
    subplot(1,2,2); plot_accuracy(handles.HLGmatches, handles.GT.HLpairs);
end
%end

% --- Executes on button press in pbSaveImg_HL.
function pbSaveImg_HL_Callback(~, ~, handles)

[filename, pathname] = uiputfile({'*.jpg'}, 'Save file name');
if  filename~=0
    img = getframe(handles.axes5);
    imwrite(img.cdata, [pathname, filesep, filename], 'Quality', 100);  
%     export_fig(handles.axes5, [pathname, filesep, filename]);
end
% end

%-------------------------------------------------------------------------
%       Panel4 : matching lower level graphs
%-------------------------------------------------------------------------

% --- Executes on button press in pbMatch_LLGraphs.
function pbMatch_LLGraphs_Callback(hObject,  ~ , handles)

fprintf('\n== Match initial graphs');

it = handles.Iteration;     % iteration
t = tic;  % Start timer

[subgraphNodes, corrmatrices, affmatrices] = initialization_LLGM(handles.LLG1, handles.LLG2, ...
                                                                 handles.HLG1.U, handles.HLG2.U,...
                                                                 handles.HLGmatches(it).matched_pairs);
% Matching
nV1 = size(handles.LLG1.V,1);  nV2 = size(handles.LLG2.V,1);
if (it==1)
    LLMatches = matchLLGraphs(nV1, nV2, subgraphNodes, corrmatrices, affmatrices, ...
                              handles.HLGmatches(it).matched_pairs);
else
    LLMatches = matchLLGraphs(nV1, nV2, subgraphNodes, corrmatrices, affmatrices, ...
                              handles.HLGmatches(it).matched_pairs, ...
                              handles.LLGmatches(it-1));
end

handles.SummaryT = handles.SummaryT + toc(t);       % Stop timer
handles.LLGmatches(it) = LLMatches;

%plotting
axes(handles.axes6); cla reset;     % plot correspondences between images
plot_LLGmatches(handles.img1, handles.LLG1, handles.HLG1, ...
                    handles.img2, handles.LLG2, handles.HLG2, ...
                    handles.LLGmatches(it).matched_pairs, ...
                    handles.HLGmatches(it).matched_pairs, handles.GT.LLpairs); 
                
                
% plot score and accuracy
axes(handles.axes13); plot_score(handles.LLGmatches);
if ~isempty(handles.GT.LLpairs)  % if we know the Ground Truth fot the HL
    axes(handles.axes14); plot_accuracy(handles.LLGmatches, handles.GT.LLpairs);
end
% pb_accuracy_LL_Callback(hObject, [], handles) 

% highlithing
axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles})   

set(handles.text_objval_LLG, 'String', sprintf('Objval:  %0.3f', LLMatches.objval));
set(handles.text_SummaryT, 'String', sprintf('Summary time:  %0.3f', handles.SummaryT));

set(handles.pbMatch_LLGraphs, 'Enable', 'off');
set(handles.pb_Reweight_HLGraph, 'Enable', 'on');

% update data
guidata(hObject, handles);

fprintf('\n');
%end


% --- Executes on mouse press over axes background.
function axes6_ButtonDownFcn(~, ~, handles)

gaxes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles})   


% --- Executes on button press in pb_accuracy_HL.
function pb_accuracy_LL_Callback(~, ~, handles)

figure; subplot(1,2,1); plot_score(handles.LLGmatches);

% if we know the Ground Truth fot the LL
if ~isempty(handles.GT.LLpairs)
    subplot(1,2,2); plot_accuracy(handles.LLGmatches, handles.GT.LLpairs);
end
%end


% --- Executes on button press in pbSaveImg_LL.
function pbSaveImg_LL_Callback(~, ~, handles)
[filename, pathname] = uiputfile({'*.jpg'}, 'Save file name');
if  filename~=0
    img = getframe(handles.axes6);
    imwrite(img.cdata, [pathname, filesep, filename], 'Quality', 100);  
%     export_fig(handles.axes5, [pathname, filesep, filename]);
end

%-------------------------------------------------------------------------
%       Panel2 : Update data for new iteration
%-------------------------------------------------------------------------

% --- Executes on button press in pb_Reweight_HLGraph.
function pb_Reweight_HLGraph_Callback(hObject, ~, handles)


fprintf('\n== Update subgraphs for the next iteration');

LLG1 = handles.LLG1; LLG2 = handles.LLG2;

HLG1_old = handles.HLG1; HLG2_old = handles.HLG2;
% 
% HLG1_old.F = ones(size(HLG1_old.V,1),1); 
% HLG2_old.F = ones(size(HLG2_old.V,1),1);

it = handles.Iteration;

t = tic;            % Start timers

% old function
% % [T, inverseT] = affine_transformation_estimation(LLG1, LLG2, HLG1_old.U, HLG2_old.U, ...
% %                                                  handles.LLGmatches(it), ...
% %                                                  handles.HLGmatches(it));
% % [HLG1, HLG2] = rearrange_subgraphs2(LLG1, LLG2, HLG1_old, HLG2_old, ...
% %                                handles.LLGmatches(it), handles.HLGmatches(it), ...
% %                                T, inverseT);
% % % -----------------------------------------------------------------------       
% % p = 1/it; % parameters of the simulated annealing
% % [HLG1, HLG2] = simulated_annealing(LLG1, LLG2, HLG1, HLG2, ...
% %                                    handles.LLGmatches(it), handles.HLGmatches(it), p);
% % % ------------------------------------------------------------------------
% % [T, inverseT] = affine_transformation_estimation(LLG1, LLG2, HLG1.U, HLG2.U, ...
% %                                                  handles.LLGmatches(it), ...
% %                                                   handles.HLGmatches(it));
% % 
% % [HLG1, HLG2] = rearrange_subgraphs2(LLG1, LLG2, HLG1, HLG2, ...
% %                                    handles.LLGmatches(it), handles.HLGmatches(it), ...
% %                                    T, inverseT);

% new function
[LLG1, LLG2, HLG1, HLG2, affTrafo] = MetropolisAlg(it, LLG1, LLG2, HLG1_old, HLG2_old,...
                                         handles.LLGmatches(it), handles.HLGmatches(it), handles.affTrafo);
handles.affTrafo = affTrafo;    

handles.SummaryT = handles.SummaryT + toc(t);             % Stop timers
it = it + 1;

handles.Iteration = it;
handles.LLG1 = LLG1; handles.LLG2 = LLG2;
handles.HLG1 = HLG1; handles.HLG2 = HLG2;
% % handles.affTrafo = affTrafo;

axes(handles.axes3);
plot_2levelgraphs(handles.img1, LLG1, HLG1, false, false, handles.HLGmatches(it-1).matched_pairs,1);

axes(handles.axes4);
plot_2levelgraphs(handles.img2, LLG2, HLG2, false, false, handles.HLGmatches(it-1).matched_pairs,2);
                                                                       
set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
set(handles.text_SummaryT, 'String', sprintf('Summary time: %0.3f', handles.SummaryT));


set(handles.pb_makeNSteps, 'Enable', 'on');
set(handles.pb_Reweight_HLGraph, 'Enable', 'off');
set(handles.pbMatch_HLGraphs, 'Enable', 'on');

guidata(hObject, handles);

fprintf('\n');
% end

%-------------------------------------------------------------------------
%       Panel2 : Algorithm control
%-------------------------------------------------------------------------


% --- Executes on button press in pb_Start.
function pb_Start_Callback(hObject, eventdata, handles)

%end



% --- Executes on button press in pb_Reset.
function pb_Reset_Callback(hObject, eventdata, handles)

%end

% --- Executes on button press in pb_makeNSteps.
function pb_makeNSteps_Callback(hObject, ~, handles)

N = str2double(get(handles.edit_NSteps,'string')); 
it = handles.Iteration;
time = handles.SummaryT;

LLG1 = handles.LLG1; LLG2 = handles.LLG2;
nV1 = size(handles.LLG1.V,1);  nV2 = size(handles.LLG2.V,1);
HLG1 = handles.HLG1; HLG2 = handles.HLG2;

% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------     
for i = 1:N
    
    display(sprintf('ITERATION %d', i));
    tic;
    % -----------------------------------------------------------------------    
    fprintf('\n== Match anchor graphs');
    % -----------------------------------------------------------------------    
    [corrmatrix, affmatrix] = initialization_HLGM(HLG1, HLG2, LLG1, LLG2);

    if (it==1)
        HLMatches = matchHLGraphs(corrmatrix, affmatrix);
    else
        HLMatches = matchHLGraphs(corrmatrix, affmatrix, HLG1, HLG2, ...
                                       handles.HLGmatches(it-1));
    end
    handles.HLGmatches(it) = HLMatches;
    
    set(handles.text_objval_HLG, 'String', sprintf('Objval:  %0.3f', HLMatches.objval));

    axes(handles.axes5); cla reset;
    plot_HLGmatches(handles.img1, handles.HLG1, ...
                    handles.img2, handles.HLG2, ....
                    handles.HLGmatches(it).matched_pairs, handles.GT.HLpairs);
    
    pb_accuracy_HL_Callback(hObject, [], handles);    
    drawnow;
    
    axes(handles.axes3);
    plot_2levelgraphs(handles.img1, LLG1, HLG1, false, false, handles.HLGmatches(it).matched_pairs,1);

    axes(handles.axes4);
    plot_2levelgraphs(handles.img2, LLG2, HLG2, false, false, handles.HLGmatches(it).matched_pairs,2);
    
    drawnow;
    % -----------------------------------------------------------------------    
    fprintf('\n== Match initial graphs');
    % -----------------------------------------------------------------------   
    [subgraphNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
                                                                     HLG1.U, HLG2.U,...
                                                                     handles.HLGmatches(it).matched_pairs);    
    if (it==1)
        LLMatches = matchLLGraphs(nV1, nV2, subgraphNodes, corrmatrices, affmatrices, handles.HLGmatches(it).matched_pairs);
    else
        LLMatches = matchLLGraphs(nV1, nV2, subgraphNodes, corrmatrices, affmatrices, ...
                                handles.HLGmatches(it).matched_pairs, ...
                                handles.LLGmatches(it-1));
    end
    handles.LLGmatches(it) = LLMatches;
    
    set(handles.text_objval_LLG, 'String', sprintf('Objval:  %0.3f', LLMatches.objval));
        
    axes(handles.axes6);
    plot_LLGmatches(handles.img1, LLG1, HLG1, ...
                handles.img2, LLG2, HLG2, ...
                LLMatches.matched_pairs, ...
                HLMatches.matched_pairs, handles.GT.LLpairs); 
    pb_accuracy_LL_Callback(hObject, [], handles);   
    
    drawnow;          
    % ----------------------------------------------------------------------- 
    fprintf('\n== Update subgraphs for the next iteration');
    % ----------------------------------------------------------------------- 

    [LLG1, LLG2, HLG1, HLG2, affTrafo] = MetropolisAlg(it, LLG1, LLG2, HLG1, HLG2,...
                                         handles.LLGmatches(it), handles.HLGmatches(it), handles.affTrafo);
    handles.affTrafo = affTrafo;    
    
% %     HLG1.F = ones(size(handles.HLG1.V,1),1); 
% %     HLG2.F = ones(size(handles.HLG2.V,1),1);
% % 
% %     [T, inverseT] = affine_transformation_estimation(LLG1, LLG2, HLG1.U, HLG2.U, ...
% %                                                      handles.LLGmatches(it), ...
% %                                                      handles.HLGmatches(it));
% %     [HLG1, HLG2] = rearrange_subgraphs2(LLG1, LLG2, HLG1, HLG2, ...
% %                                    handles.LLGmatches(it), handles.HLGmatches(it), ...
% %                                    T, inverseT);
% %     % -----------------------------------------------------------------------       
% %     p = 1/it; % parameters of the simulated annealing
% %     [HLG1, HLG2] = simulated_annealing(LLG1, LLG2, HLG1, HLG2, ...
% %                                        handles.LLGmatches(it), handles.HLGmatches(it), p);
% %     % ------------------------------------------------------------------------
% %     [T, inverseT] = affine_transformation_estimation(LLG1, LLG2, HLG1.U, HLG2.U, ...
% %                                                      handles.LLGmatches(it), ...
% %                                                       handles.HLGmatches(it));
% % 
% %     [HLG1, HLG2] = rearrange_subgraphs2(LLG1, LLG2, HLG1, HLG2, ...
% %                                        handles.LLGmatches(it), handles.HLGmatches(it), ...
% %                                        T, inverseT);
% %     % -----------------------------------------------------------------------       
    it = it + 1;
    T_it = toc;
    time = time + T_it;
    
    % -----------------------------------------------------------------------    
    axes(handles.axes3);
    plot_2levelgraphs(handles.img1, LLG1, HLG1, false, false, handles.HLGmatches(it-1).matched_pairs,1);

    axes(handles.axes4);
    plot_2levelgraphs(handles.img2, LLG2, HLG2, false, false, handles.HLGmatches(it-1).matched_pairs,2);
    
    set(handles.text_IterationCount, 'String', sprintf('Iteration: %d', it));            
    set(handles.text_SummaryT, 'String', sprintf('Summary time: %0.3f', time));
    fprintf('\n');
             
    drawnow;
    guidata(hObject, handles);
end
% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------    

handles.Iteration = it;
handles.SummaryT = time;

handles.LLG1 = LLG1; handles.LLG2 = LLG2;
handles.HLG1 = HLG1; handles.HLG2 = HLG2;

set(handles.pbMatch_LLGraphs, 'Enable', 'off');
set(handles.pb_Reweight_HLGraph, 'Enable', 'off');

axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles}) 

% update data
guidata(hObject, handles);
% end


