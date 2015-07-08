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

% Last Modified by GUIDE v2.5 29-Jun-2015 11:23:29

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

handles = setParameters(handles);

% Update handles structure 
guidata(hObject, handles);

global HLGm_score;
global LLGM_score;


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

% Additional functions
addpath(genpath('./toyProblem_realimg'));
addpath(genpath('./toyProblem'));
addpath(genpath('./HigherLevelGraph'));
addpath(genpath('./LowerLevelGraph'));
addpath(genpath('./Matching_HL'));
addpath(genpath('./Matching_LL'));
addpath(genpath('./ransac'));
addpath(genpath('./GraphCoarsening'));
addpath(genpath('./rearrange_subgraphs'));

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


%-------------------------------------------------------------------------
%   Synthetic Graph Matching
% --------------------------------------------------------------------
function mToyProblem_Callback(hObject, ~, handles)

    set(handles.pbBuildGraphs_img1, 'Enable', 'off');
    set(handles.pbBuildGraphs_img2, 'Enable', 'off');
    
    set(handles.pbSaveAnchors_img1, 'Enable', 'off');
    set(handles.pbSaveAnchors_img2, 'Enable', 'off');
    
    set(handles.pbLoadAnchors_img1, 'Enable', 'off');
    set(handles.pbLoadAnchors_img2, 'Enable', 'off');
    
    set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
    set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));
    
    
    N = 6;
    handles.img1 = repmat(ones(N,N),1,1,3);
    handles.img2 = repmat(ones(N,N),1,1,3);
    
    handles.img1selected = 0;
    handles.img2selected = 0;
    
    handles.features1.edges = [];
    handles.features2.edges = [];
    
    handles.features1.descr = [];
    handles.features2.descr = [];
       
    [LLG1, LLG2, HLG1, HLG2, GT] = make2SyntheticGraphs();
    
%     [filename, pathname] = uiputfile({'*.mat'}, 'Save file name');
%     if  filename~=0
%         save([pathname filesep filename] , 'LLG1');
%     end
    
            
    handles.HLG1 = HLG1;
    handles.HLG2 = HLG2;
    
    handles.LLG1 = LLG1;
    handles.LLG2 = LLG2;
    
    handles.HLG1isBuilt = 1;
    handles.HLG2isBuilt = 1;
    
    handles.GT = GT;                % ground truth
    
    it = 1;
    handles.Iteration = it;
    
    
    handles.HLGmatches = []; 
    handles.LLGmatches = [];

    guidata(hObject,handles); 
    
    % plot graphs
    axes(handles.axes1);
    plot_twolevelgraphs(handles.img1, LLG1, HLG1, true, false);
    
    axes(handles.axes2);
    plot_twolevelgraphs(handles.img2, LLG2, HLG2, true, false);
    
    axes(handles.axes3);
    plot_twolevelgraphs(handles.img1, LLG1, HLG1, true, true);
    
    axes(handles.axes4);
    plot_twolevelgraphs(handles.img2, LLG2, HLG2, true, true);
    
    axes(handles.axes5);cla;
    plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, HLG2, [], handles.GT.HLpairs);
                                                                
    axes(handles.axes6);cla;                                                               

    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    % 
    set(handles.pbMatch_HLGraphs, 'Enable', 'on');
    set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
    
% end


%-------------------------------------------------------------------------
%   Synthetic Graph Matching on a real image
%-------------------------------------------------------------------------

