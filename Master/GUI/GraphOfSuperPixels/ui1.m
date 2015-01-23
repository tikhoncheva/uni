function varargout = ui1(varargin)
% UI1 MATLAB code for ui1.fig
%      UI1, by itself, creates a new UI1 or raises the existing
%      singleton*.
%
%      H = UI1 returns the handle to a new UI1 or the handle to
%      the existing singleton*.
%
%      UI1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UI1.M with the given input arguments.
%
%      UI1('Property','Value',...) creates a new UI1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ui1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ui1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ui1

% Last Modified by GUIDE v2.5 23-Jan-2015 16:23:30
clc;
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ui1_OpeningFcn, ...
                   'gui_OutputFcn',  @ui1_OutputFcn, ...
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


% --- Executes just before ui1 is made visible.
function ui1_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for ui1
handles.output = hObject;

handles = resetcontrols(handles);
resetaxes(handles);

handles.img1selected = 0;
handles.img2selected = 0;

guidata(hObject,handles); 

% set parameters

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

% Matching routines
addpath(genpath( './Matching' ));
clc;

% Graph matching algorithm
addpath(genpath('../../Tools/RRWM_release_v1.22'));
clc;

set(handles.axes6,'XTick',[]);
set(handles.axes6,'YTick',[]);

set(handles.axes4,'XTick',[]);
set(handles.axes4,'YTick',[]);

set(handles.axes5,'XTick',[]);
set(handles.axes5,'YTick',[]);

% UIWAIT makes ui1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ui1_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function mOpen_Callback(hObject, eventdata, handles)
% hObject    handle to mOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
%
%   open image 1
%
function mOpenImg1_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');
%global img1;
if filename~=0
    set(handles.filename1, 'String', filename);
    img1 = imread([pathname filesep filename]);
    
    [img1SP.num, ... 
     img1SP.label, ...
     img1SP.boundary] = SLIC_Superpixels(im2uint8(img1), 1000, 20);
 
    handles.img1 = img1;
    handles.img1SP = img1SP;   
    handles.img1selected = 1;
    
    replotaxes(handles.axes1, img1);
    % if both images are selected
    if (handles.img2selected)
        set(handles.pushbuttonGetFeauters,'enable','on');
        
        % Plot two images together
        img2 = handles.img2;
        img3 = combine2images(img1, img2);
        
        handles.img12SP = combine2images(handles.img1SP.boundary, ...
                                         handles.img2SP.boundary);
        replotaxes(handles.axes6, img3);
        
    end  
    
    guidata(hObject,handles); 
    set(handles.pbSaveCurrentPoint,'Enable','off');   % Save current point
end

% --------------------------------------------------------------------
%
%   Open image 2
%
function mOpenImg2_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select second image');

if  filename~=0
    set(handles.filename2, 'String', filename);
    img2 = imread([pathname filesep filename]);
    [img2SP.num, ... 
     img2SP.label, ...
     img2SP.boundary] = SLIC_Superpixels(im2uint8(img2), 4000, 20);
    
    handles.img2 = img2;
    handles.img2SP = img2SP;      
    handles.img2selected = 1;  
    
    handles = resetcontrols(handles);
    resetaxes(handles);
    
    replotaxes(handles.axes2, img2);   
    % if both images are selected
    if (handles.img1selected)
        set(handles.pushbuttonGetFeauters,'enable','on');
        
        % Plot two images together
        img1 = handles.img1;
        img3 = combine2images(img1, img2);
        
        handles.img12SP = combine2images(handles.img1SP.boundary, ...
                                         handles.img2SP.boundary);
                                     
        replotaxes(handles.axes6, img3);
    end  
   
    guidata(hObject,handles); 
    set(handles.pbSaveCurrentPoint,'Enable','off');   % Save current point
end
      

% --- Executes on button press in pushbuttonGetFeauters.
%
% Compute features on the both images
%
function pushbuttonGetFeauters_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
 
img1 = handles.img1;
img2 = handles.img2;

replotaxes(handles.axes1, img1);
replotaxes(handles.axes2, img2);

% edge points on each images
edgesCell = cell(1,2);

% descriptors of the edge points on each images
edgeDescrCell = cell(1,2);

% Extract edge points
[F1, D1] = computeDenseSIFT(img1);
[F2, D2] = computeDenseSIFT(img2);

edgesCell{1} = F1;
edgesCell{2} = F2;

