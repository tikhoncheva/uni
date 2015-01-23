% Construct dependency graph of a given image
% 
function G = buildGraph(edges, descr, imgSP)

G.V = [];
G.E = [];

nV = size(edges,2);

Labels = unique(imgSP.label);
nLabels = numel(Labels);

figure, imshow(imgSP.boundary), hold on;

label = [];
correspondenceMatrix = zeros(nLabels, nV);
for i=1:nV
    label = [label, imgSP.label(edges(1,i), edges(2,i))];
    correspondenceMatrix(label,i) = 1;
end

% correspondenceMatrix = sparse(correspondenceMatrix);

% compute centers of superpixels
for l = 1:nLabels
    ind = find(correspondenceMatrix(l,:));
    x = sum(edges(1,ind))/numel(ind);
    y = sum(edges(1,ind))/numel(ind);
    G.V = [G.V; [x,y]];
    plot([x,y], 'ro');
end

hold off;
end