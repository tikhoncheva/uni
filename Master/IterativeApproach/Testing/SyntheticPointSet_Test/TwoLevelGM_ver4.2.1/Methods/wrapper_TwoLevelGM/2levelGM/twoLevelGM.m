%% One iteration of the two-level Graph Matching Algorithm

function [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo, time, it] = ...
                   twoLevelGM(L, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo)
    
    setParameters;
    
    nMaxIt = algparam.nMaxIt;       % maximal number of iteration for each level of the image pyramid
    nConst = algparam.nConst;       % stop, if the matching score didn't change in last C iterations    
    
    time = 0;
    it = 0; 
    count = 0;

    [LLG1, LLG2] = preprocessing(LLG1, LLG2, agparam);
    
    %
    if isempty(HLG1)
        HLG1 = buildHLGraph(L, LLG1, agparam);
    end
    if isempty(HLG2)
        HLG2 = buildHLGraph(L, LLG2, agparam);
    end
    %
    
    while count<nConst && it<nMaxIt
        it = it + 1;

        tic;
        [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo] = ...
                twoLevelGM_oneIteration(it, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);
        time = time + toc;   

        if it>=2 && abs(LLGmatches(it).objval-LLGmatches(it-1).objval)<10^(-5)
            count = count + 1;
        else
            count = 0;
        end
        
    end
    
end