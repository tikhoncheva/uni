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

% Last Modified by GUIDE v2.5 10-Dec-2014 18:00:27
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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ui1 (see VARARGIN)

% Choose default command line output for ui1
handles.output = hObject;
handles.img1selected = false;
handles.img2selected = false;

N = 2;
% cell of the key points
framesCell = cell(1,N); % Nx(6xK1) matrices
framesCell{1} = [];
framesCell{2} = [];
% cell of the descriptors
descrCell = cell(1,N); % Nx(128xK1) matrices
descrCell{1} = [];
descrCell{2} = [];
% number of interest points in each image
nV= zeros(N,1);

matchInfo.match = [];
matchInfo.dist = [];
matchInfo.sim = [];

handles.frames = framesCell;
handles.descr = descrCell;
handles.nV = nV;
handles.matchInfo = matchInfo;
handles.savepoints = false;

% handles.matchInfo = matchInfo;

guidata(hObject,handles); 

% set parameters

% Piotr Dollar toolbox
addpath('../../edges-master/');
addpath(genpath('../../piotr_toolbox_V3.26/'));


% VL_Library
%  VLFEAT_Toolbox = '/home/kitty/Documents/Uni/Master/vlfeat-0.9.19/toolbox/';
addpath('/export/home/etikhonc/Documents/vlfeat-0.9.19/toolbox/');
run vl_setup.m

addpath([ '.' filesep 'Matching' ]);

addpath(genpath(['..' filesep '..' filesep 'RRWM_release_v1.22']));

set(handles.axes3,'Visible','off');   % Show Matching results

% UIWAIT makes ui1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ui1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
% hObject    handle to mOpenImg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'File Selector');
%global img1;
if  ~strcmp(filename,'')
    set(handles.filename1, 'String', filename);
    img1 = imread([pathname filesep filename]);
%     img1 = single(rgb2gray(img1));  % Convert the image to gray scale
    handles.img1 = img1;

%     img1 = repmat(img1,[1 1 3]);
%     img1 = ind2rgb(img1, jet(256));
    
    axes(handles.axes1);
    cla reset
    imagesc(img1), axis off;

    handles.img1selected = 1;
       
    handles.matched = 0;
    handles.matchInfo.match = [];
    handles.matchInfo.dist = [];
    handles.matchInfo.sim = [];

    handles.frames{1} = [];
    handles.frames{2} = [];
    handles.descr{2} = [];
    handles.descr{3} = [];    
    
    guidata(hObject,handles); 
    
    axes(handles.axes3);
    cla reset
    axes(handles.axes4);
    cla reset
    axes(handles.axes5);
    cla reset
    axes(handles.axes6);
    cla reset
    
    % if both images are selected
    if (handles.img2selected)
        set(handles.pushbuttonGetFeauters,'enable','on');
        
        % Plot two images together
        img2 = handles.img2;
        axes(handles.axes6); 
        img3 = combine2images(img1, img2);
        imagesc(img3);
    end  
end
% --------------------------------------------------------------------
%
%   Open image 2
%
function mOpenImg2_Callback(hObject, eventdata, handles)
% hObject    handle to mOpenImg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'File Selector');

if  ~strcmp(filename,'')
    set(handles.filename2, 'String', filename);
    img2 = imread([pathname filesep filename]);
    handles.img2 = img2;

    
    axes(handles.axes2);
    cla reset
    imagesc(img2), axis off;

    handles.img2selected = 1;  
    
    handles.matched = 0;
    handles.matchInfo.match = [];
    handles.matchInfo.dist = [];
    handles.matchInfo.sim = [];

    handles.frames{1} = [];
    handles.frames{2} = [];
    handles.descr{2} = [];
    handles.descr{3} = [];

    guidata(hObject,handles); 
    
    axes(handles.axes3);
    cla reset
    axes(handles.axes4);
    cla reset
    axes(handles.axes5);
    cla reset
    axes(handles.axes6);
    cla reset
    
    % if both images are selected
    if (handles.img1selected)
        set(handles.pushbuttonGetFeauters,'enable','on');
        
        % Plot two images together
        img1 = handles.img1;
        axes(handles.axes6); 
        img3 = combine2images(img1, img2);
        imagesc(img3);
    end  