edgeDescrCell{1} = D1;
edgeDescrCell{2} = D2;

edgeDescrCell{1}(:, all( ~any(edgeDescrCell{1}), 1)) = []; % remove zero columns
edgeDescrCell{2}(:, all( ~any(edgeDescrCell{2}), 1)) = []; % remove zero columns

% load( 'frames.mat' , 'edgesCell', 'edgeDescrCell');
 
handles.edges = edgesCell;
handles.edgeDescr = edgeDescrCell;
handles.matched = 0;

handles.savepoints = 0;
guidata(hObject,handles); 

% save( 'frames.mat' ,'edgesCell', 'edgeDescrCell');

% Plot two images together
% img3 = combine2images(img1, img2);
% replotaxes(handles.axes6, img3); 

% ---------------------------------------------------------------
set(handles.pbBuildGraphs,'Enable','on');

set(handles.axes6,'Visible', 'on');    

img3 = combine2images(img1,img2);
replotaxes(handles.axes6, img3);

set(handles.checkShowDG,'Value', 0);   % Show Dependency Graph
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors


set(handles.pbSaveCurrentPoint,'Enable','on');   % Save current point

axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})


% --- Executes on button press in pbSelectPoints.
% 
% Show candidate matches py clicking on the point
% (see also axes6_ButtonDownFcn)
% 
function pbSelectPoints_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

% delete old points
handles.matchInfo.match = [];
handles.matchInfo.dist = [];
handles.matchInfo.sim = [];

handles.frames{1} = [];
handles.frames{2} = [];
handles.descr{2} = [];
handles.descr{3} = [];


handles.savepoints = 1;
guidata(hObject,handles); 

img1 = handles.img1;
img2 = handles.img2;
img3 = combine2images(img1,img2);
replotaxes(handles.axes6, img3);

% ---------------------------------------------------------------
set(handles.checkShowDG,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors

axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})


% --- Executes on mouse press over axes background.
% 
% Show candidate matches py clicking on the point
% (see also axes6_ButtonDownFcn)
% 
function axes6_ButtonDownFcn(hObject, eventdata, handles)

% get current position of the mouse
cP = get(gca,'Currentpoint');
x = cP(1,1);
y = cP(1,2);
[x,y]
 

set(handles.pbSaveCurrentPoint,'Enable','on');   % Save current point



% --- Executes on button press in pbBuildGraphs.
%
% Build graphs of the images
%
function pbBuildGraphs_Callback(hObject, eventdata, handles)

% set parameters
SetParameters;
str=get(handles.edit3, 'String');
mparam.kNN= str2num(str);
knn = mparam.kNN;

handles = guidata(hObject);

% images
img1 = handles.img1;
img2 = handles.img2;

% edge points and descriptors
edges = handles.edges;
edgeDesc = handles.edgeDescr;

DG1 = buildGraph(edges{1}, edgeDesc{1}, handles.img1SP);



handles.DG{1} = DG1;
% handles.DG{2} = DG2;

guidata(hObject,handles);

% ---------------------------------------------------------------

% visialize results of matching

axes(handles.axes6);
cla reset

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})

