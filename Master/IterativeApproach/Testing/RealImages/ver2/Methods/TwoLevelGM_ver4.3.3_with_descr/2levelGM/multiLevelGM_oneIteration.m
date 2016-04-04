%% One iteration of the two-level Graph Matching Algorithm

function [IP1, IP2, HLG1, HLG2, M] =  multiLevelGM_oneIteration(it, IP1, IP2, hHLG1, hHLG2, M)
    
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
    fprintf('ITERATION %d\n', it);
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
    
    nLevels = size(IP1,1);
    
    if it>1
        % ----------------------------------------------------------------------- 
        fprintf('\n== Update graph partitioning for the next iteration');
        % -----------------------------------------------------------------------     
        [hHLG1, hHLG2, affTrafo] = MetropolisAlg(it-1, LLG1, LLG2, hHLG1, hHLG2,...
                                             LLGmatches, HLGmatches, affTrafo);
    end
    
    % -----------------------------------------------------------------------    
    fprintf('\n== Matching two highest levels');
    % -----------------------------------------------------------------------  
    
    LLG1 = IP1(nLevels).LLG;
    LLG2 = IP2(nLevels).LLG;
    
    [corrmatrix, affmatrix, HLG1, HLG2] = initialization_HLGM(LLG1, LLG2, hHLG1, hHLG2);

    if (it==1)
        HLMatches = matchHLGraphs(corrmatrix, affmatrix);
    else
        HLMatches = matchHLGraphs(corrmatrix, affmatrix, HLG1, HLG2, HLGmatches(it-1));
    end
    M(nLevels).HLGmatches = HLMatches;
    
    % -----------------------------------------------------------------------    
    fprintf('\n== Propagate result of matching on the highest pyramid level down');
    % -------------------------------------------------------------------------
    for L = nLevels:-1:1
        M(L).it = 1;
        LLG1 = IP1(L).LLG;
        LLG2 = IP2(L).LLG;
        
        HLMatches = M(L).HLGmatches;
        
        
        [subgraphNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
                                                                         HLG1.U, HLG2.U,...
                                                                         HLMatches.matched_pairs);                                                                  
        if (it==1)
            LLMatches = matchLLGraphs(LLG1, LLG2, subgraphNodes, corrmatrices, affmatrices, HLMatches.matched_pairs);
        else
            LLMatches = matchLLGraphs(LLG1, LLG2, subgraphNodes, corrmatrices, affmatrices, ...
                                      HLGmatches(it).matched_pairs, ...
                                      LLGmatches(it-1));
        end
        M(L).LLGmatches = LLMatches; 
        if L>=2
            M(L-1).HLGmatches = LLMatches; 
            M(L-1).HLGmatches.matched_pairs(:,3) = 0;   
            
            HLG1 = buildHLGraph_inImagePyramid(IP1(L-1).LLG, IP1(L).LLG);  % use graphs on the last levels in the
            HLG2 = buildHLGraph_inImagePyramid(IP2(L-1).LLG, IP2(L).LLG);  % image pyramid as basis for the highest anchor graph
            IP1(L-1).HLG = HLG1;
            IP2(L-1).HLG = HLG2;
        end
    end

    fprintf('\n');                                     
end