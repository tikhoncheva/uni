% RANSAC with CDF-Algorithm to align points between two sets
%
% Usage:
% [M] = ransac_cdf(P1, P2, corresp s, t)
%
% Input
%     P1        first points set
%     P2        second points set
%               points in P1, P2 are already aligned
%
%     s         % of points in P1 to be used for transformation estimation
%     t         distance threshold between a data point and its projection
%               used to decide whether the point is an inlier or not.
%
% Output:
%     M         - The transformation function between the set P1 and P2


%% Based on:
% ransac.m by Peter Kovesi, 2003-2006
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au    
% http://www.csse.uwa.edu.au/~pk
% 


function[T, A, b] = ransac_cdf(P1, P2, s, t)


    % Test number of parameters
    narginchk ( 2, 4) ;

    if nargin < 4; t = 0.0; end; 
    if nargin < 3; s = 0.5; end; 
    
    maxIt = 1000;    %  maximal number of iterations
    maxInit = 100;   % maximal number of initializations
      
    n1 = size(P1,1); % number of points in the first set              
    
    p = 0.99;         % Desired probability of choosing at least one sample
                      % free from outliers
    it = 0;
    bestscore =  0;   
    bestA = eye(2);
    bestb = [0;0];
    bestT.A = bestA;
    bestT.b = bestb;
    
    N = 1;            % Dummy initialisation for number of iterations
    init = 1;
    
    n = round(n1*s);  % number of sample data points
    if n<4  % you need at least 3 point, but with exactly 3 point algorithm will always overfit
      T = bestT;
      A = bestA;
      b = bestb;
      return;
    end
    
    while N > it || init <  maxInit
        
        % Select at random s% of datapoints from first dataset
        ind = randsample(n1, n);
        sP1 = P1(ind,:);
        sP2 = P2(ind,:);
         
        H = estimateGeometricTransform(sP1,sP2,'affine');
        T = H.T';
        A = [[T(1,1)  T(1,2)];[T(2,1) T(2,2)]];
        b = [ T(1,3); T(2,3)]; 

        % Calculate number of inliers
        pr_P1 = A * P1' + repmat(b,1,n1); % proejction of the set P1
        pr_P1 = pr_P1';                
                
        dist = sqrt((P2(:,1)-pr_P1(:,1)).^2+(P2(:,2)-pr_P1(:,2)).^2);                              
        ind_inliers = dist < t;
        ninliers = nnz(ind_inliers);
        
        % Find the number of inliers to this model.
        
        if ninliers > bestscore    % Largest set of inliers so far...
            bestscore = ninliers;  % Record data for this model
            bestT = T;
            bestA = A;
            bestb = b;
            
            % Update estimate of N, the number of trials to ensure we pick, 
            % with probability p, a data set with no outliers.
            fracinliers =  ninliers/n1;
            pNoOutliers = 1 -  fracinliers^s;
            pNoOutliers = max(eps, pNoOutliers);  % Avoid division by -Inf
            pNoOutliers = min(1-eps, pNoOutliers);% Avoid division by 0.
            N = log(1-p)/log(pNoOutliers);
            init = maxInit;
        else
            init = init + 1;
        end
        
        % Safeguard being stuck in this loop forever
        it = it+1;
        if it > maxIt
            warning(sprintf('ransac reached the maximum number of %d iterations',...
                    maxIt));
            break
        end     
    end
    
    T = bestT;
    A = bestA;
    b = bestb;
end  