set(handles.checkShowDG,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors

set(handles.pbSaveCurrentPoint,'Enable','on');   % Save current point
set(handles.checkShowDG,'Enable','on');   % Show Initial Matches
set(handles.checkboxShowInitM,'Enable','on');   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Enable','on');   % Show Neighbors
set(handles.pushbuttonClearAll,'Enable','on');   % Show Matching results



% --- Executes on mouse press over axes background.
%
% Show initial candidates and the best match according to the algorithm
%
function axes3_ButtonDownFcn(hObject, eventdata, handles)


% cla 

img1 = handles.img1;
img2 = handles.img2;

f = handles.frames;

v1 = f{1}(1:2,:);
v2 = f{2}(1:2,:);

nV1 = size(v1,2);
nV2 = size(v2,2);

initMatches = handles.InitialMatching;
newMatches = handles.newMatching;
                 
cP = get(gca,'Currentpoint');
n = cP(1,1);
m = cP(1,2);
 
[m1,n1, ~] = size(img1) ;
[m2,n2, ~] = size(img2) ;
      
if (n>n1)
    % point on the second image
    n = n-n1;
    img = 2;
else
    % point on the first image
    img = 1;
end
      
if img==1
    nn = knnsearch(f{1}(1:2,:)',[n,m]);
    feature_nn = f{1}(:,nn);  
else
    nn = knnsearch(f{2}(1:2,:)',[n,m]);
    feature_nn = f{2}(:,nn);
    feature_nn(1) = feature_nn(1) + n1;      
end
      
% show best match
      
matchOld = zeros(nV1, nV2);
matchNew = zeros(nV1, nV2);

if (img==1)
    matchOld(nn, :) = initMatches(nn, :);
    matchNew(nn, :) = newMatches(nn, :);
else
    matchOld(:, nn) = initMatches(:, nn);
    matchNew(:, nn) = newMatches(:,nn);          
end

axes(handles.axes6);
cla reset
plotMatches(img1,img2, v1', v2', matchNew, matchOld);
            
% get corresponding descriptor of the best match      
if img==1 
    nn_2 = find(matchNew(nn, :));
    feature_nn_2 = f{2}(:,nn_2);
    feature_nn_2(1) = feature_nn_2(1) + n1;
else
    nn_2 = nn;  
    feature_nn_2 = feature_nn;     
    nn = find(matchNew(:,nn_2));
    feature_nn = f{1}(:,nn);
end      

% show patches
R  = 15; % from vl_feat

% second image
c2  = f{2}(1:2,nn_2);
patch2 = imcrop(img2, [c2(1)-R, c2(2)-R, 2*R+1, 2*R+1]);
axes(handles.axes5);
imagesc(patch2), colormap gray, hold off;

% first image
c1  = f{1}(1:2,nn);
axes(handles.axes4);
if numel(c1)~=0
    patch1 = imcrop(img1, [c1(1)-R, c1(2)-R, 2*R+1, 2*R+1]);
    imagesc(patch1),  colormap gray, hold off;
else
   cla reset 
end

% If show Neighbors
showNeighbors = get(handles.checkboxShowNeighbors,'Value');
if showNeighbors
   DG = handles.DG;

   % Neighbors on the right image
   nf2 = zeros(size(DG{2}));
   nf2(nn_2,:) = DG{2}(nn_2,:);
   f_2 = f{2};
   f_2(1,:) = f_2(1,:)+ n1;
   draw_graph(img, 'img2', f_2, nf2);
   
   % Neighbors on the left image
   nf1 = zeros(size(DG{1}));
   nf1(nn,:) = DG{1}(nn,:);
    
   draw_graph(img, 'img1', f{1}, nf1);
end

% axes(handles.axes3);
% set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
% set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})    


% --- Executes on button press in checkShowDG.
%
% Show dependency  graphs on the input images
%
function checkShowDG_Callback(hObject, eventdata, handles)

handles = guidata(hObject);

img1 = handles.img1;
img2 = handles.img2;
framesCell = handles.frames;

DG = handles.DG;

checked = get(hObject,'Value');

if checked 
    axes(handles.axes1);
    draw_graph(img1, 'Image 1', framesCell{1}(1:2,:), DG{1}); 
    axes(handles.axes2);
    draw_graph(img2, 'Image 2', framesCell{2}(1:2,:), DG{2});                                                  
                                                 
else
    replotaxes(handles.axes1, img1);
    replotaxes(handles.axes2, img2);
end


% --- Executes on button press in checkboxShowInitM.
%
% Show initial candidates
%
function checkboxShowInitM_Callback(hObject, eventdata, handles)

img1 = handles.img1;
img2 = handles.img2;
framesCell = handles.frames;

v1 = framesCell{1}(1:2,:);
v2 = framesCell{2}(1:2,:);

InitialMatching = handles.InitialMatching;
newMatching = handles.newMatching;

checked = get(hObject,'Value');

axes(handles.axes6);
cla reset
if checked 
    plotMatches(img1,img2, v1', v2', newMatching, InitialMatching);           

else
    plotMatches(img1,img2, v1', v2', newMatching);  
end

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})


% --- Executes on button press in pushbuttonClearAll.
%
% Clear all
%
function pushbuttonClearAll_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
axes(handles.axes6);
cla reset

img1 = handles.img1;
img2 = handles.img2;

if (handles.matched)
    framesCell = handles.frames;
    
    v1 = framesCell{1}(1:2,:);
    v2 = framesCell{2}(1:2,:);
    
    newMatching = handles.newMatching;
    plotMatches(img1,img2, v1', v2', newMatching);

else
    img3 = combine2images(img1, img2);
    replotaxes(handles.axes6, img3);
