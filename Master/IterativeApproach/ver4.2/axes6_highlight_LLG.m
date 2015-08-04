% --- Executes on mouse press over axes background.
%
% Show initial candidates and the best match according to the algorithm
%
function axes6_highlight_LLG(~, ~, handles)

L = handles.IPlevel;

img1 = handles.IP1(L).img;
img2 = handles.IP2(L).img;

LLG1 = handles.IP1(L).LLG; nV1 = size(LLG1.V,1);
LLG2 = handles.IP2(L).LLG; nV2 = size(LLG2.V,1);

HLG1 = handles.IP1(L).HLG;
HLG2 = handles.IP2(L).HLG;

LLGmatches = handles.M(L).LLGmatches;
HLGmatches = handles.M(L).HLGmatches;
GT = handles.M(L).GT;

it = handles.Iteration;
it = min(it, size(LLGmatches,2));

LL_matches = LLGmatches(it).matched_pairs;

                 
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
    nn = knnsearch(LLG1.V,[n,m]); 
else
    nn = knnsearch(LLG2.V,[n,m]);    
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
ai = HLGmatches(it).matched_pairs( LL_matches(ind,3),1);
aj = HLGmatches(it).matched_pairs( LL_matches(ind,3),2);
% ai = find( handles.HLG1.U(selected_match(:,1),:) );
% aj = find( handles.HLG2.U(selected_match(:,2),:) );
% 
% [grid1,grid2] = meshgrid(ai, aj);
% c = [grid1', grid2'];
% pairs_ai_aj = reshape(c,[],2);
% is_matched = logical(ismember(pairs_ai_aj, handles.HLGmatches(it).matched_pairs, 'rows' ));

% matched_anchors = pairs_ai_aj(is_matched, :);
matched_anchors = HLGmatches(it).matched_pairs( LL_matches(ind,3),1:2);

% show matched anchors
axes(handles.axes5);
cla reset
plot_HLGmatches(img1, HLG1, img2, HLG2, HLGmatches(it).matched_pairs, GT.HLpairs, matched_anchors);
% show matched nodes with corresponding subgraphs
axes(handles.axes6);
cla reset
plot_LLGmatches(img1, LLG1, HLG1, ...
                img2, LLG2, HLG2, ...  
                LLGmatches(it).matched_pairs, ...
                HLGmatches(it).matched_pairs, ...
                GT.LLpairs, selected_match);   


axes(handles.axes6);
set(gca,'ButtonDownFcn', {@axes6_highlight_LLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes6_highlight_LLG, handles})    
