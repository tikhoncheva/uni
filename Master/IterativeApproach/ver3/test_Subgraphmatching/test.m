
addpath(genpath('/export/home/etikhonc/Documents/Tools/piotr_toolbox_V3.26/')); % Piotr Dollar toolbox
addpath(genpath('/export/home/etikhonc/Documents/Tools/edges-master/'));  % Edge extraction
addpath(genpath('/export/home/etikhonc/Documents/Tools/vlfeat-0.9.20/toolbox/'));     % VL_feat library
run vl_setup.m
addpath(genpath('/export/home/etikhonc/Documents/Tools/RRWM_release_v1.22'));

addpath(genpath('../toyProblem_realimg/'));
addpath(genpath('../LowerLevelGraph/'));


[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');
img1 = imread([pathname filesep filename]);


[edges, descr] = computeDenseSIFT(img1);        % edges 4xn; % descr 128xn

features1.edges = edges;
features1.descr = descr;

[img2, features2, GT] = transform_image(img1, edges);
GT = GT. LLpairs;

G1 = buildLLGraph(features1.edges, features1.descr);
G2 = buildLLGraph(features2.edges, features2.descr);

f1 = figure; plot_graph(img1, G1);
f2 = figure; plot_graph(img2, G2);

%% Subregion

[m,n, ~] = size(img1);

x0 = 40; y0 =80; wx = 100; wy = 50;
% x0 = 40; y0 =80; wx = 100; wy = 70;
rect1 = [x0, y0, wx, wy];

mask1 = zeros(m,n);
mask1(y0:y0+wy, x0:x0+wx) = 1;

% x0 = 40; y0 =80; wx = 100; wy = 50;
% x0 = 40; y0 =80; wx = 150; wy = 50;
% x0 = 80; y0 =80; wx = 100; wy = 50;
% x0 = 40; y0 =100; wx = 100; wy = 50;
x0 = 80; y0 =100; wx = 100; wy = 50;
rect2 = [x0, y0, wx, wy];

mask2 = zeros(m,n);
mask2(y0:y0+wy, x0:x0+wx) = 1;

%
figure;
subplot(1,2,1);
h1 = plot_graph(img1, G1); set(h1,'AlphaData',0.4); hold on;
h2 = plot_graph(img1, G1); set(h2,'AlphaData',mask1); hold off;

subplot(1,2,2);
h1 = plot_graph(img2, G2); set(h1,'AlphaData',0.4); hold on;
h2 = plot_graph(img2, G2); set(h2,'AlphaData',mask2); hold off;

% First subgraph

img1_cut = imcrop(img1, rect1);
x0 = rect1(1); y0 = rect1(2); wx = rect1(3); wy = rect1(4);

subG1 = struct('V', [], 'D', [], 'E', []);

ind_V1 = G1.V(:,1)>=x0 & G1.V(:,1)<=x0+wx & G1.V(:,2)>=y0 & G1.V(:,2)<=y0+wy; 
ind_V1 = find(ind_V1);

subG1.V = G1.V(ind_V1,1:2);
subG1.V(:,1) = subG1.V(:,1) - x0;
subG1.V(:,2) = subG1.V(:,2) - y0;
subG1.D = G1.D(:, ind_V1);

ind_E1 = ismember(G1.E(:,1), ind_V1) & ismember(G1.E(:,2), ind_V1);
subG1.E = G1.E(ind_E1, 1:2);

[~, new_ind] = ismember(subG1.E(:,1), ind_V1); subG1.E(:,1) = new_ind;
[~, new_ind] = ismember(subG1.E(:,2), ind_V1); subG1.E(:,2) = new_ind;


% figure; plot_graph(img1_cut, subG1);

% Second subgraph

img2_cut = imcrop(img2, rect2);
x0 = rect2(1); y0 = rect2(2); wx = rect2(3); wy = rect2(4);

subG2 = struct('V', [], 'D', [], 'E', []);

ind_V2 = G2.V(:,1)>=x0 & G2.V(:,1)<=x0+wx & G2.V(:,2)>=y0 & G2.V(:,2)<=y0+wy; 
ind_V2 = find(ind_V2);

subG2.V = G2.V(ind_V2,1:2);
subG2.V(:,1) = subG2.V(:,1) - x0;
subG2.V(:,2) = subG2.V(:,2) - y0;
subG2.D = G2.D(:, ind_V2);

ind_E2 = ismember(G2.E(:,1), ind_V2) & ismember(G2.E(:,2), ind_V2);
subG2.E = G2.E(ind_E2, 1:2);

[~, new_ind] = ismember(subG2.E(:,1), ind_V2); subG2.E(:,1) = new_ind;
[~, new_ind] = ismember(subG2.E(:,2), ind_V2); subG2.E(:,2) = new_ind;


% figure; plot_graph(img2_cut, subG2);


% Ground truth for selected subgraph
GT_cut = GT(ind_V1,:);
[~, new_ind] = ismember(GT_cut(:,1), ind_V1); GT_cut(:,1) = new_ind;
[~, new_ind] = ismember(GT_cut(:,2), ind_V2); GT_cut(:,2) = new_ind;

GT_cut(GT_cut(:,1)==0,:) = [];
GT_cut(GT_cut(:,2)==0,:) = [];


%% Match two subgraphs

v1 = subG1.V';  %2xnV1
v2 = subG2.V';  %2xnV2

d1 = subG1.D;   % d x nV1 
d2 = subG2.D;   % d x nV2
               % d - size of vectorized HoG - descriptor around node

nV1 = size(v1,2);
nV2 = size(v2,2);

% adjacency matrix of the first graph
adjM1 = zeros(nV1, nV1);
E1 = subG1.E;
E1 = [E1; [E1(:,2) E1(:,1)]];
ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
adjM1(ind) = 1;

% adjacency matrix of the second graph
adjM2 = zeros(nV2, nV2);
E2 = subG2.E;
E2 = [E2; [E2(:,2) E2(:,1)]];
ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
adjM2(ind) = 1;

% correspondence matrix 
corrmatrix = ones(nV1,nV2);                                                 %  !!!!!!!!!!!!!!!!!!!!!! now: all-to-all

% compute initial affinity matrix
affmatrix = initialAffinityMatrix2(v1, v2, d1, d2, adjM1, adjM2, corrmatrix);

% conflict groups
[L12(:,1), L12(:,2)] = find(corrmatrix);
[ group1, group2 ] = make_group12(L12);

% run RRW Algorithm 
tic
x = RRWM(affmatrix, group1, group2);
display(sprintf('  time spent for the RRWM on the anchor graph: %f sec', toc));
display(sprintf('==================================================\n'));

X = greedyMapping(x, group1, group2);

matches = logical(reshape(X,nV1, nV2));
[pairs(:,1), pairs(:,2)] = find(matches);       % matched pairs of anchor graphs
objval = X'*affmatrix * X;

TP = ismember(pairs(:,1:2), GT_cut, 'rows');    % true positive matches
accuracy = sum(TP(:)) / size(pairs,1);

figure;
plot_matches(img1_cut, subG1, img2_cut, subG2, pairs, GT_cut);
title(sprintf('Matching score %.03f, Accuracy %.01f %%', objval, accuracy*100));

clear L12;
clear pairs;
%%


figure;
plot_matches(img1_cut, subG1, img2_cut, subG2, [], []);


