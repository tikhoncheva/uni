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

% Last Modified by GUIDE v2.5 04-Aug-2015 16:26:42

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
clc; 

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
% addpath(genpath('./rearrange_subgraphs'));
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
    
    HLG1 = buildHLGraph(1, LLG1, agparam);
    HLG2 = buildHLGraph(2, LLG2, agparam);

    IP1 = struct('img', img1, 'LLG', LLG1, 'HLG', HLG1);
    IP2 = struct('img', img2, 'LLG', LLG2, 'HLG', HLG2);
    
    HLGmatches = struct('objval', 0, 'matched_pairs', []);
    LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);                      

    M = struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, 'GT', GT);
    L = size(IP1,1);        % current level of the pyramid
    
    % plot graphs
    axes(handles.axes1); plot_graph(IP1(L).img, IP1(L).LLG);
    axes(handles.axes2); plot_graph(IP2(L).img, IP2(L).LLG);
    
    axes(handles.axes3); plot_2levelgraphs(IP1(L).img, IP1(L).LLG, ...
                                           IP1(L).HLG, false, false);
    axes(handles.axes4); plot_2levelgraphs(IP2(L).img, IP2(L).LLG, ...
                                           IP2(L).HLG, false, false);
    
    axes(handles.axes5); cla reset
    plot_HLGmatches(handles.IP1(L).img, handles.IP1(L).HLG, ...
                handles.IP2(L).img, handles.IP2(L).HLG, ...
                M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);
    
    
    img3 = combine2images(IP1(L).img, IP2(L).img); % combine two images        
    axes(handles.axes6); cla reset; imagesc(img3), axis off;
    
        
    % update dta    
    handles.IP1 = IP1;
    handles.IP2 = IP2;
    
    handles.M = M;
    
    handles.img1selected = 0;
    handles.img2selected = 0;
    
    handles.IPlevel = L;
    handles.SummaryT = 0.0;     
                                                                                                                        
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    set(handles.pb_start, 'Enable', 'on');
    set(handles.pb_reset, 'Enable', 'on');
    set(handles.pb_makeNSteps, 'Enable', 'on');

    set(handles.text_IPlevel, 'String', sprintf('Level: %d',handles.IPlevel));
    set(handles.text_IterationCount, 'String', sprintf('Iteration: -'));
    set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0')); 
    set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
    set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));