function mToyProblem_ri_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    img2 = imread([pathname filesep filename]);
    
    replotaxes(handles.axes1, img2);
    
    % Extract edge points and corresponding descriptors
    [edges, descr] = computeDenseSIFT(img2);        % edges 4xn; % descr 128xn


    zerocol_ind = all( ~any(descr), 1);
    descr(:, zerocol_ind) = []; % remove zero columns
    edges(:, zerocol_ind) = []; %  and corresponding points
    
    % create second image = affine_transformation(img1)
    [img1, features1, GT] = transform_image(img2, edges);
    

    % Show img1 on the axis1
    axes(handles.axes1);cla reset;
    imagesc(img1), axis off; 
    % Show img1 on the axis3
    axes(handles.axes3);cla reset;
    imagesc(img1), axis off; 
    
    % Show img2 on the axis2
    axes(handles.axes2);cla reset;
    imagesc(img2), axis off; 
    % Show img2 on the axis4
    axes(handles.axes4);cla reset;
    imagesc(img2), axis off; 
    
    % combine two images
    img3 = combine2images(img1, img2);
    axes(handles.axes5);
    imagesc(img3), axis off;
    
    axes(handles.axes6);
    imagesc(img3), axis off;
    
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    
    % update/reset data
    handles.img1 = img1;
    handles.img2 = img2;
    
    handles.img1isSelected= 1;
    handles.img2isSelected= 1;
    
    handles.features1.edges = features1.edges;
    handles.features1.descr = features1.descr;
    
    handles.features2.edges = edges;
    handles.features2.descr = descr;
    
    handles.HLG1 = [];
    handles.HLG2 = [];
    
    handles.LLG1 = [];
    handles.LLG2 = [];
    
    handles.HLG1isBuilt = 0;
    handles.HLG2isBuilt = 0;
    
    handles.HLGmatches = [];
    handles.LLGmatches = [];
    
    GT.LLpairs = [GT.LLpairs(:,2), GT.LLpairs(:,1)];
    handles.GT = GT;                         % Ground Truth
    
    handles.Iteration = 1;
    
    guidata(hObject,handles); 
    
    set(handles.pbBuildGraphs_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    
    set(handles.pbMatch_HLGraphs, 'Enable', 'off');
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');
    
    set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
    set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));
    
