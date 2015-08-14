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

% Last Modified by GUIDE v2.5 13-Aug-2015 10:40:27

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
% addpath(genpath('./rearrange_subgraphs_22'));

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
    
%     HLG1 = buildHLGraph(1, LLG1, agparam);
%     HLG2 = buildHLGraph(1, LLG2, agparam);
    HLG1 = [];
    HLG2 = [];

    IP1 = struct('img', img1, 'LLG', LLG1, 'HLG', HLG1);
    IP2 = struct('img', img2, 'LLG', LLG2, 'HLG', HLG2);
    
    HLGmatches = struct('objval', 0, 'matched_pairs', []);
    LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);                      

    M = struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, 'GT', GT, ...
               'it', 0, 'affTrafo', []);
    L = size(IP1,1);        % current level of the pyramid
    
    % plot graphs
    axes(handles.axes1); plot_graph(IP1(L).img, IP1(L).LLG);
    axes(handles.axes2); plot_graph(IP2(L).img, IP2(L).LLG);
    
%     axes(handles.axes3); plot_2levelgraphs(IP1(L).img, IP1(L).LLG, ...
%                                            IP1(L).HLG, false, false);
%     axes(handles.axes4); plot_2levelgraphs(IP2(L).img, IP2(L).LLG, ...
%                                            IP2(L).HLG, false, false);
    axes(handles.axes3); plot_graph(IP1(L).img, IP1(L).LLG);
    axes(handles.axes4); plot_graph(IP2(L).img, IP2(L).LLG);
    
    img3 = combine2images(IP1(L).img, IP2(L).img); % combine two images   
    
    axes(handles.axes5); cla reset; imagesc(img3), axis off;
%     plot_HLGmatches(IP1(L).img, IP1(L).HLG, ...
%                     IP2(L).img, IP2(L).HLG, ...
%                     M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);
    
         
    axes(handles.axes6); cla reset; imagesc(img3), axis off;
    
        
    % update dta    
    handles.IP1 = IP1;
    handles.IP2 = IP2;
    
    handles.M = M;
    
    handles.img1selected = 0;
    handles.img2selected = 0;
    
    handles.IPlevel = L;
    handles.SummaryT = 0.0;     
    
%     handles.resetData = struct('initHLG1', IP1.HLG, 'initHLG2', IP2.HLG, 'GT', M.GT);   % initial data to reset the current test
    handles.initIP1 = IP1;
    handles.initIP2 = IP2;
    handles.initM = M; 
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    
    set(handles.pb_start_MultiLGM, 'Enable', 'on');
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
    if size(img2,3)==1
        img2 = cat(3, img2, img2, img2); % make rgb image from grayscale image
    end

    filePathName = [pathname, filename];
%     [F,D] = features_Cho(filePathName, img2);
    
    setParameters;  
    
    % Image Pyramid
    [IP1, IP2, M] = imagePyramid_imageTr(filePathName, img2);
    L = size(IP1,1);        % current level of the pyramid

    % Show img1 on the axis1
    axes(handles.axes1);cla reset; plot_graph(IP1(1).img, IP1(1).LLG);
    % Show img2 on the axis2
    axes(handles.axes2);cla reset; plot_graph(IP2(1).img, IP2(1).LLG);   
%     % Show img1 on the axis3
%     axes(handles.axes3); plot_2levelgraphs(IP1(L).img, IP1(L).LLG, ...
%                                            IP1(L).HLG, false, false);
%     % Show img2 on the axis4
%     axes(handles.axes4); plot_2levelgraphs(IP2(L).img, IP2(L).LLG, ...
%                                            IP2(L).HLG, false, false);
    axes(handles.axes3); plot_graph(IP1(L).img, IP1(L).LLG);
    axes(handles.axes4); plot_graph(IP2(L).img, IP2(L).LLG);       
    
    img3 = combine2images(IP1(L).img, IP2(L).img); % combine two images    
    
    axes(handles.axes5); imagesc(img3), axis off;
%     plot_HLGmatches(IP1(L).img, IP1(L).HLG, ...
%                     IP2(L).img, IP2(L).HLG, ...
%                     M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);
       
    axes(handles.axes6);  imagesc(img3), axis off;
    
    axes(handles.axes11);cla reset;
    axes(handles.axes12);cla reset;
    axes(handles.axes13);cla reset;
    axes(handles.axes14);cla reset;
    
    % update/reset data
    handles.IP1 = IP1;
    handles.IP2 = IP2;
    
    handles.M = M;                         
    
    handles.IPlevel = L;
    handles.SummaryT = 0.0;
    
    handles.img1selected= 1;
    handles.img2selected= 1;  
    
    % initial data to reset the current test