end
      

% --- Executes on button press in pushbuttonGetFeauters.
%
% Compute features on the both images
%
function pushbuttonGetFeauters_Callback(hObject, eventdata, handles)

axes(handles.axes6);
cla reset

handles.matched = 0;
guidata(hObject,handles); 


set(handles.checkShowDG,'Value', 0);   % Show Dependency Graph
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors

set(handles.axes6,'Visible', 'on');
set(handles.axes3,'Visible','off');   % Show Matching results
set(handles.pushbuttonInitialMatch,'enable','on');
set(handles.pushbuttonClearAll,'Enable','on');   % Show Matching results
set(handles.pbMatchingAlg,'Enable','off');   % Enable matching 

% ---------------------------------------------------------------

N = 2; % number of images
img1 = handles.img1;
img2 = handles.img2;

axes(handles.axes1);
cla reset
imagesc(img1), axis off;

axes(handles.axes2);
cla reset
imagesc(img2), axis off;

% edge points on each images
edgesCell = cell(1,N);

% descriptors of the edge points on each images
edgeDescrCell = cell(1,N);

% Extract edge points


[F1, D1] = computeDenseSIFT(img1);
[F2, D2] = computeDenseSIFT(img2);

edgesCell{1} = F1;
edgesCell{2} = F2;

edgeDescrCell{1} = D1;
edgeDescrCell{2} = D2;
 
handles.edges = edgesCell;
handles.edgeDescr = edgeDescrCell;
handles.matched = 0;

handles.savepoints = 0;

guidata(hObject,handles);

% Plot two images together
axes(handles.axes6); 
img3 = combine2images(img1, img2);
imagesc(img3);

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})


% --- Executes on button press in pushbuttonInitialMatch.
% 
% Show candidate matches py clicking on the point
% (see also axes6_ButtonDownFcn)
% 
function pushbuttonInitialMatch_Callback(hObject, eventdata, handles)