end
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
% Select first image
function pbSelect_img1_Callback(hObject, ~, handles)
[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    img1 = imread([pathname filesep filename]);
    
    replotaxes(handles.axes1, img1);
    
    % Extract edge points and corresponding descriptors
    [edges, descr] = computeDenseSIFT(img1);

    zerocol_ind = all( ~any(descr), 1);
    descr(:, zerocol_ind) = []; % remove zero columns
    edges(:, zerocol_ind) = []; %  and corresponding points

    % Show it on the axis1
    axes(handles.axes1);cla reset;
    imagesc(img1), axis off; % plot_graph(img1, 'Image 2', LLG1);
    
    % Show it on the axis3
    axes(handles.axes3);cla reset;
    imagesc(img1), axis off; % plot_graph(img1, 'Image 2', LLG1);
    
    if handles.img2selected
        img3 = combine2images(img1, handles.img2);
        axes(handles.axes5);
        imagesc(img3), axis off;
    end

    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    % update/reset data
    handles.img1 = img1;
    handles.img1selected = 1;
    handles.features1.edges = edges;
    handles.features1.descr = descr;
    
    handles.HLG1 = [];
    handles.LLG1 = [];
    handles.HLG1isBuilt = 0;
    
    handles.HLGmatches = [];
    handles.LLGmatches = [];
    handles.Iteration = 1;
    
    guidata(hObject,handles); 
    
    set(handles.pbBuildGraphs_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    
    set(handles.pbMatch_HLGraphs, 'Enable', 'off');
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');

end

%
% Select second image
function pbSelect_img2_Callback(hObject, ~, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    img2 = imread([pathname filesep filename]);
    
    replotaxes(handles.axes2, img2);

    % Extract edge points and corresponding descriptors
    [edges, descr] = computeDenseSIFT(img2);

    zerocol_ind = all( ~any(descr), 1);
    descr(:, zerocol_ind) = []; % remove zero columns
    edges(:, zerocol_ind) = [];

    % Show it on the axis2 and axis 4 
    axes(handles.axes2);cla reset;
    imagesc(img2), axis off; % plot_graph(img2, 'Image 2', LLG2);
    axes(handles.axes4);cla reset;
    imagesc(img2), axis off; %plot_graph(img2, 'Image 2', LLG2);
    
    if handles.img1selected
        img3 = combine2images(handles.img1, img2);
        axes(handles.axes5);
        imagesc(img3), axis off;
    end
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    

    % update/reset data
    handles.img2 = img2;
    handles.img2selected = 1;
    handles.features2.edges = edges;
    handles.features2.descr = descr;
    
    handles.HLG2 = [];
    handles.LLG2 = [];
    handles.HLG2isBuilt = 0;
    
    handles.HLGmatches = [];
    handles.LLGmatches = [];
    handles.Iteration = 1;
    
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

    handles.parameters.nSP1 = str2double(get(handles.edit_NAnchors1,'string')); 
    handles.parameters.nSP2 = handles.parameters.nSP1;
  
    guidata(hObject,handles); 
    
    set(handles.pbSaveAnchors_img1, 'Enable', 'off');
    set(handles.pbLoadAnchors_img1, 'Enable', 'off');
    
    axes(handles.axes3);
    imagesc(handles.img1), axis off; 
    
    % build coarse (Anchor Graph HLG) and fine (Dependency Graph LLG) graph    
    % on the first image
    [HLG1, LLG1] = buildLowHighLevelGraphs (handles.img1, ...
                                                  handles.features1,...
                                                  handles.parameters.nSP1);  
    % build coarse (Anchor Graph HLG) and fine (Dependency Graph LLG) graph    
    % on the second image 
    [HLG2, LLG2] = buildLowHighLevelGraphs (handles.img2, ...
                                                    handles.features2,...
                                                    handles.parameters.nSP2);  
                                              
    % plot anchor graphs
    show_LLG = get(handles.cbShow_LLG, 'Value');
    show_HLG = get(handles.cbShow_HLG, 'Value');
    cla reset;

    axes(handles.axes3);
    plot_twolevelgraphs(handles.img1, LLG1, HLG1, show_LLG, show_HLG);

    axes(handles.axes4);
    plot_twolevelgraphs(handles.img2, LLG2, HLG2, show_LLG, show_HLG);
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    set(handles.pbSaveAnchors_img1, 'Enable', 'on');
    set(handles.pbLoadAnchors_img1, 'Enable', 'on');
    
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');
    set(handles.pb_Reweight_HLGraph, 'Enable', 'off');

    set(handles.edit_nV1, 'String', size(HLG1.V,1) );    
    set(handles.edit_nV2, 'String', size(HLG2.V,1) );
    
    
    % preparation for the HL graph matching
%     [corrmatrix, affmatrix] = initialization_HLGM(HLG1, HLG2);
        
    it = 1;
    handles.Iteration = it;
    set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
       
    handles.HLGmatches = [];
%     handles.HLGmatches(it).corrmatrix = corrmatrix;
%     handles.HLGmatches(it).affmatrix = affmatrix;

    handles.HLGmatches(it).objval  = 0.;
    handles.HLGmatches(it).matched_pairs = [];

    axes(handles.axes5);cla reset;
    plot_HLGmatches(handles.img1, HLG1, handles.img2, HLG2, handles.HLGmatches.matched_pairs, ...
                                                            handles.HLGmatches.matched_pairs);
    axes(handles.axes6); cla reset;
    img3 = combine2images(handles.img1, handles.img2);
    imagesc(img3), axis off;

    handles.LLGmatches = [];

    set(handles.pbMatch_HLGraphs, 'Enable', 'on');
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');
    set(handles.pb_Reweight_HLGraph, 'Enable', 'off');    
    
    % update data
    handles.HLG1 = HLG1;
    handles.LLG1 = LLG1;
    handles.HLG1isBuilt = 1;
    
    handles.HLG2 = HLG2;
    handles.LLG2 = LLG2;
    handles.HLG2isBuilt = 1;
    
    guidata(hObject,handles); 
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
    [HLG2, LLG2] = buildLowHighLevelGraphs (handles.img2, ...
                                            handles.features2,...
                                            handles.parameters.nSP2);  
    
    % plot anchor graph
    show_LLG = get(handles.cbShow_LLG, 'Value');
    show_HLG = get(handles.cbShow_HLG, 'Value');
    cla reset;

    axes(handles.axes4);
    plot_twolevelgraphs(handles.img2, LLG2, HLG2, show_LLG, show_HLG);
    
    set(handles.pbSaveAnchors_img2, 'Enable', 'on');
    set(handles.pbLoadAnchors_img2, 'Enable', 'on');   
    set(handles.pbMatch_LLGraphs, 'Enable', 'off');
    set(handles.pb_Reweight_HLGraph, 'Enable', 'off');
    
    set(handles.edit_nV2, 'String', size(HLG2.V,1) );
    
    if handles.HLG1isBuilt 
        
%         [corrmatrix, affmatrix] = initialization_HLGM(handles.HLG1, HLG2);
        
        it = 1;
        handles.Iteration = it;
        set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
       
        handles.HLGmatches = [];
%         handles.HLGmatches(it).corrmatrix = corrmatrix;
%         handles.HLGmatches(it).affmatrix = affmatrix;
        
        handles.HLGmatches(it).objval  = 0.;
        handles.HLGmatches(it).matched_pairs = [];
   
        axes(handles.axes5);cla reset;
        plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, HLG2, handles.HLGmatches.matched_pairs,...
                                                                        handles.HLGmatches.matched_pairs);
        axes(handles.axes6); cla reset;
        img3 = combine2images(handles.img1, handles.img2);
        imagesc(img3), axis off;                                                                    
        
        handles.LLGmatches = [];
        
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
function pbSaveAnchors_img1_Callback(hObject, ~, handles)

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');

HLG = handles.HLG1;
LLG =  handles.LLG1;

m = handles.parameters.nAnchors1;

if  filename~=0
    save([pathname filesep filename] , 'm', 'HLG', 'LLG');
end
%end

% --- Executes on button press in pbSaveAnchors_img2.
function pbSaveAnchors_img2_Callback(hObject, ~, handles)

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');

m = handles.parameters.nAnchors2;
HLG = handles.HLG2;
LLG =  handles.LLG2;

if  filename~=0
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
    plot_twolevelgraphs(handles.img1, handles.LLG1, handles.HLG1, show_LLG, show_HLG);

    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    
    if handles.HLG2isBuilt  
        
%        [corrmatrix, affmatrix] = initialization_HLGM(handles.HLG1, handles.HLG2);
       
       it = 1;
       handles.Iteration = it;
       set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
       
       handles.HLGmatches = [];
       
       handles.HLGmatches(it).corrmatrix = corrmatrix;
       handles.HLGmatches(it).affmatrix = affmatrix;

       handles.HLGmatches(it).objval  = 0.;
       handles.HLGmatches(it).matched_pairs = [];

       axes(handles.axes5);cla reset;
       plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, handles.HLGmatches.matched_pairs,...
                                                            handles.HLGmatches.matched_pairs);
       
       axes(handles.axes6); cla reset;
       img3 = combine2images(handles.img1, handles.img2);
       imagesc(img3), axis off;

       handles.LLGmatches = [];
       
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
    plot_twolevelgraphs(handles.img2, handles.LLG2, handles.HLG2, show_LLG, show_HLG);   

    if handles.HLG1isBuilt

%        [corrmatrix, affmatrix] = initialization_HLGM(handles.HLG1, handles.HLG2);

       it = 1;
       handles.Iteration = it;
       set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));
       
       handles.HLGmatches = [];
       handles.HLGmatches(it).corrmatrix = corrmatrix;
       handles.HLGmatches(it).affmatrix = affmatrix;

       handles.HLGmatches(it).objval  = 0.;
       handles.HLGmatches(it).matched_pairs = [];

       axes(handles.axes5);cla reset;
       plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, handles.HLGmatches.matched_pairs, ...
                                                                               handles.HLGmatches.matched_pairs);
       axes(handles.axes6); cla reset;
       img3 = combine2images(handles.img1, handles.img2);
       imagesc(img3), axis off;

       handles.LLGmatches = [];
       
       set(handles.pbMatch_HLGraphs, 'Enable', 'on');
       set(handles.pbMatch_LLGraphs, 'Enable', 'off');
       set(handles.pb_Reweight_HLGraph, 'Enable', 'off');       
    end    

    guidata(hObject, handles);