%     handles.resetData = struct('initHLG1', IP1.HLG, 'initHLG2', IP2.HLG, 'GT', M.GT);   
    handles.initIP1 = IP1;
    handles.initIP2 = IP2;
    handles.initM = M; 
    
    
    set(handles.pb_start_MultiLGM, 'Enable', 'on');
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

% select two images
function pbSelect_2images_Callback(hObject, ~, handles)

[filename1, pathname1] = uigetfile({'*.jpg';'*.png'}, 'Select first image');
if filename1~=0  
    [filename2, pathname2] = uigetfile({'*.jpg';'*.png'}, 'Select second image');

    if filename2~=0
        display(sprintf('First image:'));

        setParameters;

        img1 = imread([pathname1 filesep filename1]);
        if size(img1,3)==1
            img1 = cat(3, img1, img1, img1); % make rgb image from grayscale image
        end    
        
        img2 = imread([pathname2 filesep filename2]);
        if size(img2,3)==1
            img2 = cat(3, img2, img2, img2); % make rgb image from grayscale image
        end    
        
        filePathName1 = [pathname1, filename1];
        filePathName2 = [pathname2, filename2];
        
        [IP1, ~] = imagePyramid(filePathName1, img1);
        [IP2, M] = imagePyramid(filePathName2, img2);
        
        L = size(IP1,1);        % current level of the pyramid

        % Show img1 on the axis1
        axes(handles.axes1);cla reset; plot_graph(IP1(1).img, IP1(1).LLG);
        % Show img2 on the axis2
        axes(handles.axes2);cla reset; plot_graph(IP2(1).img, IP2(1).LLG);   
    %     % Show img1 on the axis3
    %     axes(handles.axes3); plot_2levelgraphs(IP1(L).img, IP1(L).LLG, ...
    %                                            IP1(L).HLG, false, false);
    %     % Show img2 on the axis4
    %     axes(handles.axes4); plot_2levelgraphs(IP2(L).img, IP2(L).LLG, ...
    %                                            IP2(L).HLG, false, false);
        axes(handles.axes3); plot_graph(IP1(L).img, IP1(L).LLG);
        axes(handles.axes4); plot_graph(IP2(L).img, IP2(L).LLG);       

        img3 = combine2images(IP1(L).img, IP2(L).img); % combine two images    

        axes(handles.axes5); imagesc(img3), axis off;
    %     plot_HLGmatches(IP1(L).img, IP1(L).HLG, ...
    %                     IP2(L).img, IP2(L).HLG, ...
    %                     M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);

        axes(handles.axes6);  imagesc(img3), axis off;

        axes(handles.axes11);cla reset;
        axes(handles.axes12);cla reset;
        axes(handles.axes13);cla reset;
        axes(handles.axes14);cla reset;

        % update/reset data
        handles.IP1 = IP1;
        handles.IP2 = IP2;

        handles.M = M;                         

        handles.IPlevel = L;
        handles.SummaryT = 0.0;

        handles.img1selected= 1;
        handles.img2selected= 1;  

        % initial data to reset the current test
    %     handles.resetData = struct('initHLG1', IP1.HLG, 'initHLG2', IP2.HLG, 'GT', M.GT);   
        handles.initIP1 = IP1;
        handles.initIP2 = IP2;
        handles.initM = M; 


        set(handles.pb_start_MultiLGM, 'Enable', 'on');
        set(handles.pb_start, 'Enable', 'on');
        set(handles.pb_reset, 'Enable', 'on');
        set(handles.pb_makeNSteps, 'Enable', 'on');

        set(handles.text_IPlevel, 'String', sprintf('Level: %d',handles.IPlevel));
        set(handles.text_IterationCount, 'String', sprintf('Iteration: -'));
        set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0')); 
        set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
        set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));

    end
end
guidata(hObject,handles); 


