%% two-level Graph Matching Algorithm for an image pyramid

function [IP1, IP2, M, time] = pyramid_twoLevelGM(IP1, IP2, M)
    
    nLevels = size(IP1,1);
    
    time = zeros(nLevels,1);
    
    for L = 1:nLevels
        
        fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
        fprintf('Level %d\n', L);
        fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
    

        LLG1 = IP1(L).LLG;
        LLG2 = IP2(L).LLG;

        HLG1 = IP1(L).HLG;
        HLG2 = IP2(L).HLG;

        LLGmatches = M(L).LLGmatches;
        HLGmatches = M(L).HLGmatches;

        affTrafo = M(L).affTrafo;
        
        [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo, time_L, it] = ...
        twoLevelGM(LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);

        time(L) = time_L;

        M(L).LLGmatches = LLGmatches;
        M(L).HLGmatches = HLGmatches;
        M(L).it = it;
        M(L).affTrafo = affTrafo;

        IP1(L).HLG = HLG1;
        IP2(L).HLG = HLG2;
        
        % 

        fprintf('\n');           
    end
end