end
%end

% --- Executes on button press in cbShow_HLG.
function cbShow_HLG_Callback(hObject, ~, handles)

show_LLG = get(handles.cbShow_LLG, 'Value');
show_HLG = get(handles.cbShow_HLG, 'Value');

% replot first anchor graph
if (handles.HLG1isBuilt)
    axes(handles.axes3);cla reset;
    plot_twolevelgraphs(handles.img1, handles.LLG1, handles.HLG1, show_LLG, show_HLG);

end
% replot second anchor graph              
if (handles.HLG2isBuilt)
    axes(handles.axes4);cla reset;
    plot_twolevelgraphs(handles.img2, handles.LLG2, handles.HLG2, show_LLG, show_HLG);
           
end


% --- Executes on button press in cbShow_LLG.
function cbShow_LLG_Callback(hObject, ~, handles)

show_LLG = get(handles.cbShow_LLG, 'Value');
show_HLG = get(handles.cbShow_HLG, 'Value');

% replot first anchor graph
if (handles.HLG1isBuilt)
    axes(handles.axes3);cla reset;
    plot_twolevelgraphs(handles.img1, handles.LLG1, handles.HLG1, show_LLG, show_HLG);

end
% replot first second graph       
if (handles.HLG2isBuilt)
    axes(handles.axes4);cla reset;
    plot_twolevelgraphs(handles.img2, handles.LLG2, handles.HLG2, show_LLG, show_HLG);