%
% Select first image
function pbSelect_img1_Callback(hObject, ~, handles)
[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    display(sprintf('First image:'));
    
    setParameters;
    
    img1 = imread([pathname filesep filename]);
    if size(img1,3)==1
        img1 = cat(3, img1, img1, img1); % make rgb image from grayscale image
    end    
    filePathName = [pathname, filename];
    [IP1, M] = imagePyramid(filePathName, img1);

    L = size(IP1,1);
    
    % Show LLG1 on the axis1
    axes(handles.axes1);cla reset; plot_graph(img1, IP1(1).LLG);
    
    % Show LLG1 on the axis3
    axes(handles.axes3);cla reset; plot_graph(IP1(L).img, IP1(L).LLG);    
%     axes(handles.axes3); plot_2levelgraphs(IP1(L).img, IP1(L).LLG, ...
%                                            IP1(L).HLG, false, false);
    
    if handles.img2selected
        
        img3 = combine2images(IP1(L).img, handles.IP2(L).img);
        
        axes(handles.axes5); imagesc(img3), axis off; 
%         plot_HLGmatches(handles.IP1(L).img, handles.IP1(L).HLG, ...
%                         handles.IP2(L).img, handles.IP2(L).HLG, ...
%                         M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);
        
        axes(handles.axes6); imagesc(img3), axis off;  
        
        handles.IPlevel = L;
        handles.SummaryT = 0.0;
       
        % initial data to reset the current test        
%         handles.resetData = struct('initHLG1', IP1(L).HLG, 'initHLG2', handles.IP2.HLG, 'GT', M.GT);   % initial data to reset the current test
        handles.initIP1 = IP1;
        handles.initIP2 = handles.IP2;
        handles.initM = M; 
        
        
        set(handles.pb_start_MultiLGM, 'Enable', 'on');
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
    if size(img2,3)==1
        img2 = cat(3, img2, img2, img2); % make rgb image from grayscale image
    end      
    filePathName = [pathname, filename];
    [IP2, M] = imagePyramid(filePathName, img2);
    L = size(IP2,1);    % current level of the pyramid
    
    % Show it on the axis2 and axis 4 
    axes(handles.axes2);cla reset;  plot_graph(IP2(1).img, IP2(1).LLG);
    axes(handles.axes4);cla reset;  plot_graph(IP2(L).img, IP2(L).LLG);
    
%     axes(handles.axes4); plot_2levelgraphs(IP2(L).img, IP2(L).LLG, ...
%                                            IP2(L).HLG, false, false);
    
    if handles.img1selected
        img3 = combine2images(handles.IP1(L).img, IP2(L).img);
        
        axes(handles.axes5); imagesc(img3), axis off;
%         plot_HLGmatches(handles.IP1(L).img, handles.IP1(L).HLG, ...
%                         IP2(L).img, IP2(L).HLG, ...
%                         M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);
        axes(handles.axes6); imagesc(img3), axis off;
        
        handles.IPlevel = L;
        handles.SummaryT = 0.0;
        
        % initial data to reset the current test        
%         handles.resetData = struct('initHLG1', handles.IP1(L).HLG, 'initHLG2', IP2.HLG, 'GT', M.GT);   % initial data to reset the current test
        handles.initIP1 = handles.IP1;
        handles.initIP2 = IP2;
        handles.initM = M; 
    
        
        set(handles.pb_start_MultiLGM, 'Enable', 'on');
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

% --- Executes on button press in pbSaveImg_axes12.
function pbSaveImg_axes12_Callback(~, ~, handles)
[filename, pathname] = uiputfile({'*.jpg'}, 'Save file name');
if  filename~=0
    img1 = getframe(handles.axes1);
    img2 = getframe(handles.axes2);
    
    img12 = combine2images(img1.cdata, img2.cdata);
    imwrite(img12, [pathname, filesep, filename], 'Quality', 100);  
end

%-------------------------------------------------------------------------
%       Panel2 : building coarse graphs (ancor graph) and fine graphs 
%-------------------------------------------------------------------------


% --- Executes on button press in cbShow_HLG.
function cbShow_HLG_Callback(~, ~, handles)

show_LLG = get(handles.cbShow_LLG, 'Value');
show_HLG = get(handles.cbShow_HLG, 'Value');

L = handles.IPlevel;
it = handles.M(L).it;

if it==0
    % replot first anchor graph
    axes(handles.axes3); plot_2levelgraphs(handles.IP1(L).img, handles.IP1(L).LLG, ...
                                           handles.IP1(L).HLG, show_LLG, show_HLG);
    % replot second anchor graph              
    axes(handles.axes4); plot_2levelgraphs(handles.IP2(L).img, handles.IP2(L).LLG, ...
                                           handles.IP2(L).HLG, show_LLG, show_HLG)    
else  
    % replot first anchor graph
    axes(handles.axes3); plot_2levelgraphs(handles.IP1(L).img, handles.IP1(L).LLG, ...
                                           handles.IP1(L).HLG, show_LLG, show_HLG, ...
                                           handles.M(L).HLGmatches(it).matched_pairs,1);
    % replot second anchor graph              
    axes(handles.axes4); plot_2levelgraphs(handles.IP2(L).img, handles.IP2(L).LLG, ...
                                           handles.IP2(L).HLG, show_LLG, show_HLG, ...
                                           handles.M(L).HLGmatches(it).matched_pairs,1);
end
%end


% --- Executes on button press in cbShow_LLG.
function cbShow_LLG_Callback(~, ~, handles)

show_LLG = get(handles.cbShow_LLG, 'Value');
show_HLG = get(handles.cbShow_HLG, 'Value');

L = handles.IPlevel;
it = handles.M(L).it;

if it==0
    % replot first anchor graph
    axes(handles.axes3); plot_2levelgraphs(handles.IP1(L).img, handles.IP1(L).LLG, ...
                                           handles.IP1(L).HLG, show_LLG, show_HLG);
    % replot second anchor graph              
    axes(handles.axes4); plot_2levelgraphs(handles.IP2(L).img, handles.IP2(L).LLG, ...
                                           handles.IP2(L).HLG, show_LLG, show_HLG)    
else  
    % replot first anchor graph
    axes(handles.axes3); plot_2levelgraphs(handles.IP1(L).img, handles.IP1(L).LLG, ...
                                           handles.IP1(L).HLG, show_LLG, show_HLG, ...
                                           handles.M(L).HLGmatches(it).matched_pairs,1);
    % replot second anchor graph              
    axes(handles.axes4); plot_2levelgraphs(handles.IP2(L).img, handles.IP2(L).LLG, ...
                                           handles.IP2(L).HLG, show_LLG, show_HLG, ...
                                           handles.M(L).HLGmatches(it).matched_pairs,1);
end
%end

% --- Executes on button press in pbSaveImg_axes34.
function pbSaveImg_axes34_Callback(~, ~, handles)

[filename, pathname] = uiputfile({'*.jpg'}, 'Save file name');
if  filename~=0
    img3 = getframe(handles.axes3);
    img4 = getframe(handles.axes4);

    img34 = combine2images(img3.cdata, img4.cdata);
    imwrite(img34, [pathname, filesep, filename], 'Quality', 100);  
end


%-------------------------------------------------------------------------
%       Panel3 : matching Higher Level Graphs
%-------------------------------------------------------------------------

% --- Executes on button press in pb_accuracy_LL.
function pb_accuracy_HL_Callback(~, ~, handles)
figure;

nSubplots = 1;

L = handles.IPlevel;
HLGmatches = handles.M(L).HLGmatches;

nIt = size(HLGmatches, 2);


x = 1:1:nIt;
y_obj = zeros(1, nIt);
for i=1:1:nIt
    y_obj(i) = HLGmatches(i).objval;
end

% if we knew the Ground Truth for the HL
if ~isempty(handles.M(L).GT.HLpairs)
    nSubplots = 2;
    
    GT = handles.M(L).GT.HLpairs;
    y_ac = zeros(1, nIt);
    for i=1:1:nIt
        TP = ismember(HLGmatches(i).matched_pairs(:,1:2), GT, 'rows');
        TP = sum(TP(:));
        y_ac(i) = TP/ size(HLGmatches(i).matched_pairs,1)*100;
    end
    
    subplot(1,2,2);
    plot(x, y_ac), hold on; plot(x,y_ac, 'bo'), hold off;
    xlabel('Iteration'); ylabel('Accurasy');set(gca,'FontSize',6);
    set(legend('Accurasy'), 'Location', 'best', 'FontSize', 6);
end


subplot(1,nSubplots,1);
plot(x, y_obj), hold on; plot(x,y_obj, 'bo'), hold off;
xlabel('Iteration'); ylabel('Score');set(gca,'FontSize',6);
% title('          Matching result on the Higher Level');
set(legend('Score'), 'Location', 'best', 'FontSize', 6);

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

% --- Executes on button press in pb_accuracy_LL.
function pb_accuracy_LL_Callback(~, ~, handles)
figure; nSubplots = 1;

L = handles.IPlevel;
LLGmatches = handles.M(L).LLGmatches;

nIt = size(LLGmatches,2);

x = 1:1:nIt;
y_obj = zeros(1, nIt);
for i=1:1:nIt
    y_obj(i) = LLGmatches(i).objval;
end

% if we know the Ground Truth fot the LL
if ~isempty(handles.M(L).GT.LLpairs)
    nSubplots = 2;
    
    GT = handles.M(L).GT.LLpairs;
    y_ac = zeros(1, nIt);
    for i=1:1:nIt
        TP = ismember(LLGmatches(i).matched_pairs(:,1:2), GT, 'rows');
        TP = sum(TP(:));
        y_ac(i) = TP/ size(LLGmatches(i).matched_pairs,1) * 100;
    end
    
    subplot(1,2,2);
    plot(x, y_ac), hold on; plot(x,y_ac, 'bo'), hold off;
    xlabel('Iteration'); ylabel('Accurasy'); set(gca,'FontSize',6)
    set(legend('Accurasy'), 'Location', 'best', 'FontSize', 6);
end

subplot(1,nSubplots,1);
plot(x, y_obj), hold on; plot(x,y_obj, 'bo'), hold off;
xlabel('Iteration'); ylabel('Score');set(gca,'FontSize',6);
set(legend('Score'), 'Location', 'best', 'FontSize', 6);

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

%-------------------------------------------------------------------------
%       Panel2 : Algorithm control
%-------------------------------------------------------------------------


% ------------------         Start        --------------------------------
function pb_start_Callback(hObject, ~, handles)

rng(1);

L = str2double(get(handles.edit_selectLevel,'string'));  %handles.IPlevel;
assert(L<=size(handles.IP1,1), 'image pyramid has only %d level(s)', size(handles.IP1,1));

% pb_reset_Callback(hObject, [], handles);

% reset data
IP1 = handles.initIP1;
IP2 = handles.initIP2;

HLGmatches = struct('objval', 0, 'matched_pairs', []);
LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);  

