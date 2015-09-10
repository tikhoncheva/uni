%% Make Problem
function [ problem, time1, time2 ] = makeProblem_ProgGM(iparam, initPathnFile)

t = tic;
%setMethods_ProgGM;
%%set Graph MAtching method
methods(1).fhandle = @RRWM;
methods(1).variable = {'affinityMatrix', 'group1', 'group2'};
methods(1).strName = 'RRWM';
methods(1).postProcess = @postGreedy;


aparam.bProgGM = true;    % true for ProgGM, and false for conventional GM
setParams; % params for feature extraction and matching

pparam.bShow = 0;                              % visualize the process? 
pparam.k_neighbor1 = 25;                       % k_1 
pparam.k_neighbor2 = 5;                        % k_2
pparam.threshold_dissim = 1.0;                 % SIFT distance threshold for candidates
pparam.maxIterGM = 10;                         % max iteration of progression
pparam.max_candidates = mparam.nMaxMatch;      % num of max cand matches in progression


%% make or load INITIAL matches
if exist(initPathnFile, 'file') == 2 
    disp ([ 'loading features from' initPathnFile ' and make new matches.']);
    load(initPathnFile); % load cdata
    cdata = initialmatch_main_re( iparam, cdata, mparam);
    cdata.bPair = 1;
else
    % initial matching routine
    cdata = initialmatch_main( iparam, fparam, mparam );
    cdata.GT = [];
end

time = toc(t);
%% Calculate affinity matrix of initial candidates
t1 = tic;
cand_matchlist = cell2mat({ cdata.matchInfo.match }');
[cdata.distanceMatrix, cdata.flipMatrix ] = computeEuclidDistance( cdata.view, cand_matchlist, 0 );

cdata.affinityMatrix = dissim2affinity( cdata.distanceMatrix ); % make an affinity matrix
[cdata.group1, cdata.group2 ] = make_group12(cand_matchlist(:,1:2));

% eliminate conflicting elements
cdata.affinityMatrix = cdata.affinityMatrix.*~(getConflictMatrix(cdata.group1, cdata.group2));
cdata.affinityMatrix(1:(size(cdata.affinityMatrix,1)+1):end) = 0; % diagonal 0s

%% add node similarity to the affine matrix
d1 = cdata.view(1).desc';
d2 = cdata.view(2).desc';
nodesim = nodeSimilarity(d1, d2, 'cosine');
ind = (cand_matchlist(:,2)-1)*size(d1,2) + cand_matchlist(:,1);
nodesim = nodesim(ind);
cdata.affinityMatrix(1:(size(cdata.affinityMatrix,1)+1):end) = nodesim;


time1 = toc(t1) + time;
% clear iparam fparam mparam;
%% Create two initial graphs (for twoLevelGM)

t2 = tic;
setParameters_2levelGM;
edges1 = cdata.view(1).feat(:,1:2)';
descr1 = cdata.view(1).desc';
LLG1 = buildLLGraph(edges1, descr1, igparam_2lGM);

edges2 = cdata.view(2).feat(:,1:2)';
descr2 = cdata.view(2).desc';
LLG2 = buildLLGraph(edges2, descr2, igparam_2lGM);

time2 = toc(t2) + time;
clear edges1 descr1 edges2 descr2;
clear ipparam_2lGM igparam_2lGM agparam_2lGM algparam_2lGM;
%% Ground Truth (boolean vector)
nV1 = size(LLG1.V,1);
nV2 = size(LLG2.V,1);
GTmatrix = zeros(nV1, nV2);
GTmatrix(sub2ind(size(GTmatrix), cdata.GT(:,1), cdata.GT(:,2))) = 1;
cdata.GTbool = GTmatrix(:);

%% Extrapolated GT
cand_matchlist_init = [repmat((1:nV1)', nV2,1), ...
                         kron((1:nV2)', ones(nV1,1))];
GT_EXTbool = extrapolateGT( LLG1.V, LLG2.V, cand_matchlist_init, cdata.GT, mparam.extrapolation_dist);
GT_EXT_mat = zeros(nV1,nV2);
GT_EXT_mat(sub2ind(size(GT_EXT_mat), ...
          cand_matchlist_init(logical(GT_EXTbool'),1),...
          cand_matchlist_init(logical(GT_EXTbool'),2) )) = 1;
[GT_EXT(:,1), GT_EXT(:,2)] = find(GT_EXT_mat); 


%%
problem.n1 = nV1;
problem.n2 = nV2;

problem.method = methods;
problem.pparam = pparam;
problem.cdata = cdata;
problem.cdata.cand_matchlist_init = cand_matchlist_init;
problem.cdata.GT_EXT = GT_EXT;
problem.cdata.GT_EXTbool = GT_EXTbool;
problem.extrapolation_dist = mparam.extrapolation_dist;

problem.LLG1 = LLG1;
problem.LLG2 = LLG2;

end