end

%-------------------------------------------------------------------------
%       Panel3 : matching Higher Level Graphs
%-------------------------------------------------------------------------

% --- Executes on button press in pbMatch_HLGraphs.
function pbMatch_HLGraphs_Callback(hObject, ~, handles)
%  We use Reweighted Random Walk Algorithm for the graph matching
%   see Minsu Cho, Jungmin Lee, and Kyoung Mu Lee   
%       "Reweighted Random Walks for Graph Matching"

it = handles.Iteration;                         % iterations

[corrmatrix, affmatrix] = initialization_HLGM(handles.HLG1, handles.HLG2, ...
                                              handles.LLG1, handles.LLG2);

% corrmatrix = handles.HLGmatches.corrmatrix;     % corrmatrix
% affmatrix = handles.HLGmatches(it).affmatrix;       % affmatrix

[objval, matched_pairs] = matchHLGraphs(corrmatrix, affmatrix);

axes(handles.axes5); cla reset;
if (it==1)
%     plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, matched_pairs, ...
%                                                                             matched_pairs);
    plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, matched_pairs, ...
                                                                            handles.GT.HLpairs);
else
    plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, matched_pairs, ...
                                                                            handles.GT.HLpairs);
%     plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, matched_pairs, ...
%                                                                             handles.HLGmatches(it-1).matched_pairs);
end

set(handles.pbMatch_LLGraphs, 'Enable', 'on');
set(handles.pb_Reweight_HLGraph, 'Enable', 'off');
set(handles.text_objval_HLG, 'String', sprintf('Objval: %0.3f', objval));

%update data

global HLGM_score;
tmp = HLGM_score;
tmp = [tmp, objval];
HLGM_score = tmp;

handles.HLGmatches(it).objval = objval;
handles.HLGmatches(it).matched_pairs = matched_pairs;
handles.HLGmatches(it).corrmatrix = corrmatrix;
handles.HLGmatches(it).affmatrix = affmatrix;

handles.LLGmatches(it).objval = 0;

if (~exist('handles.LLGmatches(it).matched_pairs', 'var'))
    handles.LLGmatches(it).matched_pairs = [];
end

guidata(hObject, handles);

% plot results of the matching
axes(handles.axes6);
if (it==1)
    plot_LLGmatches(handles.img1, handles.LLG1, handles.HLG1, ...
                    handles.img2, handles.LLG2, handles.HLG2, ...
                    handles.LLGmatches(it).matched_pairs, ...
                    handles.HLGmatches(it).matched_pairs, handles.GT.LLpairs);    
%     plot_LLGmatches(handles.img1, handles.LLG1, handles.img2, handles.LLG2, [], handles.LLGmatches(it).matched_pairs, ...
%                                                                                 handles.LLGmatches(it).matched_pairs);
end

axes(handles.axes3);
plot_twolevelgraphs(handles.img1, handles.LLG1, handles.HLG1, false, false, handles.HLGmatches(it).matched_pairs,1);

