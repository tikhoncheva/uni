%% two-level Graph Matching Algorithm for an image pyramid
% each two levels build an instance of the 2-Level-GM
% for the highest level one creates an additional anchor graph 

% NOTE: number of levels in the pyramid must be even
%       in each lower level unmatched nodes are omited

% NOTE: the problem is getting bigger with each pair of levelss, so that is
% not a simplification of the initial problem

function [IP1, IP2, M, time] = multiLevelGM(IP1, IP2, M)
    
    nLevels = size(IP1,1);
    assert(nLevels>=2, 'use Pyramid two Level GM only for more then 2 level structure')
    
    setParameters;
    nMaxIt = algparam.nMaxIt;       % maximal number of iteration for each level of the image pyramid
    nConst = algparam.nConst;       % stop, if the matching score didn't change in last C iterations    
    
    time = 0;
    it = 0; 
    count = 0;
    nMaxIt = 1;
      
    L = nLevels; % start with the highest level
    
    % highest HLGraphs
    [IP1(L).LLG, IP2(L).LLG] = preprocessing(IP1(L).LLG, IP2(L).LLG, agparam);
    
    hHLG1 = buildHLGraph(L, IP1(L).LLG, agparam);
    hHLG2 = buildHLGraph(L, IP2(L).LLG, agparam);    
    
%     hHLG1 = buildHLGraph_inImagePyramid(IP1(L-1).LLG, IP1(L).LLG);  % use graphs on the last levels in the
%     hHLG2 = buildHLGraph_inImagePyramid(IP1(L-1).LLG, IP1(L).LLG);  % image pyramid as basis for the highest anchor graph
    
    M_prev = M;
    
    while count<nConst && it<nMaxIt
        it = it + 1;

        %tic;
        [IP1, IP2, hHLG1, hHLG2, M ] = ...
                multiLevelGM_oneIteration(it, IP1, IP2, hHLG1, hHLG2, M_prev);
        %time = time + toc;   

        if it>=2 && (M(1).LLGmatches.objval-M_prev.LLGmatches.objval<10^(-5))
            count = count + 1;
        else
            count = 0;
        end
        
        M_prev = M;
        
    end
end