set(handles.checkShowDG,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors

% ---------------------------------------------------------------

handles = guidata(hObject);

handles.matched = 0;

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

axes(handles.axes6);
cla reset
% combine two images in one by putting them one next to the other
ihight = max(size(img1,1),size(img2,1));
if size(img1,1) < ihight
    img1(ihight,1,1) = 0;
end
if size(img2,1) < ihight
    img2(ihight,1,1) = 0;
end

img3 = cat(2,img1,img2);
imagesc(img3);

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(handles.pushbuttonClearAll,'Enable','on');   % Show Matching results



% --- Executes on mouse press over axes background.
% 
% Show candidate matches py clicking on the point
% (see also axes6_ButtonDownFcn)
% 
function axes6_ButtonDownFcn(hObject, eventdata, handles)

set(handles.axes3,'Visible','off');   % Show Matching results
axes(handles.axes6);

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


% get current position of the mouse
cP = get(gca,'Currentpoint');
x = cP(1,1);
y = cP(1,2);
[x,y]

global newPoint;
parametersNewPoint;
newPoint.coords = [x,y];

% find nearest edge point to the clicked point
nn = knnsearch(edges{1}(1:2,:)',[x,y]);

x = edges{1}(1,nn);
y = edges{1}(2,nn);

x = 2*floor(x/2) + 1; 
y = 2*floor(y/2) + 1;


%  replot if user dont want to save points
if ~handles.savepoints
    % replot background
    cla reset
    % combine two images in one by putting them one next to the other
    ihight = max(size(img1,1),size(img2,1));
    if size(img1,1) < ihight
      img1(ihight,1,1) = 0;
    end
    if size(img2,1) < ihight
      img2(ihight,1,1) = 0;
    end

    img3 = cat(2,img1,img2);
    imagesc(img3)
    
    set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
    set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
end

% if we have clciked ont he first image
if (x <= size(img1,2) && y <= size(img1,1))    
    % get descriptor of the point on each scale
    ind = find(edges{1}(1,:) == x & edges{1}(2,:) == y); 
    
    neighborlist = []; %zeros(1, numel(ind)*knn);
    vallist = []; %zeros(1, numel(ind)*knn);
  
    for j = 1:numel(ind)
%         [matches, sim] = crosscorelation( double(edgeDesc{1}(:,ind(j))),...
%                                            double(edgeDesc{2}),...
%                                            mparam.kNN);
          
        
        [matches, sim] = cosinesimilaruty( double(edgeDesc{1}(:,ind(j))),...
                                           double(edgeDesc{2}),...
                                           mparam.kNN);
          
%         dist = sum(abs(bsxfun(@minus,double(edgeDesc{2}),...
%                                                double(edgeDesc{1}(:,ind(j))))));
%         
%         dist = dist./max(dist(:));
%         [val,nnInd] = sort(dist);
                                           
%         a = (j-1)*mparam.kNN + 1;
%         b = j*mparam.kNN;
%         neightborlist(a:b) = nnInd(1:knn);
%         vallist(a:b) = val(1:knn);
        neighborlist = [neighborlist, matches];
        vallist = [vallist, sim];
        
        for k = 1:mparam.kNN
            X2 = edges{2}(1,matches(k)) + size(img1,2);
            Y2 = edges{2}(2,matches(k));
            rectangle('Position',[X2-5,Y2-5,10,10],'FaceColor','y');
        end
    end
    
    nnInd = eliminate_closed_features(edges{2}(1:2,neighborlist), vallist);
    
    newPoint.neighbors = neighborlist(nnInd);
    newPoint.simvals =  vallist(nnInd)';
    
    newPoint.frame = edges{1}(:,nn);
    newPoint.descr = edgeDesc{1}(:,nn);
    newPoint.neighborsFrames = edges{2}(:,newPoint.neighbors);
    newPoint.neighborsDescrs = edgeDesc{2}(:,newPoint.neighbors);
    
    for i = 1:numel(nnInd)
        X2 = edges{2}(1,neighborlist(nnInd(i)))+ size(img1,2);
        Y2 = edges{2}(2,neighborlist(nnInd(i)));

        line([x,X2],[y,Y2],'LineWidth',1,'Color','g');
        rectangle('Position',[X2-3,Y2-3,6,6],'FaceColor','r');
    end    
    rectangle('Position',[x-3,y-3,6,6],'FaceColor','r');  
    
end    
    
    
% save points to match them with MPM
if handles.savepoints
    set(handles.pbMatchingAlg,'Enable','on');   % Enable matching 

    % get already saved frames, descriptors and matches
    framesCell = handles.frames;
    descrCell = handles.descr;
    matchInfo = handles.matchInfo; 

    F1 = size(framesCell{1},2)+1;
    D2 = size(descrCell{2},2)+1;

    % add new point to frames and descr on the first images
    framesCell{1} = [framesCell{1}, newPoint.frame];      
    descrCell{1} = [descrCell{1}, newPoint.descr];
    % add all matches point to the frames, descr on the second image
    framesCell{2} = [framesCell{2}, newPoint.neighborsFrames ];
    descrCell{2} = [descrCell{2}, newPoint.neighborsDescrs]; 
    % add new matches
    
    nNewMatches = numel(newPoint.neighbors);
    matchInfo.match = [matchInfo.match [F1*ones(1,nNewMatches);...
                                        D2:D2+nNewMatches-1]];
    matchInfo.sim = [matchInfo.sim; newPoint.simvals];
    matchInfo.dist = max(newPoint.simvals(:)) - newPoint.simvals';

    % update saved values
    handles.frames = framesCell;
    handles.descr = descrCell;
    handles.matchInfo = matchInfo; 
end



% --- Executes on button press in pbMatchingAlg.
%
% Do matching algorithm on the selected points
%
function pbMatchingAlg_Callback(hObject, eventdata, handles)

set(handles.checkShowDG,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors

% ---------------------------------------------------------------

handles = guidata(hObject);

img1 = handles.img1;
img2 = handles.img2;

framesCell = handles.frames;
descrCell = handles.descr;
matchInfo = handles.matchInfo; 

% handles.matched = 0;
% guidata(hObject,handles);

% set parameters

SetParameters;

N = 2;

% Cell of the dependency graphs
DG = cell(1,N); % nV_i x nV_i

size(framesCell{1})
v1 = framesCell{1}(1:2,:);
v2 = framesCell{2}(1:2,:);

nV1 = size(framesCell{1},2);
nV2 = size(framesCell{2},2);

% 
corrMatrix = zeros(nV1,nV2);
for ii = 1:size(matchInfo.match,2)
    corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
end

handles.InitialMatching = corrMatrix;

% ------------ Step 3
%
% Build Dependency Graphs (DG) on each image
%

% Min Degree of the graph
str = get(handles.editMinDegree, 'String');
minDeg = str2num(str);

DG{1} = buildDependGraph_RefImage(framesCell{1}, minDeg);
DG{2} = buildDependGraph(framesCell{2}, DG{1}, matchInfo);
% DG{2} = buildDependGraph_RefImage(framesCell{2}, minDeg);
set(handles.checkShowDG,'Enable','on');   % Show Dependency graph


%  Reweighted Random Walk
    
% compute initial affinity matrix

[AffMatrix,ratio] = initialAffinityMatrix(v1, v2, DG{1}, DG{2}, matchInfo);
set(handles.editRatio,'String',ratio); 



% conflict groups
corrMatrix = zeros(nV1,nV2);
for ii = 1:size(matchInfo.match,2)
    corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
end
[L12(:,1), L12(:,2)] = find(corrMatrix);
[ group1, group2 ] = make_group12(L12);

% run RRW Algorithm 
x = RRWM(AffMatrix, group1, group2);

X = greedyMapping(x, group1, group2);

% X = zeros(size(cdata.E12)); X(find(cdata.E12)) = x;
% X = discretisationMatching_hungarian(x,cdata.E12); X = X(find(cdata.E12));

disp(AffMatrix(x>0.5,x>0.5))

% Objective = x'*AffMatrix * x;
    
newCorrMatrix = zeros(nV1, nV2);
for i=1:size(L12,1)
	newCorrMatrix(L12(i,1), L12(i,2)) = X(i);
end    


% visialize results of matching
set(handles.axes6,'Visible', 'off');   % Hide plot with selected points

axes(handles.axes3);
set(handles.axes3,'Visible','on');   % Show Matching results
cla reset

plotMatches(img1,img2, v1', v2', newCorrMatrix);     

% ---------------------------------------------------------------
handles.frames = framesCell;
handles.descr = descrCell;
handles.DG = DG;
handles.InitialMatching =corrMatrix;
handles.newMatching = newCorrMatrix;
handles.matched = 1;

guidata(hObject,handles);


handles = guidata(hObject);
set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})


set(handles.checkboxShowInitM,'Enable','on');   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Enable','on');   % Show Neighbors
set(handles.pushbuttonClearAll,'Enable','on');   % Show Matching results


% --- Executes on mouse press over axes background.
%
% Show initial candidates and the best match according to the algorithm
%
function axes3_ButtonDownFcn(hObject, eventdata, handles)

% set(handles.axes6, 'Visible', 'off');
% axes(handles.axes3);
% cla 

img1 = handles.img1;
img2 = handles.img2;
f = handles.frames;
d = handles.descr;

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

axes(handles.axes3);
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
      
% vl_plotsiftdescriptor( d{1}(:,nn), feature_nn) ;
% vl_plotsiftdescriptor( d{2}(:,nn_2), feature_nn_2) ;
%       

% cut patches
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
   
   set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
   set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})  
   
