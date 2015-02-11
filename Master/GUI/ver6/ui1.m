function varargout = ui1(varargin)

% ui1 MATLAB code for ui1.fig
% Last Modified by GUIDE v2.5 11-Feb-2014 17:57:54


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

% % Used libraries

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

set(handles.axes3,'XTick',[]);
set(handles.axes3,'YTick',[]);

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
% 
%
%



% --------------------------------------------------------------------
%
%   open image 1
%
function mOpenImg1_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    set(handles.filename1, 'String', filename);
    img1 = imread([pathname filesep filename]);
    
    [img1SP.num, ... 
     img1SP.label, ...
     img1SP.boundary] = SLIC_Superpixels(im2uint8(img1), 100, 20);
 
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
     img2SP.boundary] = SLIC_Superpixels(im2uint8(img2), 500, 20);
    
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
% [F1, D1] = computeDenseSIFT(img1);
% [F2, D2] = computeDenseSIFT(img2);
% 
% zerocol_ind = all( ~any(D1), 1);
% D1(:, zerocol_ind) = []; % remove zero columns
% F1(:, zerocol_ind) = [];
% 
% zerocol_ind = all( ~any(D2), 1);
% D2(:, zerocol_ind) = []; % remove zero columns
% F2(:, zerocol_ind) = [];
% 
% edgesCell{1} = F1;
% edgesCell{2} = F2;
% 
% edgeDescrCell{1} = D1;
% edgeDescrCell{2} = D2;

load( 'frames.mat' , 'edgesCell', 'edgeDescrCell');
 
handles.edges = edgesCell;
handles.edgeDescr = edgeDescrCell;
handles.matched = 0;

guidata(hObject,handles); 

% save( 'frames.mat' ,'edgesCell', 'edgeDescrCell');


% Find correspondencies between two images

matchInfo.match = [];
matchInfo.sim = [];
matchInfo.dist = [];

SetParameters;

