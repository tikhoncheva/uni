% --- Executes on mouse press over axes background.
%
% Show initial candidates and the best match according to the algorithm
%
function axes6_highlight_LLG(hObject, ~, handles)

img1 = handles.img1;
img2 = handles.img2;

v1 = handles.LLG1.V';
v2 = handles.LLG2.V';

nV1 = size(v1,2);
nV2 = size(v2,2);

it = handles.Iteration;

LL_matches = handles.LLGmatches(it).matched_pairs;

GT = handles.GT.LLpairs;
                 
cP = get(gca,'Currentpoint');
n = cP(1,1);
m = cP(1,2);
 
[~,n1, ~] = size(img1) ;
      
if (n>n1)
    % point on the second image
    n = n-n1;
    img = 2;
else
    % point on the first image
    img = 1;
end
      
if img==1
    nn = knnsearch(handles.LLG1.V,[n,m]); 
else
    nn = knnsearch(handles.LLG2.V,[n,m]);    
end
      
% show selected match
if (img==1)
    ind = (LL_matches(:,1) == nn);
    selected_match = LL_matches(ind,1:2);
else
    ind = (LL_matches(:,2) == nn);
    selected_match = LL_matches(ind,1:2);      
end

% show matched nodes with corresponding subgraphs
axes(handles.axes6);
cla reset
plot_LLGmatches(handles.img1, handles.LLG1, ...
                handles.img2, handles.LLG2, ...  
                handles.LLGmatches(it).matched_pairs, ...
                GT, selected_match);   


axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles})    
