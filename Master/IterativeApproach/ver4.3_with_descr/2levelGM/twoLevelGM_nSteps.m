%% One iteration of the two-level Graph Matching Algorithm

function [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo, time, it] = ...
                   twoLevelGM_nSteps(L, N, it,  LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, InitialMatches, affTrafo)
    
    setParameters;
    time = 0;
    
    poolobj = parpool(2);                           

    [LLG1, LLG2] = preprocessing(LLG1, LLG2, agparam);

    %
    if isempty(HLG1)
%         HLG1 = buildHLGraph(L, LLG1, agparam);
        HLG1 = buildHLGraph_use_InitMatches(L, LLG1, unique(InitialMatches(:,1)), agparam);
%         HLG1 = buildHLGraph_grid(L, LLG1, agparam);
    end
    if isempty(HLG2)
%         HLG2 = buildHLGraph(L, LLG2, agparam);
        HLG2 = buildHLGraph_use_InitMatches(L, LLG2, unique(InitialMatches(:,2)), agparam);
%         HLG2 = buildHLGraph_grid(L, LLG2, agparam);
    end
    %
    
    for i = 1:N
        it = it + 1;

        tic;
        [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo] = ...
                twoLevelGM_oneIteration(it, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);
        time = time + toc;   
        
    end
    
    % close parallel pool
    delete(poolobj); 
end