end

axes(handles.axes3);
set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})    


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
    
    axes(handles.axes1);
    imagesc(img1),colormap(gray), axis off;

    axes(handles.axes2);
    imagesc(img2),colormap(gray), axis off;
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

axes(handles.axes3);
cla reset
if checked 
    plotMatches(img1,img2, v1', v2', newMatching, InitialMatching);           

else
    plotMatches(img1,img2, v1', v2', newMatching);  
end

set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})


% --- Executes on button press in pushbuttonClearAll.
%
% Clear all
%
function pushbuttonClearAll_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
set(handles.axes6, 'Visible', 'off');
axes(handles.axes3);
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
    ihight = max(size(img1,1),size(img2,1));
    if size(img1,1) < ihight
        img1(ihight,1,1) = 0;
    end
    if size(img2,1) < ihight
        img2(ihight,1,1) = 0;
    end

    img3 = cat(2,img1,img2);

    imagesc(img3)
end

set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
guidata(hObject,handles);
% set(handles.axes6,'Visible', 'off');   % Hide plot with selected points


% --- Executes on button press in pbSaveCurrentPoint.
%
%  save current point
%
function pbSaveCurrentPoint_Callback(hObject, eventdata, handles)

set(handles.pbMatchingAlg,'Enable','on');   % Enable matching 
% get already saved frames, descriptors and matches
handles = guidata(hObject);