axes(handles.axes4);
plot_twolevelgraphs(handles.img2, handles.LLG2, handles.HLG2, false, false, handles.HLGmatches(it).matched_pairs,2);

% plot score
pb_accuracy_HL_Callback(hObject, [], handles);


axes(handles.axes5);
set(gca,'ButtonDownFcn', {@axes5_highlight_HLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes5_highlight_HLG, handles}) 
%end

% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, ~, handles)

axes(handles.axes5);
set(gca,'ButtonDownFcn', {@axes5_highlight_HLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes5_highlight_HLG, handles}) 
    

% --- Executes on button press in pb_accuracy_LL.
function pb_accuracy_HL_Callback(hObject, ~, handles)
nIt = size(handles.LLGmatches,2);

x = 1:1:nIt;
y_obj = zeros(1, nIt);
for i=1:1:nIt
    y_obj(i) = handles.HLGmatches(i).objval;
end

axes(handles.axes11);% figure; subplot(1,2,1); 
plot(x, y_obj), hold on; plot(x,y_obj, 'bo'), hold off;
xlabel('Iteration'); ylabel('Score');set(gca,'FontSize',6);
% title('          Matching result on the Higher Level');
set(legend('Score'), 'Location', 'best', 'FontSize', 6);

% if we knew the Ground Truth for the HL
if ~isempty(handles.GT.HLpairs)
    GT = handles.GT.HLpairs;
    y_ac = zeros(1, nIt);
    for i=1:1:nIt
        TP = ismember(handles.HLGmatches(i).matched_pairs(:,1:2), GT, 'rows');
        TP = sum(TP(:));
        y_ac(i) = TP/ size(handles.HLGmatches(i).matched_pairs,1)*100;
    end
    
    axes(handles.axes12);%subplot(1,2,2);
    plot(x, y_ac), hold on; plot(x,y_ac, 'bo'), hold off;
    xlabel('Iteration'); ylabel('Accurasy');set(gca,'FontSize',6);
    set(legend('Accurasy'), 'Location', 'best', 'FontSize', 6);
end
%end

%-------------------------------------------------------------------------
%       Panel4 : matching lower level graphs
%-------------------------------------------------------------------------

% --- Executes on button press in pbMatch_LLGraphs.
function pbMatch_LLGraphs_Callback(hObject,  ~ , handles)

it = handles.Iteration;

if (it == 1) % first iteration
    [subgraphsNodes, corrmatrices, affmatrices] = initialization_LLGM(handles.LLG1, handles.LLG2, ...
                                                                      handles.HLG1.U, handles.HLG2.U,...
                                                                      handles.HLGmatches(it).matched_pairs);
else
    [subgraphsNodes, corrmatrices, affmatrices] = initialization_LLGM(handles.LLG1, handles.LLG2,...
                                                                      handles.HLG1.U, handles.HLG2.U, ...
                                                                      handles.HLGmatches(it).matched_pairs,...
                                                                      handles.HLGmatches(it-1).matched_pairs, ...
                                                                      handles.LLGmatches(it-1));
end

% if isfield(handles.LLGmatches(it), 'aftr_sim') 
%     nV1 = size(handles.LLG1.V,1);
%     nV2 = size(handles.LLG2.V,1);
%     affmatrices = add_affine_transformation_similarity(nV1, nV2, subgraphsNodes, affmatrices, ...
%                                                        handles.HLGmatches(it).matched_pairs, ...
%                                                        handles.HLGmatches(it-1).matched_pairs, ...
%                                                        handles.LLGmatches(it).aftr_sim); 
% end

% [filename, pathname] = uiputfile({'*.mat'}, 'Save file name');
% if  filename~=0
%     save([pathname filesep filename] , 'subgraphsNodes', 'corrmatrices', 'affmatrices');
% end

% [filename, pathname] = uigetfile({'*.mat'}, 'File Selector');
% load( [pathname filesep filename] ,'-mat', 'subgraphsNodes', 'corrmatrices', 'affmatrices');  

% [objval, matches] = matchLLGraphs(handles.LLG1, handles.LLG2, ...
%                                  handles.HLGmatches.matches);

