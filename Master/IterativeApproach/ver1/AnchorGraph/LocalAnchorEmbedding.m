%% Local Anchor Embedding function
% solves an QP to get the approximation of the given
% vertex x_i through s nearest anchor points

% Source:
% Wei Liu, Junfeng He, Shih-Fu Chang Large 
% "Graph construction for scalable semi-supervised learning"

% Input: 
% dimension d = 2
% x       given set of vertices (2 x n)
% A       coordinates of the anchors (2 x m)
% U       boolean matrix, U \in R^(n x m) 
%         each row of Ui has exactly s non-zero entries,
%         corresponding to the s nearest anchor points of xi

% Output
% obj     optimal objective value
% Z       regression matrix
%         each row Zi has exactly s non-zero entries,
%         corresponding to the s nearest anchor points of xi

% QP
%     min 1/2|x - U*z|^2
%     s.t. sum(z_j, j) = 1, z_j>=0

function Z = LocalAnchorEmbedding(x, A, U)
    
    n = size(x, 2);
    m = size(A, 2);
    
    Z = zeros(n,m);
    
    for i=1:n % for each vertex x_i
        na_ind = find(U(i,:)>0);      % index set of the nearest anchors
        s = length(na_ind);
        
        Ai = A(:, na_ind);            % coordinates of the s nearest anchors (2 x s)
        xi = x(:,i);                  % current vertex x (2 x 1)
        
        z_tm1 = ones(s,1)/s;
        z_t = z_tm1;
        
        sigma_tm2 = 0;
        sigma_tm1 = 1;
        
        beta_tm1 = 1;
        
        t = 0;
        
        while (z_t <= z_tm1)    % z_t converges
            t = t + 1;
            alpha_t = (sigma_tm2-1)/sigma_tm1;
            v_t = z_t + alpha_t *(z_t-z_tm1);  
            
            j = 0;
            beta = 2^j * beta_tm1;
            z = simplexProjection(v_t - grad_g(v_t, xi, Ai) / beta);
            while (g(z, xi, Ai) > g_new(z, v_t, beta, xi, Ai))
                j = j+1;
                beta = 2^j * beta_tm1;
                z = simplexProjection(v_t - grad_g(v_t, xi, Ai) / beta);
            end
            
            beta_tm1 = beta;
            z_tm1 = z_t;
            z_t = z;
            
            sigma_t = (1+sqrt(1+4*sigma_tm1^2))/2.;
            
            sigma_tm2 = sigma_tm1;
            sigma_tm1 = sigma_t;
        end    
        
        zi = z_t;
        Z(i, na_ind) = zi(:);
    end
end

%% Value of the objective function in point z
% z (s x 1), xi (2 x 1), Ai (2 x s)
% val (2 x 1)
function val = g(z, xi, Ai)   % (1x2)
    val = sum((xi - Ai*z).^2) / 2.;
end

%% Value of the gradient of the objective function in point z
% z (s x 1), xi (2 x 1), Ai (2 x s)
% val (s x 1)
function val = grad_g(z, xi, Ai)
    val = Ai'*Ai*z - Ai'*xi;
end

%% Update objective
% z (s x 1), v (s x 1), beta = const
function val = g_new(z, v, beta, xi, Ai)
    val = g(v, xi, Ai) + grad_g(v, xi, Ai)'*(z-v) + beta* sum((z - v).^2) / 2.;
end

%% Projection operator 
% (see Duchi et al. "Efficient projections onto l_1-ball
%                                        for learning in high dimensions")
% z    vector (s x 1)
% pz   projection of z, such that pz = argmin_{z'}|z' - z|
function pz = simplexProjection(z)
    s = size(z,1); 
    v = sort(z);
    
    j = 1;
    while (j<=s) && (v(j) - (sum(v(1:j)) - 1)/j >0) 
        j = j+1;
    end
    p = j - 1;

    theta = (sum(v(1:p)) - 1) / p;
    
    pz = bsxfun(@max, z-theta, zeros(s,1));
end
