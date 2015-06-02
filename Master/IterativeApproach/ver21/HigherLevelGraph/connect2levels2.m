%% define correspondences between graphs on higher and lower level
% A node v of Lower Level Graph correpondes to an anchor a from Higher
% Level Graph, if v is inside defined region around a
%
% Input
%   LLG     lower level graph, LLG = (V,D,E,U)
%   HLG     higher level graph, HLG = (V,D,E)
%     T     list of local transformation matrices estimated for each anchor node
%  gamma    parameter
% Output
%   U       correspondence matrix

function [U] = connect2levels2(LLG, HLG, V2, varargin) %anchor_matched_pairs, nodes_matched_pairs, T, gamma)

    n = size(LLG.V, 1);  % number of nodes in the lower level graph LLG
    m = size(HLG.V, 1);  % number of nodes in the higher level graph HLG
    gamma = 1;
    
    % for each node calculate it's distance to the nearest anchor
    diffx = repmat(LLG.V(:,1), 1, m) - repmat(HLG.V(:,1)', n, 1);
    diffy = repmat(LLG.V(:,2), 1, m) - repmat(HLG.V(:,2)', n, 1);
    dist = sqrt(diffx.^2 + diffy.^2);

    U1 = dist;
    
    
    U2 = zeros(n, m);
    
    if (nargin == 7)
        
        anchor_matched_pairs = varargin{1};
        nodes_matched_pairs = varargin{2};
        T = varargin{3};
        gamma = varargin{4};
        
        assert( max(nodes_matched_pairs(:,1)) <= n, 'index of matched nodes exceeded the number of nodes');
        assert( max(anchor_matched_pairs(:,1)) <= m, 'index of matched anchors exceeded the number of anchors');
        
        coord_of_matches = zeros(n, 2);
        coord_of_matches( nodes_matched_pairs(:,1), :) = V2( nodes_matched_pairs(:,2), :);
        
        % apply the transformation T(j) defined by each matched anchor to
        % all nodes from LLG.V and calculate distances between
        % projections and found matches V2
        P = size(anchor_matched_pairs, 1);
        
        for j=1:P    
            if (sum(T(j,:))>0)
                aj = anchor_matched_pairs(j,1);
            
                % T(j) is a [6x1] row-vector
                A = reshape(T(j, 1:4), 2, 2);
                b = T(j, 5:6)';
                % projection of points LLG.V
                fV = A * LLG.V' + repmat(b,1,n);
                fV = fV';
                
%                 figure,
%                     plot(LLG.V(:,1), 6-LLG.V(:,2), 'r*'), hold on;
% 
%                     edges = LLG.E';
%                     edges(end+1,:) = 1;
%                     edges = edges(:);
% 
%                     points = LLG.V(edges,:);
%                     points(3:3:end,:) = NaN;
% 
%                     line(points(:,1), 6-points(:,2), 'Color', 'g');
% 
% 
% %                     fV_prime(:,1) = 8 + fV(:,1);
% %                     fV_prime(:,2) = fV(:,2);
% % 
%                     V2_prime(:,1) = 8 + V2(:,1);  
%                     V2_prime(:,2) = V2(:,2);  
% % 
%                     plot(V2_prime(:,1), 6-V2_prime(:,2), 'r*');
% %                     plot(fV_prime(:,1), 6-fV_prime(:,2), 'b*')
% % 
% % 
% %                     nans = NaN * ones(size(fV_prime,1),1) ;
% %                     x = [ LLG.V(:,1) , fV_prime(:,1) , nans ] ;
% %                     y = [ LLG.V(:,2) , fV_prime(:,2) , nans ] ; 
% %                     line(x', 6-y', 'Color','b') ;
% 
%                 
%                 hold off;
                
                

                % distance between projections and found matches
                diffx = coord_of_matches(:,1) - fV(:,1);
                diffy = coord_of_matches(:,2) - fV(:,2);
                U2_p = sqrt(diffx.^2 + diffy.^2);        

                U2(:,aj) = U2_p;
            end
        end 
    end
    
%     lincomb_Us = gamma*U1 + (1-gamma)*exp(-U2/10);
    C = max(U1(:)-min(U1(:)));
    U2 = C* (1./(1+exp(-U2)) - 0.5);
    lincomb_Us = gamma*U1 + (1-gamma)*U2;
    
    [~, minpos] = min(lincomb_Us, [], 2);
    
    U = false(n,m);
    U(sub2ind([n,m], [1:n]', minpos)) = true;
    
    
    % check if each anchor node has either 0 or at least 3 associated nodes
    col_sum = sum(double(U));
    problem_anchors = find(col_sum>0 & col_sum<3);
    
    if (numel(problem_anchors)>0)
        display(sprintf('WARNING: %d subgraph(s) contain less than 3 nodes', numel(problem_anchors)));
%        lincomb_Us_cut = lincomb_Us(:, problem_anchors);
%        
%        [~, ind_sort] = sort(lincomb_Us_cut);
%        
%        for j=1:numel(problem_anchors)
%            U(ind_sort(1:3), j) = true;
%        end   
%        
    end
    
end
