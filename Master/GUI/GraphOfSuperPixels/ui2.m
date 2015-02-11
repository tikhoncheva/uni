function varargout = ui2(varargin)
% UI2 MATLAB code for ui2.fig

% Last Modified by GUIDE v2.5 04-Feb-2015 13:47:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ui2_OpeningFcn, ...
                   'gui_OutputFcn',  @ui2_OutputFcn, ...
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


% --- Executes just before ui2 is made visible.
function ui2_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for ui2
handles.output = hObject;
guidata(hObject,handles); 

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
addpath(genpath('./Matching'));
clc;

set(handles.axes1,'XTick',[]);
set(handles.axes1,'YTick',[]);

set(handles.axes2,'XTick',[]);
set(handles.axes2,'YTick',[]);




% --- Outputs from this function are returned to the command line.
function varargout = ui2_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;





% --------------------------------------------------------------------
%
%   open image
%
function OpenImage_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');

if filename~=0
    set(handles.filename1, 'String', filename);
    img1 = imread([pathname filesep filename]);
    
    [img1SP.num, ... 
     img1SP.label, ...
     img1SP.boundary] = SLIC_Superpixels(im2uint8(img1),1000, 20);
 
    handles.img1 = img1;
    handles.img1SP = img1SP;   
    handles.img1selected = 1;
    
    replotaxes(handles.axes1, img1);
    
    guidata(hObject,handles); 
    
    set(handles.pbuttonBuildGraph, 'enable', 'on');

end

% --------------------------------------------------------------------
%
%   Build dependency graph
%
function pbuttonBuildGraph_Callback(hObject, eventdata, handles)

handles = guidata(hObject);
 
img1 = handles.img1;
img1SP = handles.img1SP;

replotaxes(handles.axes1, img1);

% Compute features on the both images

% Extract edge points and corresponding descriptors
[edges, descr] = computeDenseSIFT(img1);

zerocol_ind = all( ~any(descr), 1);
descr(:, zerocol_ind) = []; % remove zero columns
edges(:, zerocol_ind) = [];

handles.edges = edges;
handles.edgeDescr = descr;



% descr_dist = squareform(pdist(descr'));
% size(descr_dist)
% 
% descr_dist_g_0 = descr_dist>0;
% min_dist = min(descr_dist(descr_dist_g_0));
% max_dist = max(descr_dist(descr_dist_g_0));
% threshold = min_dist + 0.05*(max_dist - min_dist);
% descr_dist2 = ~logical(descr_dist > threshold);
% 
% ind = [];
% for j=1:size(descr_dist2,2)
%    if (numel(find(descr_dist2(:,j)==0))>0)
%        ind = [ind, j];
%    end
% end
% 
% CC = bwconncomp(descr_dist2);

    
% figure,
%     imagesc(img1), hold on;
%     plot(edges(1,:), edges(2, :), '*r')
%     for cc=2:CC.NumObjects
%         [x,y] = ind2sub(size(descr_dist2),CC.PixelIdxList{1,cc});
%         for i=1:size(x, 1)
%             line([edges(1,x(i)) edges(1,y(i)) ],...
%                  [edges(2,x(i)) edges(2,y(i)) ], 'Color', 'b')
%         end     
%     end
% 
% hold off    


% use knn - clustering algorithm to get rid of uninteresting points  

% descr = double(descr);
% colnorm = sqrt(sum(descr.^2,1));
% for j=1:size(descr,2)
%     descr(:,j) = descr(:,j) ./ colnorm(j);
% end

% k = 10;
% [~, assignments] = vl_kmeans(G.D, k, 'verbose', 'distance', 'l2', 'algorithm', 'ann');
% 
% group1 = find(assignments==1);
% group2 = find(assignments==2);
% group3 = find(assignments==3);

% figure, imagesc(imgSP.boundary), hold on;
%     plot(G.V(group1,1),G.V(group1,2), 'r*')
%     plot(G.V(group2,1),G.V(group2,2), 'g*')
%     plot(G.V(group3,1),G.V(group3,2), 'b*')
% hold off;
% Build dependency graph

DG1 = buildGraph(edges, descr, img1SP);
handles.DG = DG1;

% Show it on the axis2

axes(handles.axes2);
if get(handles.checkboxShowSP,'Value')
    draw_graph(img1SP.boundary, 'Image 1', DG1);              
else
    draw_graph(img1, 'Image 1', DG1);
end

% [IX,IY] = vl_grad(rgb2gray(img1));
% img2 = IX.*IX + IY.*IY;
% figure, imagesc(img2);
% 
% v1 = edges(1,:);
% v2 = edges(2,:);
% 
% img3 = zeros(size(img2));
% img3(sub2ind(size(img3),v2,v1))=img2(sub2ind(size(img2),v2,v1));
% figure, imagesc(img3);
% 
% maxgradval = max(find(img3>0))

% % v1 = DG1.E(:,1);
% % v2 = DG1.E(:,2);
% % n = size(DG1.V,1);
% % % Adjazent matrix of the graph
% % AdjM = zeros(n,n);
% % AdjM(sub2ind([n,n],v1,v2))=1;
% % 
% % % find recursively rows with one 1 and set it to 0 until no such rows are
% % % found
% % flagDo = true;
% % while flagDo
% %     flagDo = false;
% %     for i=1:n
% %        nones = numel(find(AdjM(i,:)>0));
% %        if nones <1
% %           flagDo = true;
% %           j = find(AdjM(i,:)>0);
% %           AdjM(i,j) = 0; 
% %           AdjM(j,i) = 0;
% %        end
% %     end    
% %     
% % end
% % 
% % [v1,v2] = find(AdjM>0);
% % DG1.E = [v1,v2];
% % 
% % figure,
% %     draw_graph(img1, 'Image 1', DG1);
% % hold off;

% Save all data
guidata(hObject,handles);


% --- Executes on button press in checkboxShowSP.
function checkboxShowSP_Callback(hObject, eventdata, handles)

handles = guidata(hObject);

img1 = handles.img1;
img1SP = handles.img1SP;
DG1 = handles.DG;

checked = get(hObject,'Value');

axes(handles.axes2);
if checked 
    draw_graph(img1SP.boundary, 'Image 1', DG1);              
else
    draw_graph(img1, 'Image 1', DG1);
end



% --- Executes on button press in pushbutton2.
%
% Recalculate super pixel of the image and build new dependency graph
%
function pushbutton2_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

img1 = handles.img1;

% new SP 

str = get(handles.editSP1, 'String');
nSP1 = str2num(str);

[img1SP.num, ... 
 img1SP.label, ...
 img1SP.boundary] = SLIC_Superpixels(im2uint8(img1), nSP1, 20);

handles.img1SP = img1SP;   
edges = handles.edges;


% Build dependency graph
DG1 = buildGraph(edges, descr, handles.img1SP);
handles.DG = DG1;

% Show it on the axis2

axes(handles.axes2);
if get(handles.checkboxShowSP,'Value')
    draw_graph(img1SP.boundary, 'Image 1', DG1); 
else
    draw_graph(img1, 'Image 1', DG1); 
end;

% Save all data
guidata(hObject,handles);