guidata(hObject,handles);     
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
    L = size(IP1,1);        % current level of the pyramid

    % Show img1 on the axis1
    axes(handles.axes1);cla reset; plot_graph(IP1(1).img, IP1(1).LLG);
    % Show img2 on the axis2
    axes(handles.axes2);cla reset; plot_graph(IP2(1).img, IP2(1).LLG);   
    % Show img2 on the axis3
    axes(handles.axes3); plot_2levelgraphs(IP1(L).img, IP1(L).LLG, ...
                                           IP1(L).HLG, false, false);
    % Show img2 on the axis4
    axes(handles.axes4); plot_2levelgraphs(IP2(L).img, IP2(L).LLG, ...
                                           IP2(L).HLG, false, false);
                                       
    
    axes(handles.axes5);
    plot_HLGmatches(IP1(L).img, IP1(L).HLG, ...
                    IP2(L).img, IP2(L).HLG, ...
                    M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);
    
    img3 = combine2images(IP1(L).img, IP2(L).img); % combine two images                
    axes(handles.axes6);  imagesc(img3), axis off;
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    % update/reset data
    handles.IP1 = IP1;
    handles.IP2 = IP2;
    
    handles.M = M;                         % Ground Truth 
    
    handles.IPlevel = L;
    handles.SummaryT = 0.0;
    
    handles.img1selected= 1;
    handles.img2selected= 1;  

    set(handles.pb_start, 'Enable', 'on');
    set(handles.pb_reset, 'Enable', 'on');
    set(handles.pb_makeNSteps, 'Enable', 'on');

    set(handles.text_IPlevel, 'String', sprintf('Level: %d',handles.IPlevel));
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
    [IP1, M] = imagePyramid(1, img1, fparam, ipparam, igparam, agparam);

    L = size(IP1,1);
    
    % Show LLG1 on the axis1
    axes(handles.axes1);cla reset; plot_graph(img1, IP1(1).LLG);
    
    % Show LLG1 on the axis3
    axes(handles.axes3); plot_2levelgraphs(IP1(L).img, IP1(L).LLG, ...
                                           IP1(L).HLG, false, false);
    
    if handles.img2selected
        img3 = combine2images(IP1(L).img, handles.IP2(L).img);
        
        axes(handles.axes5);
        plot_HLGmatches(handles.IP1(L).img, handles.IP1(L).HLG, ...
                        handles.IP2(L).img, handles.IP2(L).HLG, ...
                        M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);
        
        axes(handles.axes6);
        imagesc(img3), axis off;  
        
        handles.IPlevel = L;
        handles.SummaryT = 0.0;
        
        set(handles.pb_start, 'Enable', 'on');
        set(handles.pb_reset, 'Enable', 'on');
        set(handles.pb_makeNSteps, 'Enable', 'on');

        set(handles.text_IPlevel, 'String', sprintf('Level: %d',handles.IPlevel));
        set(handles.text_IterationCount, 'String', sprintf('Iteration: -'));
        set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0')); 
        set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
        set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));
        
    end

    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    % update/reset data
    handles.IP1 = IP1;
    handles.img1selected = 1;

    handles.M = M;
    
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
    [IP2, M] = imagePyramid(2, img2, fparam, ipparam, igparam, agparam);
    L = size(IP2,1);    % current level of the pyramid
    
    % Show it on the axis2 and axis 4 
    axes(handles.axes2);cla reset;  plot_graph(IP2(1).img, IP2(1).LLG);
    axes(handles.axes4); plot_2levelgraphs(IP2(L).img, IP2(L).LLG, ...
                                           IP2(L).HLG, false, false);
    
    if handles.img1selected
        img3 = combine2images(handles.IP1(L).img, IP2(L).img);
        
        axes(handles.axes5);cla reset;
        plot_HLGmatches(handles.IP1(L).img, handles.IP1(L).HLG, ...
                        handles.IP2(L).img, handles.IP2(L).HLG, ...
                        M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);
        axes(handles.axes6);
        imagesc(img3), axis off;
        
        handles.IPlevel = L;
        handles.SummaryT = 0.0;
        
        set(handles.pb_start, 'Enable', 'on');
        set(handles.pb_reset, 'Enable', 'on');
        set(handles.pb_makeNSteps, 'Enable', 'on');

        set(handles.text_IPlevel, 'String', sprintf('Level: %d',handles.IPlevel));
        set(handles.text_IterationCount, 'String', sprintf('Iteration: -'));
        set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0')); 
        set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
        set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));
    
    end
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    

    % update/reset data
    handles.IP2 = IP2;
    handles.img2selected = 1;

    handles.M = M;

end
guidata(hObject,handles); 
%end

%-------------------------------------------------------------------------
%       Panel2 : building coarse graphs (ancor graph) and fine graphs 
%-------------------------------------------------------------------------


% --- Executes on button press in cbShow_HLG.
function cbShow_HLG_Callback(~, ~, handles)

show_LLG = get(handles.cbShow_LLG, 'Value');
show_HLG = get(handles.cbShow_HLG, 'Value');

L = handles.IPlevel;
% replot first anchor graph
axes(handles.axes3);cla reset;
plot_2levelgraphs(handles.IP1(L).img, handles.IP1(L).LLG, ...
                                          handles.IP1(L).HLG, show_LLG, show_HLG);
% replot second anchor graph              
axes(handles.axes4);cla reset;
plot_2levelgraphs(handles.IP2(L).img, handles.IP2(L).LLG, ...
                                          handles.IP2(L).HLG, show_LLG, show_HLG);
%end


% --- Executes on button press in cbShow_LLG.
function cbShow_LLG_Callback(~, ~, handles)

show_LLG = get(handles.cbShow_LLG, 'Value');
show_HLG = get(handles.cbShow_HLG, 'Value');

L = handles.IPlevel;
% replot first anchor graph
axes(handles.axes3);cla reset;
plot_2levelgraphs(handles.IP1(L).img, handles.IP1(L).LLG, ...
                                          handles.IP1(L).HLG, show_LLG, show_HLG);
% replot second anchor graph              
axes(handles.axes4);cla reset;
plot_2levelgraphs(handles.IP2(L).img, handles.IP2(L).LLG, ...
                                          handles.IP2(L).HLG, show_LLG, show_HLG);
%end

%-------------------------------------------------------------------------
%       Panel3 : matching Higher Level Graphs
%-------------------------------------------------------------------------

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

%-------------------------------------------------------------------------
%       Panel2 : Algorithm control
%-------------------------------------------------------------------------


% --- Executes on button press in pb_start.
function pb_start_Callback(hObject, eventdata, handles)

%end



% --- Executes on button press in pb_reset.
function pb_reset_Callback(hObject, eventdata, handles)

%end

