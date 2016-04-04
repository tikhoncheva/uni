
addpath(genpath('/export/home/etikhonc/Documents/Tools/piotr_toolbox_V3.26/')); % Piotr Dollar toolbox
addpath(genpath('/export/home/etikhonc/Documents/Tools/edges-master/'));  % Edge extraction
addpath(genpath('/export/home/etikhonc/Documents/Tools/vlfeat-0.9.20/toolbox/'));     % VL_feat library
run vl_setup.m

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
nA = 40;
% ------------------

LLGraph1_LEM = LLGraph1;
[HLGraph1_LEM, U_LEM] = LEM_coarsen_2(img1, LLGraph1_LEM, nA);
LLGraph1_LEM.U = U_LEM;

figure;
subplot(1,2,1);
plot_twolevelgraphs(img1, LLGraph1_LEM, HLGraph1_LEM);
title(sprintf('HEM Coarsed graph with %d nodes (initial %d nodes)', size(HLGraph1_LEM.V,1), size(LLGraph1_LEM.V,1)) );


% LLGraph1_HEM = LLGraph1;
% [HLGraph1_HEM, U_HEM] = HEM_coarsen(img1, LLGraph1_HEM, nA);
% LLGraph1_HEM.U = U_HEM;
% 
% figure;
% plot_twolevelgraphs(img1, LLGraph1_HEM, HLGraph1_HEM);
% title(sprintf('HEM Coarsed graph with %d nodes (initial %d nodes)', size(HLGraph1_HEM.V,1), size(LLGraph1_HEM.V,1)) );

LLGraph2_LEM = LLGraph2;
[HLGraph2_LEM, U_LEM] = LEM_coarsen_2(img2, LLGraph2_LEM, nA);
LLGraph2_LEM.U = U_LEM;

% LLGraph2_HEM = LLGraph2;
% [HLGraph2_HEM, U_HEM] = HEM_coarsen(img2, LLGraph2_HEM, nA);
% LLGraph2_HEM.U = U_HEM;

% figure;
subplot(1,2,2);
plot_twolevelgraphs(img2, LLGraph2_LEM, HLGraph2_LEM);
title(sprintf('LEM Coarsed graph with %d nodes (initial %d nodes)', size(HLGraph1_LEM.V,1), size(LLGraph1_LEM.V,1)) );

% figure;
% plot_twolevelgraphs(img2, LLGraph2_HEM, HLGraph2_HEM);
% title(sprintf('HEM Coarsed graph with %d nodes (initial %d nodes)', size(HLGraph1_HEM.V,1), size(LLGraph1_HEM.V,1)) );

%% Coarsening of two graphs parallel

LLGraph1_LEM = LLGraph1; LLGraph2_LEM = LLGraph2;
[HLGraph1_LEM, U1_LEM, HLGraph2_LEM, U2_LEM] = LEM_coarsen_2graphs(img1, LLGraph1_LEM,...
                                                            img2, LLGraph2_LEM, nA);
LLGraph1_LEM.U = U1_LEM; LLGraph2_LEM.U = U2_LEM;