for i = 1:size(IP1,1)
    IP1(i).HLG = [];
    IP2(i).HLG = [];
%     IP1(i).HLG.D_appear = [];
%     IP1(i).HLG.D_struct = cell(size(IP1(i).HLG.V,1),1);
% 
%     IP2(i).HLG.D_appear = [];
%     IP2(i).HLG.D_struct = cell(size(IP2(i).HLG.V,1),1);

    M(i,1) = struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, 'GT', handles.M(i).GT, ...
               'it',0, 'affTrafo', []);
end

LLG1 = IP1(L).LLG;
LLG2 = IP2(L).LLG;

HLG1 = IP1(L).HLG;
HLG2 = IP2(L).HLG;

LLGmatches = M(L).LLGmatches;
HLGmatches = M(L).HLGmatches;

affTrafo = M(L).affTrafo;

% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------     

% setParameters;

% nMaxIt = algparam.nMaxIt;       % maximal number of iteration for each level of the image pyramid
% nConst = algparam.nConst;       % stop, if the matching score didn't change in last C iterations
 
% time = handles.SummaryT;

% it = 0; count = 0;
% 
% [LLG1, LLG2] = preprocessing(LLG1, LLG2, agparam);
% 
% while count<nConst && it<nMaxIt
%     it = it + 1;
%     
%     tic;
%     [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo] = ...
%         twoLevelGM_oneIteration(it, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);
%     time = time + toc;   
%     
%     if it>=2 && (LLGmatches(it).objval-LLGmatches(it-1).objval<eps)
%         count = count + 1;
%     else
%         count = 0;
%     end
%     
%     handles.SummaryT = time;
% 
%     handles.M(L).LLGmatches = LLGmatches;
%     handles.M(L).HLGmatches = HLGmatches;
%     handles.M(L).it = it;
%     handles.M(L).affTrafo = affTrafo;
% 
%     handles = update_GUI_after_one_GM_iteration(handles);        
%     
%     handles.IP1(L).HLG = HLG1;
%     handles.IP2(L).HLG = HLG2;
%     
%     guidata(hObject, handles);
% end

% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------    
[HLG1, HLG2, LLGmatches, HLGmatches, affTrafo, time, it] = ...
    twoLevelGM(L, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);

handles.SummaryT = time;

handles.M(L).LLGmatches = LLGmatches;
handles.M(L).HLGmatches = HLGmatches;
handles.M(L).it = it;
handles.M(L).affTrafo = affTrafo;
guidata(hObject, handles);

handles.IP1(L).HLG = HLG1;
handles.IP2(L).HLG = HLG2;

handles = update_GUI_after_one_GM_iteration(L, handles);        

guidata(hObject, handles);

% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------    
axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles}) 

% update data
guidata(hObject, handles);
% ----------------------------------------------------------------------- 


% ------------------         Reset        --------------------------------
function pb_reset_Callback(hObject, ~, handles)

rng(1);

L = str2double(get(handles.edit_selectLevel,'string'));  %handles.IPlevel;

IP1 = handles.initIP1;
IP2 = handles.initIP2;

HLGmatches = struct('objval', 0, 'matched_pairs', []);
LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);  

for i = 1:size(IP1,1)
    IP1(i).HLG = [];
    IP2(i).HLG = [];
%     IP1(i).HLG.D_appear = [];
%     IP1(i).HLG.D_struct = cell(size(IP1(i).HLG.V,1),1);
% 
%     IP2(i).HLG.D_appear = [];
%     IP2(i).HLG.D_struct = cell(size(IP2(i).HLG.V,1),1);

    M(i,1) = struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, 'GT', handles.M(i).GT, ...
               'it',0, 'affTrafo', []);