end

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
guidata(hObject,handles);


% --- Executes on button press in pbSaveCurrentPoint.
%
%  save current point
%
function pbSaveCurrentPoint_Callback(hObject, eventdata, handles)

set(handles.pbBuildGraphs,'Enable','on');   % Enable matching 
% get already saved frames, descriptors and matches
handles = guidata(hObject);

framesCell = handles.frames;
descrCell = handles.descr;
matchInfo = handles.matchInfo; 

F1 = size(framesCell{1},2)+1;   % increase the number of frames
D2 = size(descrCell{2},2)+1;    % increase the number of descr

global newPoint

% add new point to frames and descr on the first images
framesCell{1} = [framesCell{1}, newPoint.frame];      
descrCell{1} =  [ descrCell{1}, newPoint.descr];
    
nNewMatches = numel(newPoint.neighbors);
maxsimval = 1; % max(newPoint.simvals(:));

% add all matches point to the frames, descr on the second image
if size(framesCell{2},2)>0
    for i = 1:nNewMatches
        % check if the frame was not alredy saved
        [~,p] = ismember(newPoint.neighborsFrames(:,i)', framesCell{2}','rows');

        if (p~=0)
            matchInfo.match = [matchInfo.match [F1; p]];
            matchInfo.sim = [matchInfo.sim; newPoint.simvals(i)];
            matchInfo.dist =[ matchInfo.dist, max(newPoint.simvals(:)) - newPoint.simvals(i)];

        else

            D2 = size(descrCell{2},2)+1;
            
            framesCell{2} = [framesCell{2}, newPoint.neighborsFrames(1:end,i) ];
            descrCell{2} = [descrCell{2}, newPoint.neighborsDescrs(:,i)]; 

            matchInfo.match = [matchInfo.match [F1;D2] ];
            matchInfo.sim = [matchInfo.sim; newPoint.simvals(i)];
            matchInfo.dist =[matchInfo.dist, maxsimval - newPoint.simvals(i,1)];
        end

    end
else     

    % add all matches point to the frames, descr on the second image
    framesCell{2} = [framesCell{2}, newPoint.neighborsFrames ];
    descrCell{2} = [descrCell{2}, newPoint.neighborsDescrs]; 
    % add new matches

    matchInfo.match = [matchInfo.match [F1*ones(1,nNewMatches);...
                                        D2:D2+nNewMatches-1]];
    matchInfo.sim = [matchInfo.sim; newPoint.simvals];
    matchInfo.dist = [ matchInfo.dist, maxsimval - newPoint.simvals'];

end
% update saved values
handles.frames = framesCell;
handles.descr = descrCell;
handles.matchInfo = matchInfo; 

guidata(hObject,handles); 

set(handles.pbSaveCurrentPoint,'Enable','off');   % Save current point


% --- Executes on button press in pbClear.
%
% plot combined image3
%
function pbClear_Callback(hObject, eventdata, handles)

handles = guidata(hObject);

img1 = handles.img1;
img2 = handles.img2;
img3 = combine2images(img1,img2);

replotaxes(handles.axes6, img3);

axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})




% --- Executes on button press in pbSavePoints.
%
%   Save frames, descriptors, matchInfo of previously selected points
%
function pbSavePoints_Callback(hObject, eventdata, handles)

set(handles.pbBuildGraphs,'Enable','on');   % Enable matching 
% get already saved frames, descriptors and matches
handles = guidata(hObject);

framesCell = handles.frames;
descrCell = handles.descr;
matchInfo = handles.matchInfo; 

n = size(framesCell{1},2);

[filename, pathname] = uiputfile({'*.mat'}, 'Save file name');

if  filename~=0
    save([pathname filesep filename] ,'framesCell',...
                                      'descrCell', ...
                                      'matchInfo');
end
axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})