% str=get(handles.edit3, 'String');
% mparam.kNN= str2num(str);
% knn = mparam.kNN;
% 
% %/------------------------------------------------------------------------
% % for each feature on the first image
% for i=1:size(edgesCell{1},2)
% 
%     x = edgesCell{1}(1,i);
%     y = edgesCell{1}(2,i);
%     
%     % do votig to stabilize the algorithm
%     [best_neighbors, best_neighbors_vals] = votingSLIC([x,y], edgesCell, edgeDescrCell,...
%                                                        handles.img1SP, ...
%                                                        handles.img2SP, ...
%                                                        mparam); 
%     
%    
%     nnInd = eliminate_closed_features(edgesCell{2}(1:2,best_neighbors), best_neighbors_vals);
%     
% 
%     % save mathces
%     neighbors = best_neighbors(nnInd);
%     simvals =  best_neighbors_vals(nnInd)';
%     
%     nMatches = numel(neighbors); 
%     maxsimval = 1; % max(newPoint.simvals(:));
%     
%     matchInfo.match = [matchInfo.match [i*ones(1,nMatches); neighbors]];
%     matchInfo.sim = [matchInfo.sim; simvals];
%     matchInfo.dist = [ matchInfo.dist, maxsimval - simvals'];    
%     
% end    
% save( 'matchInfo.mat' ,'matchInfo');

load( 'matchInfo.mat' , 'matchInfo');
handles.matchInfo = matchInfo;

guidata(hObject,handles); 

% % ---------------------------------------------------------------
% set(handles.axes3, 'Visible', 'off');
% set(handles.axes6,'Visible', 'on');    

% img3 = combine2images(img1,img2);
% replotaxes(handles.axes6, img3);

set(handles.checkShowDG,'Value', 0);   % Show Dependency Graph
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors

set(handles.pbMatchingAlg,'Enable','on');   % Enable matching 

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

% global newPoint;
% parametersNewPoint;
% newPoint.coords = [x,y];
% 
% % find nearest edge point to the clicked point
% nn = knnsearch(edges{1}(1:2,:)',[x,y]);
% 
% x = edges{1}(1,nn);
% y = edges{1}(2,nn);
% 
% x = 2*floor(x/2) + 1; 
% y = 2*floor(y/2) + 1;
% 
% 
% %  replot if user dont want to save points
% if ~handles.savepoints
%     % replot background
%     img3 = combine2images(img1, img2);
%     replotaxes(handles.axes6, img3)
%     
%     axes(handles.axes6);
%     set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
%     set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
% end
% 
% % if we have clicked on the first image
% if (x <= size(img1,2) && y <= size(img1,1))
%     
%     % get descriptor of the point on each scale
%     ind = find(edges{1}(1,:) == x & edges{1}(2,:) == y); 
%     
%     neighborlist = []; %zeros(1, numel(ind)*knn);
%     vallist = []; %zeros(1, numel(ind)*knn);
%   
%     % do votig to stabilize the algorithm
%     [best_neighbors, best_neighbors_vals, img12SP] = votingSLIC([x,y], edges, edgeDesc,...
%                                                        handles.img1SP, ...
%                                                        handles.img2SP, ...
%                                                        mparam);
%                                                       
%     handles.img12SP = img12SP;
%     
%     axes(handles.axes6);
%     for j = 1:numel(ind)
% %         [matches, sim] = crosscorelation( double(edgeDesc{1}(:,ind(j))),...
% %                                            double(edgeDesc{2}),...
% %                                            mparam.kNN);
%           
%         
% %         [matches, sim] = cosinesimilaruty( double(edgeDesc{1}(:,ind(j))),...
% %                                            double(edgeDesc{2}),...
% %                                            mparam.kNN);
% 
% %         [matches, sim] = matchSIFTdescr( double(edgeDesc{1}(:,ind(j))),...
% %                                            double(edgeDesc{2}),...
% %                                            mparam.kNN);
% 
% % Euclidian distance between descriptors
%         diff = bsxfun(@minus,double(edgeDesc{2}),...
%                              double(edgeDesc{1}(:,ind(j))));
%         dist = sqrt(sum(diff.^2));
%         dist = dist./max(dist(:));
%         [val,nnInd] = sort(dist); 
%         
%         sim = val(1:mparam.kNN);
%         matches = nnInd(1:mparam.kNN);
% 
% %         similarityVec = dotsimilarity( double(edgeDesc{1}(:,ind(j))'),...
% %                                            double(edgeDesc{2}'));                                  
% %         [val,nnInd] = sort(similarityVec, 'descend'); 
% %         
% %         sim = val(1:mparam.kNN);
% %         matches = nnInd(1:mparam.kNN);                                       
% 
% 
% % N.B. : According to the similarity function we eliminate later
% % points with the biggest or smallest similarity values
% 
% %         dist = sum(abs(bsxfun(@minus,double(edgeDesc{2}),...
% %                                                double(edgeDesc{1}(:,ind(j))))));
% %         
% %         dist = dist./max(dist(:));
% %         [val,nnInd] = sort(dist);
%                                            
% %         a = (j-1)*mparam.kNN + 1;
% %         b = j*mparam.kNN;
% %         neightborlist(a:b) = nnInd(1:knn);
% %         vallist(a:b) = val(1:knn);
%         neighborlist = [neighborlist, matches];
%         vallist = [vallist, sim];
%         
%         for k = 1:mparam.kNN
%             X2 = edges{2}(1,matches(k)) + size(img1,2);
%             Y2 = edges{2}(2,matches(k));
%             rectangle('Position',[X2-5,Y2-5,10,10],'FaceColor','y');
%         end
%     end
%     
%     
%    
%     nnInd = eliminate_closed_features(edges{2}(1:2,best_neighbors), best_neighbors_vals);
% %     nnInd = eliminate_closed_features(edges{2}(1:2,neighborlist), vallist);
%     
% %     newPoint.neighbors = neighborlist(nnInd);
% %     newPoint.simvals =  vallist(nnInd)';
%     
% 
%     newPoint.neighbors = best_neighbors(nnInd);
%     newPoint.simvals =  best_neighbors_vals(nnInd)';
%     
%     newPoint.frame = edges{1}(:,nn);
%     newPoint.descr = edgeDesc{1}(:,nn);
%     newPoint.neighborsFrames = edges{2}(:,newPoint.neighbors);
%     newPoint.neighborsDescrs = edgeDesc{2}(:,newPoint.neighbors);
%     
%     for i = 1:numel(nnInd)
%         X2 = edges{2}(1,best_neighbors(nnInd(i)))+ size(img1,2);
%         Y2 = edges{2}(2,best_neighbors(nnInd(i)));
% 
%         line([x,X2],[y,Y2],'LineWidth',1,'Color','g');
%         rectangle('Position',[X2-3,Y2-3,6,6],'FaceColor','r');
%     end    
%     rectangle('Position',[x-3,y-3,6,6],'FaceColor','r');  
%     
% end    
% 
% set(handles.pbSaveCurrentPoint,'Enable','on');   % Save current point
set(gca,'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_ButtonDownFcn, handles})


% --- Executes on button press in pbMatchingAlg.
%
% Do matching algorithm on the selected points
%
function pbMatchingAlg_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

img1 = handles.img1;
img2 = handles.img2;

edgesCell = handles.edges;
descrCell = handles.edgeDescr;
matchInfo = handles.matchInfo; 

% handles.matched = 0;
% guidata(hObject,handles);

% set parameters

SetParameters;

N = 2;

% Cell of the dependency graphs
DG = cell(1,N); % nV_i x nV_i
G = cell(1,N);

v1 = edgesCell{1}(1:2,:);
v2 = edgesCell{2}(1:2,:);

nV1 = size(edgesCell{1},2);
nV2 = size(edgesCell{2},2);

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

[G{1}, DG{1}] = buildGraph(edgesCell{1}, descrCell{1}, handles.img1SP);
[G{2}, DG{2}] = buildGraph(edgesCell{2}, descrCell{2}, handles.img2SP);


handles.DG = DG;
handles.G = G;


% ------------ Step 4  Reweighted Random Walk
    
% compute initial affinity matrix

% [AffMatrix,ratio] = initialAffinityMatrix1(v1, v2, DG{1}, DG{2}, matchInfo);
AffMatrix = initialAffinityMatrix2(v1, v2, DG{1}, DG{2}, matchInfo);


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

disp(AffMatrix(x>0.5,x>0.5))

% Objective = x'*AffMatrix * x;
    
newCorrMatrix = zeros(nV1, nV2);
for i=1:size(L12,1)
	newCorrMatrix(L12(i,1), L12(i,2)) = X(i);
end    


handles.InitialMatching =corrMatrix;
handles.newMatching = newCorrMatrix;
handles.matched = 1;

guidata(hObject,handles);

% ---------------------------------------------------------------

% visialize results of matching
set(handles.axes6,'Visible', 'off');   % Hide plot with selected points
set(handles.axes3,'Visible','on');   % Show Matching results

axes(handles.axes3);
cla reset
img3 = combine2images(img1, img2);
replotaxes(handles.axes3, img3);
    
% plotMatches(img1,img2, v1', v2', newCorrMatrix);     


set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})

set(handles.checkShowDG,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowInitM,'Value', 0);   % Show Initial Matches
set(handles.checkboxShowNeighbors,'Value', 0);   % Show Neighbors

% set(handles.pbSaveCurrentPoint,'Enable','on');   % Save current point

set(handles.checkShowDG,'Enable','on');   % Show Dependency graph
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

G = handles.G;

checked = get(hObject,'Value');

if checked 
    axes(handles.axes1);
    draw_graph(img1, 'Image 1', G{1}); 
    axes(handles.axes2);
    draw_graph(img2, 'Image 1', G{2});                                                  
                                                 
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
edgesCell = handles.frames;

v1 = edgesCell{1}(1:2,:);
v2 = edgesCell{2}(1:2,:);

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
axes(handles.axes3);
cla reset

img1 = handles.img1;
img2 = handles.img2;

if (handles.matched)
    edgesCell = handles.frames;
    
    v1 = edgesCell{1}(1:2,:);
    v2 = edgesCell{2}(1:2,:);
    
    newMatching = handles.newMatching;
    plotMatches(img1,img2, v1', v2', newMatching);

else
    img3 = combine2images(img1, img2);
    replotaxes(handles.axes3, img3);
end

set(gca,'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
guidata(hObject,handles);




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
    

set(handles.pbMatchingAlg,'Enable','off');   % Enable matching 

if get(handles.checkboxSP,'Value'); 
    replotaxes(handles.axes6, handles.img12SP);   
end;    

guidata(hObject,handles);