% --- Executes on button press in pb_makeNSteps.
function pb_makeNSteps_Callback(hObject, ~, handles)

N = str2double(get(handles.edit_NSteps,'string')); 
time = handles.SummaryT;

L = handles.IPlevel;

img1 = handles.IP1(L).img;
img2 = handles.IP2(L).img;

LLG1 = handles.IP1(L).LLG;  nV1 = size(LLG1.V,1);
LLG2 = handles.IP2(L).LLG;  nV2 = size(LLG2.V,1);

HLG1 = handles.IP1(L).HLG;
HLG2 = handles.IP2(L).HLG;

LLGmatches = handles.M(L).LLGmatches;
HLGmatches = handles.M(L).HLGmatches;

GT = handles.M(L).GT;

it = handles.M(L).it;

affTrafo = handles.M(L).affTrafo;

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
        HLMatches = matchHLGraphs(corrmatrix, affmatrix, HLG1, HLG2, HLGmatches(it-1));
    end
    HLGmatches(it) = HLMatches;
    
    set(handles.text_objval_HLG, 'String', sprintf('Objval:  %0.3f', HLMatches.objval));

    axes(handles.axes5); cla reset;
    plot_HLGmatches(img1, HLG1, img2, HLG2, HLGmatches(it).matched_pairs, GT.HLpairs);
    
    % plot score and accuracy
    axes(handles.axes11); plot_score(HLGmatches);
    if ~isempty(GT.HLpairs)  % if we know the Ground Truth fot the HL
        axes(handles.axes12); plot_accuracy(HLGmatches, GT.HLpairs);
    end  
    drawnow;
    
    axes(handles.axes3);
    plot_2levelgraphs(img1, LLG1, HLG1, false, false, HLGmatches(it).matched_pairs,1);

    axes(handles.axes4);
    plot_2levelgraphs(img2, LLG2, HLG2, false, false, HLGmatches(it).matched_pairs,2);
    
    drawnow;
    % -----------------------------------------------------------------------    
    fprintf('\n== Match initial graphs');
    % -----------------------------------------------------------------------   
    [subgraphNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
                                                                     HLG1.U, HLG2.U,...
                                                                     HLGmatches(it).matched_pairs);    
    if (it==1)
        LLMatches = matchLLGraphs(nV1, nV2, subgraphNodes, corrmatrices, affmatrices, HLGmatches(it).matched_pairs);
    else
        LLMatches = matchLLGraphs(nV1, nV2, subgraphNodes, corrmatrices, affmatrices, ...
                                  HLGmatches(it).matched_pairs, ...
                                  LLGmatches(it-1));
    end
    LLGmatches(it) = LLMatches;
    
    set(handles.text_objval_LLG, 'String', sprintf('Objval:  %0.3f', LLMatches.objval));
        
    axes(handles.axes6);
    plot_LLGmatches(img1, LLG1, HLG1, ...
                    img2, LLG2, HLG2, ...
                    LLMatches.matched_pairs, ...
                    HLMatches.matched_pairs, GT.LLpairs); 
    
    % plot score and accuracy
    axes(handles.axes13); plot_score(LLGmatches);
    if ~isempty(GT.LLpairs)  % if we know the Ground Truth fot the HL
        axes(handles.axes14); plot_accuracy(LLGmatches, GT.LLpairs);
    end
    
    drawnow;          
    % ----------------------------------------------------------------------- 
    fprintf('\n== Update subgraphs for the next iteration');
    % ----------------------------------------------------------------------- 

    [LLG1, LLG2, HLG1, HLG2, affTrafo] = MetropolisAlg(it, LLG1, LLG2, HLG1, HLG2,...
                                         LLGmatches(it), HLGmatches(it), affTrafo); 
    
    it = it + 1;
    T_it = toc;
    time = time + T_it;
    
    % -----------------------------------------------------------------------    
    axes(handles.axes3);
    plot_2levelgraphs(img1, LLG1, HLG1, false, false, HLGmatches(it-1).matched_pairs,1);

    axes(handles.axes4);
    plot_2levelgraphs(img2, LLG2, HLG2, false, false, HLGmatches(it-1).matched_pairs,2);
    
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

handles.IP1(L).LLG = LLG1;
handles.IP2(L).LLG = LLG2;

handles.IP1(L).HLG = HLG1;
handles.IP2(L).HLG = HLG2;

handles.M(L).LLGmatches = LLGmatches;
handles.M(L).HLGmatches = HLGmatches;
handles.M(L).it = it;
handles.M(L).affTrafo = affTrafo;

axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles}) 

% update data
guidata(hObject, handles);
% end
