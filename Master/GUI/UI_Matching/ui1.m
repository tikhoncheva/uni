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

% Last Modified by GUIDE v2.5 14-Nov-2014 13:38:20
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

% Update handles structure
guidata(hObject, handles);

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
function mOpenImg1_Callback(hObject, eventdata, handles)
% hObject    handle to mOpenImg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.jpg'}, 'File Selector');
%global img1;
if  ~strcmp(filename,'')
    set(handles.filename1, 'String', filename);
    img1 = imread([pathname filesep filename]);
    img1 = single(rgb2gray(img1));  % Convert the image to gray scale
    handles.img1 = img1;

    axes(handles.axes1);
    imagesc(img1),colormap(gray), axis off;

    handles.img1selected = 1;
    guidata(hObject,handles);


    if (handles.img2selected)
        set(handles.pushbuttonStart,'enable','on');
    end    
end
% --------------------------------------------------------------------
function mOpenImg2_Callback(hObject, eventdata, handles)
% hObject    handle to mOpenImg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.jpg'}, 'File Selector');

if  ~strcmp(filename,'')
    set(handles.filename2, 'String', filename);
    img2 = imread([pathname filesep filename]);
    img2 = single(rgb2gray(img2));  % Convert the image to gray scale
    handles.img2 = img2;

    axes(handles.axes2);
    imagesc(img2),colormap(gray), axis off;

    handles.img2selected = 1;
    guidata(hObject,handles);


    if (handles.img1selected)
        set(handles.pushbuttonStart,'enable','on');
    end    
end
        
% --- Executes on button press in pushbuttonStart.
% Match two selected images
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes3);
cla reset

set(handles.checkShowDG,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors
set(handles.checkboxShowInitialFeatures,'Value', 0);   % Show Initial Features
% ---------------------------------------------------------------

% set parameters

% MPM code
 addpath(genpath(['..' filesep '..' filesep 'MPM_release_v3']));
% addpath(genpath(['..' filesep  'MPM_release_v3']));

% VL_Library

%  VLFEAT_Toolbox = '/home/kitty/Documents/Uni/Master/vlfeat-0.9.19/toolbox/';
 VLFEAT_Toolbox = '/export/home/etikhonc/Documents/vlfeat-0.9.19/toolbox/';

addpath(genpath(VLFEAT_Toolbox));
addpath([ '.' filesep 'Matching' ]);

run vl_setup.m

clc;

SetParameters;
% get kNN from the GUI
str=get(handles.edit3, 'String');
mparam.kNN= str2num(str);

N = 2; % number of images
img1 = handles.img1;
img2 = handles.img2;

% cell of the keypoints on the each image
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nV= zeros(N,1);

% Cell of the dependency graphs
DG = cell(1,N); % nV_i x nV_i


% ------------ Step 1
%
% Extract feature points
% img 1
[ framesCell{1}, descrCell{1}, nV(1),runtime ] = ...
                                    find_features_harlap_vl(img1, false, 10);
fprintf(' %f secs elapsed for finding %d interest points on the image %d \n', ...
                        runtime, nV(1) , 1);                                  
% img 2    
[ framesCell{2}, descrCell{2}, nV(2), runtime ] = ...
                                    find_features_harlap_vl(img2, false);

fprintf(' %f secs elapsed for finding %d interest points on the image %d \n', ...
                        runtime, nV(2) , 2);                                

handles.framesInitial = framesCell;
% ------------


v1 = framesCell{1}(1:2,:);
nV1 = nV(1,1);
                    
% ------------ Step 2      
%
% Reduce number of keypoints on the second image in each pair of images
% For each keypoint on the ref image find theirs k nearest neighbors on 
% the second image
% The points that are not neighbors of some point on the ref image will be
% deleted


matchInfo = make_initialmatches2(descrCell{1},descrCell{2}, mparam); 
    
% delete all features that are not neighbors of some point on the
% reference image

[ uniq_feat2, ~, ~ ] = unique(matchInfo.match(2,:));
nV(2) = size(uniq_feat2, 2);
framesCell{2} = framesCell{2}(:, uniq_feat2);
descrCell{2}  =  descrCell{2}(:, uniq_feat2); 
   

% framesCell{2} = framesCell{2}(:, matchInfo.match(2,:));
% descrCell{2}  =  descrCell{2}(:, matchInfo.match(2,:)); 
    
matchInfo = make_initialmatches2(descrCell{1},descrCell{2}, mparam); 

corrMatrix = zeros(nV(1),nV(2));
for ii = 1:size(matchInfo.match,2)
    corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
end

% ------------ Step 3
%
% Build Dependency Graphs (DG) on each image
%

%minDeg = 30;    % Min Degree of the graph
% get kNN from the GUI
str = get(handles.editMinDegree, 'String');
minDeg = str2num(str);

DG{1} = buildDependGraph_RefImage(framesCell{1}, minDeg);
DG{2} = buildDependGraph(framesCell{2}, DG{1}, matchInfo);
% DG{2} = buildDependGraph_RefImage(framesCell{2}, minDeg);
set(handles.checkShowDG,'Enable','on');   % Show Dependency graph


%  Max-Pooling Strategy
 
v2 = framesCell{2}(1:2,:);
nV2 = nV(2,1);
%                                     
   
Adj1 = DG{1};
Adj2 = DG{2};

    
% compute initial affinity matrix
[AffMatrix,ratio] = initialAffinityMatrix(v1, v2, Adj1, Adj2, matchInfo);
 set(handles.editRatio,'String',ratio); 
% run MPM  

% conflict groups
corrMatrix = zeros(nV1,nV2);
for ii = 1:size(matchInfo.match,2)
    corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
end
[L12(:,1), L12(:,2)] = find(corrMatrix);
[ group1, group2 ] = make_group12(L12);

x = MPM(AffMatrix, group1, group2);
% Objective = x'*AffMatrix * x;
    
CorrMatrix = zeros(nV1, nV2);
for i=1:size(L12,1)
	CorrMatrix(L12(i,1), L12(i,2)) = x(i);
end    

newCorrMatrix = roundMatrix(CorrMatrix);

global newMatches;
newMatches = newCorrMatrix;

% visialize results of matching
axes(handles.axes3);
plotMatches(img1,img2, v1', v2', newCorrMatrix);     

% ---------------------------------------------------------------
handles.frames = framesCell;
handles.descr = descrCell;
handles.nV = nV;
handles.DG = DG;
handles.InitialMatching = CorrMatrix;
handles.newMatching = newCorrMatrix;

guidata(hObject,handles);

% set(gca,'ButtonDownFcn', @mouseclick_callback)
% set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)
set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})

