% --- Executes on mouse press over axes background.
%
% Show initial candidates and the best match according to the algorithm
%
function axes6_highlight_LLG(~, ~, handles)

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

% corresponding match between anchor graphs:
ai = handles.HLGmatches(it).matched_pairs( LL_matches(ind,3),1);
aj = handles.HLGmatches(it).matched_pairs( LL_matches(ind,3),2);
% ai = find( handles.HLG1.U(selected_match(:,1),:) );
% aj = find( handles.HLG2.U(selected_match(:,2),:) );
% 
% [grid1,grid2] = meshgrid(ai, aj);
% c = [grid1', grid2'];
% pairs_ai_aj = reshape(c,[],2);
% is_matched = logical(ismember(pairs_ai_aj, handles.HLGmatches(it).matched_pairs, 'rows' ));

% matched_anchors = pairs_ai_aj(is_matched, :);
matched_anchors = handles.HLGmatches(it).matched_pairs( LL_matches(ind,3),1:2);

% show matched anchors
axes(handles.axes5);
cla reset
plot_HLGmatches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, handles.HLGmatches(it).matched_pairs, ...
                                                                        handles.GT.HLpairs, matched_anchors);
% show matched nodes with corresponding subgraphs
axes(handles.axes6);
cla reset
plot_LLGmatches(handles.img1, handles.LLG1, handles.HLG1, ...
                handles.img2, handles.LLG2, handles.HLG2, ...  
                handles.LLGmatches(it).matched_pairs, ...
                handles.HLGmatches(it).matched_pairs, ...
                GT, selected_match);   


axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles})    
