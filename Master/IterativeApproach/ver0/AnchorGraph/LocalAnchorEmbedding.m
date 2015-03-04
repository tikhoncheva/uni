% Local Anchor Embedding function solves an QP to get the approximate given
% vertex x_i through s nearest anchor points

% Source:
% Wei Liu, Junfeng He, Shih-Fu Chang Large 
% "Graph construction for scalable semi-supervised learning"

% Input: 
% x       given set of vertices (n x 2)
% U       boolean matrix, U \in R^(n x m) 
%         each row of U_i has exactly s non-zero entries 
%         corresponding to the s nearest anchor points of x_i
% A       coordinates of the anchors (m x 2)

% Output
% obj     optimal objective value
% z       corresponding optimal vector (z \in R^(m)) with s non-zero
%         entries

% QP
%     min 1/2|x - U*z|^2
%     s.t. sum(z_j, j) = 1, z_j>=0

function Z = LocalAnchorEmbedding(x, U, A)
    
    n = size(x, 1);
    m = size(A, 1);
    
    Z = zeros(n,m);
    
    for i=1:n % for each vertex x_i
        
        nn_ind = find(U>0);      % index set of the nearest anchors
        s = length(nn_ind);
        
        z_tm1 = ones(s,1)/s;
        z_t = z_tm1;
        
        sigma_tm2 = 0;
        sigma_tm1 = 1;
        
        beta0 = 1;
        beta_tm1 = beta0;
        
        t = 0;
        
        while (z_t <= z_tm1)    % z_t converges
            t = t + 1;
            alpha_t = (sigma_tm2-1)/sigma_tm1;
            v_t = z_t + alpha_t *(z_t-z_tm1);  
            
            j = 0;
            beta = 2^j * beta0;
            z = simplexProjection(v_t - grad_g(v_t) / beta);
            while (g(z)>g_new(z, v_t, beta))
                beta = beta0;
                z = z; ???
                j = j+1;
            end
            
            sigma_t = (1+sqrt(1+4*sigma_tm1^2))/2.;
            
            sigma_tm2 = sigmae_tm1;
            sigma_tm1 = sigma_t;
            t = t + 1;
           
        end    
        
    
    
        
    end
end

% z (s x 1), x (2 x 1), A_i (2 x s)
% val (2 x 1)
function val = g(z, x_i, A_i)   % (1x2)
    val = sum((x_i - A_i*z).^2) / 2.;
end

% z (s x 1), x (2 x 1), A_i (2 x s)
% val (s x 1)
function val = grad_g(z, x_i, A_i)
    val = A_i'*A_i*z - A_i'*x_i;
end

% z (s x 1), v (s x 1), beta = const
function val = g_new(z, v, beta)
    val = g(v) + grad_g(v)'*(z-v) + beta* sum((z - v).^2) / 2.;
end

% Projection operator (see Duchi et al. "Efficient projecctions onto l_1-ball
%                                        for learning in high dimensions")
% z    vector (s x 1)
% pz   projection of z, such that pz = argmin|pz - z|
function pz = simplexProjection(z)
    v = sort(z);
    
    p = zeros(s,1);
    for j=1:s
       p(j) = v(j) - (sum(v(1:j)) - 1) / j; 
    end
    pp = p(p>0);
    
    jmax = max(pp);
    theta = (sum(v(1:jmax)) - 1) / jmax;
    
    pz = bsxfun(@max, z-theta, zeros(s,1));
end
