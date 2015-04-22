% --- Executes on mouse press over axes background.
%
% Show initial candidates and the best match according to the algorithm
%
function axes5_highlight_HLG(hObject, ~, handles)

img1 = handles.img1;
img2 = handles.img2;

v1 = handles.HLG1.V';   % 2 x nV1
v2 = handles.HLG2.V';   % 2 x nV2

d1 = handles.HLG1.D;
d2 = handles.HLG2.D;

nV1 = size(v1,2);
nV2 = size(v2,2);

matches = handles.HLGmatches.matches;
                 
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
    nn = knnsearch(handles.HLG1.V,[n,m]); 
else
    nn = knnsearch(handles.HLG2.V,[n,m]);    
end
      
% show best match
      
bestmatch = zeros(nV1, nV2);

if (img==1)
    bestmatch(nn, :) = matches(nn, :);
else
    bestmatch(:, nn) = matches(:,nn);          
end

axes(handles.axes5);
cla reset
plot_matches(handles.img1, handles.HLG1, handles.img2, handles.HLG2, matches, bestmatch);

W  = 36; % from vl_feat

if (img == 1)
    nn_match = find(matches(nn, :)>0);
    p1  = v1(1:2,nn);               % coordinates of the selected node on the first image
    p2 = v2(1:2, nn_match); % coordinates of the selected node on the second image
else
    nn_match = find(matches(:,nn)>0);
    p1  = v1(1:2, nn_match); % coordinates of the selected node on the first image
    p2 = v2(1:2, nn);               % coordinates of the selected node on the second image
end


simval = nodeSimilarity(d1, d2, 'euclidean');

if (img == 1)
    display( simval(1, (nn_match-1)*nV1 + nn) );
else
    display( simval(1, (nn-1)*nV1 + nn_match) );
end

patch1 = imcrop(img1, [p1(1)-W/2, p1(2)-W/2, W, W]);
patch2 = imcrop(img2, [p2(1)-W/2, p2(2)-W/2, W, W]);    

figure, imagesc(patch1),  colormap gray, hold off;
figure, imagesc(patch2),  colormap gray, hold off;

axes(handles.axes5);
set(gca,'ButtonDownFcn', {@axes5_highlight_HLG, handles})
set(get(gca,'Children'),'ButtonDownFcn', {@axes5_highlight_HLG, handles})    
