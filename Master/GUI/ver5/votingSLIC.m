function votingSCLIC( point, edges, edgeDescr, SP1, SP2, mparam)

display('Voting');

% figure, imshow(label2rgb(SP1.label,'jet','c','shuffle'));

x = point(1);
y = point(2);

point_label = SP1.label(y,x);

[sameSP(:,1), sameSP(:,2)] = find(SP1.label == point_label);

% get descriptor of the point on each scale
ind = [];

    
for i=1:size(sameSP,1)
    SP1.boundary(sameSP(i,1), sameSP(i,2), :) = 0;
    ind = [ind, find(edges{1}(1,:) == sameSP(i,2) & ...
                     edges{1}(2,:) == sameSP(i,1)) ]; 
end

edgeP = edges{1}(1:2,ind);

% edgeP = [edgeP'; [x,y]];
% [edgeP,ia,ic] = unique(edges{1}(1:2,ind));

SP1.boundary(edgeP(2,:),edgeP(1,:), 1) = 255;
SP1.boundary(edgeP(2,:),edgeP(1,:), 2:3) = 0;

% figure, imshow(SP1.boundary);

neighborlist = []; %zeros(1, numel(ind)*knn);
vallist = []; %zeros(1, numel(ind)*knn);
    
for j = 1:numel(ind)
    % Euclidian distance between descriptors
    diff = bsxfun(@minus,double(edgeDescr{2}),...
                         double(edgeDescr{1}(:,ind(j))));
    dist = sqrt(sum(diff.^2));
    dist = dist./max(dist(:));
    [val,nnInd] = sort(dist); 

    sim = val(1:mparam.kNN);
    matches = nnInd(1:mparam.kNN);
    
    neighborlist = [neighborlist, matches];
    vallist = [vallist, sim];

end


labels_coord = edges{2}(1:2, neighborlist);
linearInd = sub2ind(size(SP2.label), labels_coord(2,:), labels_coord(1,:)); 

label_list = SP2.label(linearInd);

for i=1:numel(neighborlist)
    point_label2 = SP2.label(edges{2}(2, neighborlist(i)),edges{2}(1,neighborlist(i)));
 
    if isKey(votes,point_label2)
        votes(point_label2) = votes(point_label2) + 1;
    else     
        votes(point_label2) = 1;
    end
    
    [sameSP2x, sameSP2y] = find(SP2.label == point_label2);

    for j=1:size(sameSP2x,1)
        SP2.boundary(sameSP2x(j), sameSP2y(j), 1) = 255;
        SP2.boundary(sameSP2x(j), sameSP2y(j), 2:3) = 0;
    end
end

votes = unique(label_list)


% figure, imshow(SP2.boundary);

end