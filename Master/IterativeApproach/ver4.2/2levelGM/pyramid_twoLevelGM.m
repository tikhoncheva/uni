%% two-level Graph Matching Algorithm for an image pyramid

function [IP1, IP2, M, time] = pyramid_twoLevelGM(IP1, IP2, M)
    
    setParameters;
    nLevels = size(IP1,1);
    assert(nLevels>=2, 'use Pyramid two Level GM only for more then 2 level structure')
    time = zeros(nLevels,1);
    
    for L = nLevels:-1:1
%     for L = nLevels-1:-1:1        
        fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
        fprintf('Level %d\n', L);
        fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
    

        LLG1 = IP1(L).LLG;
        LLG2 = IP2(L).LLG;

        if L==nLevels 
            HLG1 = buildHLGraph(L, LLG1, agparam);
            HLG2 = buildHLGraph(L, LLG2, agparam);

%         if L==nLevels-1 
%               HLG1 = buildHLGraph_inImagePyramid(LLG1, IP1(L+1).LLG);
%               HLG2 = buildHLGraph_inImagePyramid(LLG2, IP2(L+1).LLG);
        else
            HLG1 = buildHLGraph_inImagePyramid(LLG1, IP1(L+1).LLG, M(L+1).LLGmatches);
            HLG2 = buildHLGraph_inImagePyramid(LLG2, IP2(L+1).LLG, M(L+1).LLGmatches);
        end
        figure, subplot(1,2,1); plot_2levelgraphs(IP1(L).img, LLG1, HLG1, true, true);
        subplot(1,2,2);  plot_2levelgraphs(IP2(L).img, LLG2, HLG2, true, true);

            
        LLGmatches = M(L).LLGmatches;
        HLGmatches = M(L).HLGmatches;

        affTrafo = M(L).affTrafo;
        
        [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo, time_L, it] = ...
        twoLevelGM(L, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo);

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