framesCell = handles.frames;
descrCell = handles.descr;
matchInfo = handles.matchInfo; 

F1 = size(framesCell{1},2)+1;
D2 = size(descrCell{2},2)+1;

global newPoint

% add new point to frames and descr on the first images
framesCell{1} = [framesCell{1}, newPoint.frame];      
descrCell{1} = [descrCell{1}, newPoint.descr];
% add all matches point to the frames, descr on the second image
framesCell{2} = [framesCell{2}, newPoint.neighborsFrames ];
descrCell{2} = [descrCell{2}, newPoint.neighborsDescrs]; 
% add new matches

nNewMatches = numel(newPoint.neighbors);
matchInfo.match = [matchInfo.match [F1*ones(1,nNewMatches);...
                                    D2:D2+nNewMatches-1]];
matchInfo.sim = [matchInfo.sim; newPoint.simvals];
matchInfo.dist = max(newPoint.simvals(:)) - newPoint.simvals';

% update saved values
handles.frames = framesCell;
handles.descr = descrCell;
handles.matchInfo = matchInfo; 
guidata(hObject,handles); 


% --- Executes on button press in pbClear.
function pbClear_Callback(hObject, eventdata, handles)
% hObject    handle to pbClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
set(handles.axes3, 'Visible', 'off');
axes(handles.axes6);
cla reset

img1 = handles.img1;
img2 = handles.img2;


ihight = max(size(img1,1),size(img2,1));
if size(img1,1) < ihight
    img1(ihight,1,1) = 0;
end

if size(img2,1) < ihight
    img2(ihight,1,1) = 0;
end

img3 = cat(2,img1,img2);

imagesc(img3)

set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})




% --- Executes on button press in pbSavePoints.
%
%   Save frames, descriptors, matchInfo of previously selected points
%
function pbSavePoints_Callback(hObject, eventdata, handles)

set(handles.pbMatchingAlg,'Enable','on');   % Enable matching 
% get already saved frames, descriptors and matches
handles = guidata(hObject);

framesCell = handles.frames;
descrCell = handles.descr;
matchInfo = handles.matchInfo; 

n = size(framesCell{1},2)

save(sprintf('graph_n%d.mat', n) ,'framesCell',...
                                  'descrCell', ...
                                  'matchInfo');

% --- Executes on button press in pbLoadPoints.
%
%  Load frames, descriptors, matchInfo of previously selected points
%  from a file
%
function pbLoadPoints_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.mat'}, 'File Selector');
%global img1;
if  ~strcmp(filename,'')
    % read data from file
    load( [pathname filesep filename] ,'-mat', 'framesCell',...
                           'descrCell', ...
                           'matchInfo')
    
    % rewrite current variables
    handles = guidata(hObject);
    
    handles.frames = framesCell;
    handles.descr = descrCell;
    handles.matchInfo = matchInfo; 

    guidata(hObject,handles); 
    
    % plot points and matches
    
    img1 = handles.img1;
    img2 = handles.img2;

    ihight = max(size(img1,1),size(img2,1));
    if size(img1,1) < ihight
        img1(ihight,1,1) = 0;
    end
    if size(img2,1) < ihight
        img2(ihight,1,1) = 0;
    end

    img3 = cat(2,img1,img2);
    imagesc(img3);
    
    nV1 = size(framesCell{1},2);
    nV2 = size(framesCell{2},2);
    
    v1 = framesCell{1}(1:2,:);
    v2 = framesCell{2}(1:2,:);
    
    corrMatrix = zeros(nV1,nV2);
    for ii = 1:size(matchInfo.match,2)
        corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
    end

    plotMatches(img1,img2, v1', v2', corrMatrix);
    
    set(handles.pbMatchingAlg,'Enable','on');   % Enable matching 
end