end

% img1 = handles.IP1(1).img;
% img2 = handles.IP2(1).img;
% 
% initLLG1 = handles.IP1(1).LLG;
% initLLG2 = handles.IP2(1).LLG;
% 
% initHLG1 = handles.resetData.initHLG1;
% initHLG2 = handles.resetData.initHLG2;
% 
% GT = handles.resetData.GT;
% 
% IP1 = struct('img', img1, 'LLG', initLLG1, 'HLG', initHLG1);
% IP2 = struct('img', img2, 'LLG', initLLG2, 'HLG', initHLG2);
% 
% HLGmatches = struct('objval', 0, 'matched_pairs', []);
% LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);                      
% 
% M = struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, 'GT', GT, ...
%            'it',0, 'affTrafo', []);


% Show img1 on the axis1
axes(handles.axes1);cla reset; plot_graph(IP1(1).img, IP1(1).LLG);
% Show img2 on the axis2
axes(handles.axes2);cla reset; plot_graph(IP2(1).img, IP2(1).LLG);   
% Show img2 on the axis3
axes(handles.axes3);cla reset; plot_graph(IP1(L).img, IP1(L).LLG);
% axes(handles.axes3); plot_2levelgraphs(IP1(L).img, IP1(L).LLG, ...
%                                        IP1(L).HLG, false, false);
% Show img2 on the axis4
axes(handles.axes4);cla reset; plot_graph(IP2(L).img, IP2(L).LLG);   
% axes(handles.axes4); plot_2levelgraphs(IP2(L).img, IP2(L).LLG, ...
%                                        IP2(L).HLG, false, false);

img3 = combine2images(IP1(L).img, IP2(L).img); % combine two images     

axes(handles.axes5); imagesc(img3), axis off;
% plot_HLGmatches(IP1(L).img, IP1(L).HLG, ...
%                 IP2(L).img, IP2(L).HLG, ...
%                 M(L).HLGmatches.matched_pairs, M(L).HLGmatches.matched_pairs);           
axes(handles.axes6);  imagesc(img3), axis off;

axes(handles.axes11);cla reset;
axes(handles.axes12);cla reset;
axes(handles.axes13);cla reset;
axes(handles.axes14);cla reset;

% update/reset data
handles.IP1 = IP1; 
handles.IP2 = IP2;

handles.M = M;                        

handles.IPlevel = L;
handles.SummaryT = 0.0;

handles.img1selected= 1;
handles.img2selected= 1;  

set(handles.pb_start_MultiLGM, 'Enable', 'on');
set(handles.pb_start, 'Enable', 'on');
set(handles.pb_reset, 'Enable', 'on');
set(handles.pb_makeNSteps, 'Enable', 'on');