% Reweighting by the HLGraph matching
% affmatrices = reweight_LLGraph(LLG1, LLG2, affmatrices, handles.HLGmatches(it));

% Matching
nV1 = size(handles.LLG1.V,1);
nV2 = size(handles.LLG2.V,1);
[objval, matched_pairs, ...
 lobjval, lweights] = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices);

% Update data

global LLGM_score;
tmp = LLGM_score;
tmp = [tmp, objval];
LLGM_score = tmp;

handles.LLGmatches(it).objval = objval;
handles.LLGmatches(it).matched_pairs = matched_pairs;

handles.LLGmatches(it).lobjval = lobjval;
handles.LLGmatches(it).lweights = lweights;
handles.LLGmatches(it).subgraphsNodes = subgraphsNodes;
handles.LLGmatches(it).corrmatrices = corrmatrices;
handles.LLGmatches(it).affmatrices  = affmatrices;

guidata(hObject, handles);


set(handles.text_objval_LLG, 'String', sprintf('Objval:  %0.3f', objval));
set(handles.pb_Reweight_HLGraph, 'Enable', 'on');

%plotting
axes(handles.axes6); cla reset;
if (it==1)
    plot_LLGmatches(handles.img1, handles.LLG1, handles.HLG1, ...
                    handles.img2, handles.LLG2, handles.HLG2, ...
                    handles.LLGmatches(it).matched_pairs, ...
                    handles.HLGmatches(it).matched_pairs, ...
                                                                                handles.GT.LLpairs); 
%     plot_LLGmatches(handles.img1, handles.LLG1, handles.img2, handles.LLG2, [], handles.LLGmatches(it).matched_pairs, ...
%                                                                                 handles.LLGmatches(it).matched_pairs);
else
    plot_LLGmatches(handles.img1, handles.LLG1, handles.HLG1, ...
                    handles.img2, handles.LLG2, handles.HLG2, ...  
                    handles.LLGmatches(it).matched_pairs, ...
                    handles.HLGmatches(it).matched_pairs, ...
                                                                                handles.GT.LLpairs);     
%     plot_LLGmatches(handles.img1, handles.LLG1, handles.img2, handles.LLG2, [], handles.LLGmatches(it).matched_pairs, ...
%                                                                                 handles.LLGmatches(it-1).matched_pairs);
end


% plot score and accuracy
pb_accuracy_LL_Callback(hObject, [], handles)

% highlithin
axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles})   
%end


% --- Executes on mouse press over axes background.
function axes6_ButtonDownFcn(hObject, ~, handles)

gaxes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles})   


% --- Executes on button press in pb_Reweight_HLGraph.
function pb_Reweight_HLGraph_Callback(hObject, ~, handles)

LLG1 = handles.LLG1;
LLG2 = handles.LLG2;

HLG1 = handles.HLG1;
HLG2 = handles.HLG2;


it = handles.Iteration;

% -----------------------------------------------------------------------
% estimated affine transformation for each subgraph given matches 
% [T, inverseT] = affine_transformation_estimation(LLG1, LLG2, HLG1.U, HLG2.U, ...
%                                                  handles.LLGmatches(it), ...
%                                                   handles.HLGmatches(it));
% 
% [HLG1, HLG2] = rearrange_subgraphs2(LLG1, LLG2, HLG1, HLG2, ...
%                                    handles.LLGmatches(it), handles.HLGmatches(it), ...
%                                    T, inverseT);
% -----------------------------------------------------------------------


% -----------------------------------------------------------------------                               
% Simulated annealing                               
% -----------------------------------------------------------------------          
% parameters of the simulated annealing
p = 10;
p = p*(0.95^(it-1));
kB = 1; %1.3865 * 10^(-23);       % Bolzmann's constant    

[HLG1, HLG2] = simulated_annealing(LLG1, LLG2, HLG1, HLG2, ...
                                   handles.LLGmatches(it), handles.HLGmatches(it), p);
% ------------------------------------------------------------------------


% -----------------------------------------------------------------------
% estimated affine transformation for each subgraph given matches 
[T, inverseT] = affine_transformation_estimation(LLG1, LLG2, HLG1.U, HLG2.U, ...
                                                 handles.LLGmatches(it), ...
                                                  handles.HLGmatches(it));