% --- Executes on button press in pbLoadPoints.
%
%  Load frames, descriptors, matchInfo of previously selected points
%  from a file
%
function pbLoadPoints_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.mat'}, 'File Selector');
%global img1;
if  filename~=0
    % read data from file
    load( [pathname filesep filename] ,'-mat', 'framesCell',...
                           'descrCell', ...
                           'matchInfo');
    
    % rewrite current variables
    handles = guidata(hObject);
    
    handles.frames = framesCell;
    handles.descr = descrCell;
    handles.matchInfo = matchInfo; 

    guidata(hObject,handles); 
    
    % plot points and matches
    
    img1 = handles.img1;
    img2 = handles.img2;
    
    nV1 = size(framesCell{1},2);
    nV2 = size(framesCell{2},2);
    
    v1 = framesCell{1}(1:2,:);
    v2 = framesCell{2}(1:2,:);
    
    corrMatrix = zeros(nV1,nV2);
    for ii = 1:size(matchInfo.match,2)
        corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
    end

    axes(handles.axes6);
    plotMatches(img1,img2, v1', v2', corrMatrix);
    
    set(handles.pbBuildGraphs,'Enable','on');   % Enable matching 
end
axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})


% --- Executes on button press in pbDeleteAllsPoints.
%
% Delete all selected points
%
function pbDeleteAllsPoints_Callback(hObject, eventdata, handles)

% load current values
handles = guidata(hObject);

handles = resetcontrols(handles);

% update handles
guidata(hObject,handles);


% replot image
img1 = handles.img1;
img2 = handles.img2;
img3 = combine2images(img1,img2);

axes(handles.axes6);
replotaxes(handles.axes6, img3);

% set(handles.pushbuttonGetFeauters,'enable','on');
% set(handles.pbSelectPoints,'enable','on');

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})



% --- Executes on button press in pbShowsPoints.
%
% Show all selected points
%
function pbShowsPoints_Callback(hObject, eventdata, handles)

% load current values
handles = guidata(hObject);
 
img1 = handles.img1;
img2 = handles.img2;
img3 = combine2images(img1,img2);

v1 = handles.frames{1}(1:2,:);
v2 = handles.frames{2}(1:2,:);

matchInfo = handles.matchInfo;

% axes(handles.axes6);
% imagesc(img3), hold on

for i = 1:size(v1,2)
    X1 = v1(1,i);
    Y1 = v1(2,i);
    rectangle('Position',[X1-3,Y1-3,6,6],'FaceColor','r');
end 

for i = 1:size(v2,2)
    X2 = v2(1,i)+ size(img1,2);
    Y2 = v2(2,i);
    rectangle('Position',[X2-3,Y2-3,6,6],'FaceColor','r');
end 


nV1 = size(v1,2);
nV2 = size(v2,2);

corrMatrix = zeros(nV1,nV2);
for ii = 1:size(matchInfo.match,2)
    corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
end

axes(handles.axes6);
plotMatches(img1,img2, v1', v2', corrMatrix);

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
 
 
 


% --- Executes on button press in checkboxSP.
%
%   Show extracted super pixels on the background
%
function checkboxSP_Callback(hObject, eventdata, handles)

handles = guidata(hObject);

img1 = handles.img1;
img2 = handles.img2;
img3 = combine2images(img1, img2);

checked = get(hObject,'Value');

if checked 
    replotaxes(handles.axes6, handles.img12SP);              
else
    replotaxes(handles.axes6, img3);
end

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})




% --- Executes on button press in pbReCalcSP.
%
%   Recalculate superpixel of the input images
%
function pbReCalcSP_Callback(hObject, eventdata, handles)

handles = guidata(hObject);

img1 = handles.img1;
img2 = handles.img2;

str = get(handles.editSP1, 'String');
nSP1 = str2num(str);

str = get(handles.editSP2, 'String');
nSP2 = str2num(str);

[img1SP.num, ... 
 img1SP.label, ...
 img1SP.boundary] = SLIC_Superpixels(im2uint8(img1), nSP1, 20);
 

[img2SP.num, ... 
 img2SP.label, ...
 img2SP.boundary] = SLIC_Superpixels(im2uint8(img2), nSP2, 20);

handles.img12SP = combine2images(img1SP.boundary, img2SP.boundary);

% save new SP
handles.img1SP = img1SP;   
handles.img2SP = img2SP;   

% delete frames
handles.frames = cell(1,2);
handles.frames{1} = [];
handles.frames{2} = [];

% delete descriptors
handles.descr = cell(1,2);
handles.descr{1} = [];
handles.descr{2} = [];

% delete match info
handles.matched = 0;
handles.matchInfo.match = [];
handles.matchInfo.dist = [];
handles.matchInfo.sim = [];
    

set(handles.pbBuildGraphs,'Enable','off');   % Enable matching 

if get(handles.checkboxSP,'Value'); 
    replotaxes(handles.axes6, handles.img12SP);   
end;    

guidata(hObject,handles);
