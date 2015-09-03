%% Makes current problem into Graph Matching form
function [accuracy, score, time, X] = wrapper_GM(method, cdata) %, Xraw, score_raw, score_MP] = wrapper_GM(method, cdata)
% Make function evaluation script
str = ['feval(@' func2str(method.fhandle)];
for j = 1:length(method.variable), str = [str ',cdata.' method.variable{j} ]; end
if ~isempty(method.param), for i = 1:length(method.param), str = [str, ',method.param{' num2str(i) '}']; end; end
str = [str, ')']; 

if ~strcmp(func2str(method.fhandle), 'wrapper_TwoLevelGM')
    
    %% PATH
%     if strcmp(func2str(method.fhandle), 'PATH')
%      
%     end

    %% FAQ
    if strcmp(func2str(method.fhandle), 'sfw')

        start = tic;
        for i=1:cdata.FAQ_nIt,
            % If it it the first start then start in the center of the space
            if i>1
                [mn(i).s,mn(i).p,~,~,~,~] = sfw(cdata.A, cdata.B, 30,-1); %eval(str);
                % otherwise pick a point near the center of the space.
            else
                [mn(i).s,mn(i).p,~,~,~,~] = sfw(cdata.A, cdata.B, 30);
            end

        end
        S=[mn.s]';
        [f, indopt] = min(S(1:cdata.FAQ_nIt));

        seq = mn(indopt).p;
        time = toc(start);

        X = zeros(cdata.nP1, cdata.nP2);
        ind = sub2ind(size(X), (1:cdata.nP1)', seq');
        X(ind) = 1;

        [corr(:,1), corr(:,2)] = find(X);
        score = matching_score_LL(cdata.LLG1, cdata.LLG2, corr);
        X = X(:);
%         score = f;

    end
    
    %% GLAG
    if strcmp(func2str(method.fhandle), 'GLAG')
        start = tic;
        param = struct('verbose', 0);
        [~,X]=graph_matching(cdata.A,cdata.B, param);
        [corr(:,1), corr(:,2)] = find(X);
        score = matching_score_LL(cdata.LLG1, cdata.LLG2, corr);
        X = X(:);
        time = toc(start);
    end
    
%     tic;
%     s = 0;
%     [corr] = graphmAlg(cdata.A, cdata.B, s, 'PATH');   
% 	gmAlg = @(A,B,s) graphmAlg(cdata.A,cdata.B,cdata.s,'PATH');
%     % number of seed vertices
%     m = 20;
%     %
%     numdim = 10;
%     %
%     max_clust = 100;
%     
% 	[match, clust_labels] = BigGMr(cdata.A, cdata.B, m, numdim, max_clust, @spectralEmbed, @kmeansAlgr, gmAlg);
% 	time = toc;
    
%     % Function evaluation & Excution time Check
%     tic; Xraw = eval(str); %time = toc;
%     % Discretization by one-to-one mapping constraints
%     if 0
%         % Hungarian assignment
%         X = zeros(size(cdata.E12)); X(find(cdata.E12)) = Xraw;
%         X = discretisationMatching_hungarian(X,cdata.E12); X = X(find(cdata.E12));
%     else % Greedy assignment
%         X = greedyMapping(Xraw, cdata.group1, cdata.group2);
%     end
%     % Matching Score
%     score = X'*cdata.affinityMatrix*X; % objective score function
%     time = toc; % @ETikhonc: move toc to the end, because TwoLevelGM does also discretization
else
    start = tic; [Xraw, score] = eval(str); time = toc(start);
    X = Xraw;
end

% Xraw = Xraw / sqrt(sum(Xraw.^2));
% score_raw = Xraw'*cdata.affinityMatrix*Xraw; % objective score function
% score_MP = (Xraw)'*RMP_mult(cdata.affinityMatrix, Xraw, cdata.group1); % objective MP score function

% [ tmpS tmpSel tmp_norm ] = RMP_mult_mm(cdata.affinityMatrix, Xraw, cdata.group1);
% if 0
%     tmpX = Xraw;
%     tmpX(~tmpSel) = 0;
%     t_norm = sqrt(sum(tmpX.^2));
% else
%     t_norm = sqrt(tmp_norm);
% end
% if t_norm ~= 0
%     %tmpX = tmpX / t_norm;
%     Xraw = Xraw / t_norm;
% end
% score_MP = (Xraw')*RMP_mult_mm(cdata.affinityMatrix, (Xraw), cdata.group1);
%score_MP
%pause;
%score_MP = 0;
%score_MP = (Xraw'*tmpS) / sum(Xraw(find(tmpS>0)).^2);
%pause;
%score_MP = sum(score_MP .* score_MP);
if isempty(cdata.GTbool)
% if length(cdata.GTbool) ~= length(cdata.affinityMatrix)
    accuracy = NaN; % Exception for no GT information
else
    accuracy = (X(:)'*cdata.GTbool(:))/sum(cdata.GTbool);
end