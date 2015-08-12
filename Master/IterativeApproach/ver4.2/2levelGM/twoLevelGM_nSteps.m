%% One iteration of the two-level Graph Matching Algorithm

function [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo, time, it] = ...
                   twoLevelGM_nSteps(N, it,  LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo)
    
    setParameters;
    time = 0;

    [LLG1, LLG2] = preprocessing(LLG1, LLG2, agparam);

    for i = 1:N
        it = it + 1;

        tic;
        [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo] = ...
                twoLevelGM_oneIteration(it, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);
        time = time + toc;   
        
    end
    
end