[HLG1, HLG2] = rearrange_subgraphs2(LLG1, LLG2, HLG1, HLG2, ...
                                   handles.LLGmatches(it), handles.HLGmatches(it), ...
                                   T, inverseT);
% -----------------------------------------------------------------------



% use old graphs!                                
% [aftr_sim_HL, aftr_sim_LL] = affine_transformation_similarity(LLG1, LLG2, HLG1, HLG2, ...
%                                                               handles.LLGmatches(it).matched_pairs, ...
%                                                               handles.HLGmatches(it).matched_pairs, ...
%                                                               T, handles.GT);    
                                                          
% new_affmatrix_HLG = reweight_HLGraph(LLG1, LLG2, handles.LLGmatches(it), handles.HLGmatches(it), gamma);

% [LLG1, LLG2, LL_matches] = force1to1matching(LLG1, LLG2, handles.LLGmatches(it).matched_pairs, ...
%                                              handles.HLGmatches(it).matched_pairs, T, handles.GT.LLpairs);

    

% gamma = 0.3;
% [LLG1, LLG2, HLG1, HLG2] = rebuild_HLGraph(LLG1, LLG2, HLG1, HLG2, ...
%                                            handles.LLGmatches(it),...
%                                            handles.HLGmatches(it), handles.GT, T, inverseT, gamma);


% update affmatrix for the HLGM
% [~, new_affmatrix_HLG] = initialization_HLGM(HLG1, HLG2); %, aftr_sim_HL);

it = it + 1;
handles.Iteration = it;

% handles.HLGmatches(it).affmatrix = new_affmatrix_HLG;
% handles.LLGmatches(it).aftr_sim = aftr_sim_LL;

handles.LLG1 = LLG1;
handles.LLG2 = LLG2;
handles.HLG1 = HLG1;
handles.HLG2 = HLG2;

axes(handles.axes3);
plot_twolevelgraphs(handles.img1, LLG1, HLG1, false, false, handles.HLGmatches(it-1).matched_pairs,1);

axes(handles.axes4);
plot_twolevelgraphs(handles.img2, LLG2, HLG2, false, false, handles.HLGmatches(it-1).matched_pairs,2);

% axes(handles.axes5);cla;
% plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, HLG2, handles.HLGmatches(it).matched_pairs,...
%                                                                 handles.GT.HLpairs);
                                                                        

set(handles.text_IterationCount, 'String', sprintf('Iteration: %d',handles.Iteration));

set(handles.pbMatch_LLGraphs, 'Enable', 'off');
set(handles.pb_Reweight_HLGraph, 'Enable', 'off');

guidata(hObject, handles);
% end



% --- Executes on button press in pb_accuracy_HL.
function pb_accuracy_LL_Callback(hObject, ~, handles)
nIt = size(handles.LLGmatches,2);

x = 1:1:nIt;
y_obj = zeros(1, nIt);
for i=1:1:nIt
    y_obj(i) = handles.LLGmatches(i).objval;
end

%figure; subplot(1,2,1);
axes(handles.axes13);
plot(x, y_obj), hold on; plot(x,y_obj, 'bo'), hold off;
xlabel('Iteration'); ylabel('Score');set(gca,'FontSize',6);
set(legend('Score'), 'Location', 'best', 'FontSize', 6);

% if we know the Ground Truth fot the LL
if ~isempty(handles.GT.LLpairs)
    GT = handles.GT.LLpairs;
    y_ac = zeros(1, nIt);
    for i=1:1:nIt
        TP = ismember(handles.LLGmatches(i).matched_pairs(:,1:2), GT, 'rows');
        TP = sum(TP(:));
        y_ac(i) = TP/ size(handles.LLGmatches(i).matched_pairs,1) * 100;
    end
    
    axes(handles.axes14); %subplot(1,2,1);
    plot(x, y_ac), hold on; plot(x,y_ac, 'bo'), hold off;
    xlabel('Iteration'); ylabel('Accurasy'); set(gca,'FontSize',6)
    set(legend('Accurasy'), 'Location', 'best', 'FontSize', 6);
end
%end
