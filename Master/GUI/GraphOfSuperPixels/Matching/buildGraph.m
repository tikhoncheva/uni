% Construct dependency graph of a given image
% 
function G = buildGraph(edges, descr, imgSP)

G.V = [];
G.E = [];

nV = size(edges,2);

% all labels of the image
Labels = unique(imgSP.label);
nLabels = numel(Labels);

Labels = [];
correspondenceMatrix = zeros(nLabels, nV);
for i=1:nV
    label_i = imgSP.label(edges(2,i), edges(1,i));
    
    [SPxy(:,1), SPxy(:,2)] = find(imgSP.label == label_i);

    for j=1:size(SPxy,1)
        imgSP.boundary(SPxy(j,1), SPxy(j,2), 1:2) = 0;  % mark super pixels on the first image    
        imgSP.boundary(SPxy(j,1), SPxy(j,2), 3) = 255;  % mark super pixels on the first image    
 
    end
    clear SPxy
%    plot(edges(1,i),edges(2,i),'b.');
    
    Labels = [Labels, label_i];
    correspondenceMatrix(label_i + 1, i) = 1;
end

% labels of super pixel, which contain edge points
Labels = unique(Labels);
nLabels = numel(Labels);

correspondenceMatrix(all(~any(correspondenceMatrix, 2),2), :) = []; % remove zero rows
% correspondenceMatrix = sparse(correspondenceMatrix);


figure, imshow(imgSP.boundary), hold on;
% compute centers of superpixels
for l = 1:nLabels
    
    % find edge points inside selected SP
    ind = find(correspondenceMatrix(l,:));
    
    x = sum(edges(1,ind))/numel(ind);
    y = sum(edges(2,ind))/numel(ind);
    
    G.V = [G.V; [x,y]];
    plot(x,y, 'rx');
end



n = size(G.V,1);
% connect super pixel that have a common edge

% compute distance matrix
distM = squareform(pdist(G.V, 'euclidean')); % (2 x n) x (2 x n) distance matrix
% distM = distM(1:n1, n1+1:end);

% distM(1:(n+1):end)= Inf;
meandist = mean(distM(:));

element_to_del= (distM > 0.05*meandist);
distM(element_to_del) = 0;
distM(1:(n+1):end)= 0;

[v1,v2] = find(distM>0);

for i=1:length(v1)
    line([G.V(v1(i),1) G.V(v2(i),1) ],...
         [G.V(v1(i),2) G.V(v2(i),2) ], 'Color', 'g');  

end

hold off;
end