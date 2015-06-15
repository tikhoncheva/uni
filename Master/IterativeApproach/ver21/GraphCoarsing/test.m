
addpath(genpath('/export/home/etikhonc/Documents/Tools/piotr_toolbox_V3.26/')); % Piotr Dollar toolbox
addpath(genpath('/export/home/etikhonc/Documents/Tools/edges-master/'));  % Edge extraction
addpath(genpath('../.'));


[filename, pathname] = uigetfile({'*.jpg';'*.png'}, 'Select first image');
img1 = imread([pathname filesep filename]);


[edges, descr] = computeDenseSIFT(img1);        % edges 4xn; % descr 128xn

features1.edges = edges;
features1.descr = descr;

[img2, features2, ~] = transform_image(img1, edges);

LLGraph1 = buildLLGraph(features1.edges, features1.descr);
LLGraph2 = buildLLGraph(features2.edges, features2.descr);

%%
% ------------------
nA = 50;
% ------------------
HLGraph1_LEM = LEM_coarsen(img1, LLGraph1, nA);
HLGraph1_HEM = HEM_coarsen(img1, LLGraph1, nA);


HLGraph2_LEM = LEM_coarsen(img2, LLGraph2, nA);
HLGraph2_HEM = HEM_coarsen(img2, LLGraph2, nA);