set(handles.axes3,'Visible','on');   % Show Matching results
set(handles.checkboxShowInitM,'Enable','on');   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Enable','on');   % Show Neighbors
set(handles.pushbuttonClearAll,'Enable','on');   % Show Matching results
set(handles.checkboxShowInitialFeatures,'Enable','on');   % Show Initial Features




% --- Executes on button press in checkShowDG.
% Show dependency  graphs
function checkShowDG_Callback(hObject, eventdata, handles)
% hObject    handle to checkShowDG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
% Show Initial Matches
function checkboxShowInitM_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowInitM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowInitM
img1 = handles.img1;
img2 = handles.img2;
framesCell = handles.frames;

v1 = framesCell{1}(1:2,:);
v2 = framesCell{2}(1:2,:);

InitialMatching = handles.InitialMatching;
newMatching = handles.newMatching;

checked = get(hObject,'Value');

axes(handles.axes3);
if checked 
    plotMatches(img1,img2, v1', v2', newMatching, InitialMatching);           

else
    plotMatches(img1,img2, v1', v2', newMatching);  
end

set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})

% set(gca,'ButtonDownFcn', @mouseclick_callback)
% set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)



% --- Executes on mouse press over axes background.
%
% Click on the image with matches results
%
function axes3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cP = get(gca,'Currentpoint');
n = cP(1,1);
m = cP(1,2);

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
      
vl_plotsiftdescriptor( d{1}(:,nn), feature_nn) ;
vl_plotsiftdescriptor( d{2}(:,nn_2), feature_nn_2) ;
      
%       set(gca,'ButtonDownFcn', @mouseclick_callback)
%       set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)
set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})      
      
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

axes(handles.axes3);

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
% -----------------



% --- Executes on button press in pushbuttonClearAll.
%
% Clear all
%
function pushbuttonClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

img1 = handles.img1;
img2 = handles.img2;
framesCell = handles.frames;

v1 = framesCell{1}(1:2,:);
v2 = framesCell{2}(1:2,:);

newMatching = handles.newMatching;
plotMatches(img1,img2, v1', v2', newMatching);

set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})

% set(gca,'ButtonDownFcn', @mouseclick_callback)
% set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)

% set(handles.checkShowDG,'Enable','off');   % Show DG
% set(handles.checkboxShowInitM,'Enable','off');   % Show Initial Matches



function editMinDegree_Callback(hObject, eventdata, handles)
% hObject    handle to editMinDegree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMinDegree as text
%        str2double(get(hObject,'String')) returns contents of editMinDegree as a double


% --- Executes during object creation, after setting all properties.
function editMinDegree_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinDegree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRatio_Callback(hObject, eventdata, handles)
% hObject    handle to editRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRatio as text
%        str2double(get(hObject,'String')) returns contents of editRatio as a double


% --- Executes during object creation, after setting all properties.
function editRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxShowNeighbors.
function checkboxShowNeighbors_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowNeighbors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowNeighbors


% --- Executes on button press in checkboxShowInitialFeatures.
%
% Show all initial features
%
function checkboxShowInitialFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowInitialFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkboxShowInitialFeatures,'Value');

    img1 = handles.img1;
    img2 = handles.img2;

    [~,n1, ~] = size(img1) ;

    framesCell = handles.frames;
    initialFrames = handles.framesInitial;

    initialFrames{2}(1,:)= initialFrames{2}(1,:) + n1;

    plot(initialFrames{2}(1,:),initialFrames{2}(2,:), 'r.')

else
    img1 = handles.img1;
    img2 = handles.img2;
    framesCell = handles.frames;

    v1 = framesCell{1}(1:2,:);
    v2 = framesCell{2}(1:2,:);

    newMatching = handles.newMatching;
    plotMatches(img1,img2, v1', v2', newMatching);

end

set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