set(handles.text_IPlevel, 'String', sprintf('Level: %d',handles.IPlevel));
set(handles.text_IterationCount, 'String', sprintf('Iteration: -'));
set(handles.text_SummaryT, 'String', sprintf('Summary time: 0.0')); 
set(handles.text_objval_HLG, 'String', sprintf('Objval: -'));
set(handles.text_objval_LLG, 'String', sprintf('Objval: -'));

% update data
guidata(hObject, handles);
% ----------------------------------------------------------------------- 


% ------------------  Make N steps        --------------------------------
function pb_makeNSteps_Callback(hObject, ~, handles)

N = str2double(get(handles.edit_NSteps,'string')); 
L = str2double(get(handles.edit_selectLevel,'string'));  %handles.IPlevel;

LLG1 = handles.IP1(L).LLG;  
LLG2 = handles.IP2(L).LLG;  

HLG1 = handles.IP1(L).HLG;
HLG2 = handles.IP2(L).HLG;

LLGmatches = handles.M(L).LLGmatches;
HLGmatches = handles.M(L).HLGmatches;

affTrafo = handles.M(L).affTrafo;

% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------   

% setParameters;

% it = handles.M(L).it;
% time = handles.SummaryT;

% [LLG1, LLG2] = preprocessing(LLG1, LLG2, agparam);
% 
% for i = 1:N
%     it = it + 1;
%     
%     tic;
%     [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo] = ...
%         twoLevelGM(it, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);  
%     time = time + toc;   
%     
%     handles.SummaryT = time;
% 
%     handles.M(L).LLGmatches = LLGmatches;
%     handles.M(L).HLGmatches = HLGmatches;
%     handles.M(L).it = it;
%     handles.M(L).affTrafo = affTrafo;
%     
%     handles = update_GUI_after_one_GM_iteration(handles);       
%       
%     handles.IP1(L).HLG = HLG1;
%     handles.IP2(L).HLG = HLG2;
%     
%     guidata(hObject, handles);
% end
% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------    
it = handles.M(L).it;
[HLG1, HLG2, LLGmatches, HLGmatches, affTrafo, time, it] = ...
    twoLevelGM_nSteps(L, N, it, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);

handles.SummaryT = time;

handles.M(L).LLGmatches = LLGmatches;
handles.M(L).HLGmatches = HLGmatches;
handles.M(L).it = it;
handles.M(L).affTrafo = affTrafo;
guidata(hObject, handles);

handles.IP1(L).HLG = HLG1;
handles.IP2(L).HLG = HLG2;

handles = update_GUI_after_one_GM_iteration(L, handles);      
guidata(hObject, handles);

% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------   

axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles}) 

% update data
guidata(hObject, handles);
% ------------------------------------------------------------------------


% ----------         Start  Multi Level Algorithm   ----------------------
function pb_start_MultiLGM_Callback(hObject, eventdata, handles)
setParameters;

% nMaxIt = algparam.nMaxIt;       % maximal number of iteration for each level of the image pyramid
% nConst = algparam.nConst;       % stop, if the matching score didn't change in last C iterations
 
% time = handles.SummaryT;

% reset data
IP1 = handles.initIP1;
IP2 = handles.initIP2;

HLGmatches = struct('objval', 0, 'matched_pairs', []);
LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);  

for i = 1:size(IP1,1)
    IP1(i).HLG = [];
    IP2(i).HLG = [];
%     IP1(i).HLG.D_appear = [];
%     IP1(i).HLG.D_struct = cell(size(IP1(i).HLG.V,1),1);

%     IP2(i).HLG.D_appear = [];
%     IP2(i).HLG.D_struct = cell(size(IP2(i).HLG.V,1),1);

    M(i,1) = struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, 'GT', handles.M(i).GT, ...
               'it',0, 'affTrafo', []);
end
% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------    

% [IP1, IP2, M, time] = pyramid_twoLevelGM(IP1, IP2, M);
[IP1, IP2, M, time] = multiLevelGM(IP1, IP2, M);

% -----------------------------------------------------------------------       
% -----------------------------------------------------------------------  

handles.SummaryT = sum(time(:));
handles.M = M;
handles.IP1 = IP1;
handles.IP2 = IP2;
guidata(hObject, handles);

L = 1;
handles = update_GUI_after_one_GM_iteration(L, handles);        

axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles}) 

% update data
guidata(hObject, handles);
%end

