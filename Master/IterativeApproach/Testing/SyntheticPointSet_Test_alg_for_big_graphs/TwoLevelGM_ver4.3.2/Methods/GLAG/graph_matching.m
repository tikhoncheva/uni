%% 
% [P,Pp] = graph_matching(A,B,param)
%
% Inputs:
%   - A,B: adjacency matrices of the graphs to be matched
%   - param: structure for parameters:
%       * param.verbose [default 0] 
%       * param.maxIter [default 30000]
%       * param.N [default 100]         Computes the closest permuation matrix after each N iterations
%       * param.tol [default 2e-2]      Tolerance in the difference of the objective funcion
%       * param.tol2 [default 9e-9]     Tolerance in Frobenius norm of AP-PB
%       * param.c [default 2]          Parameter c in the optimization. It doesn't affect the convergence.
%
% Outputs:
%   - P: doubly stochastic matrix minimizing the objective function
%   - Pp: best permutation matrix found
%
% The code is released under the terms of the GNU GPLv3 License.
% If you use the code for your research please cite the following paper:
%
% Robust Multimodal Graph Matching: Sparse Coding Meets Graph Matching
% Advances in Neural Information Processing Systems 26 (NIPS 2013)
% M. Fiori, P. Sprechmann, J. Vogelstein, P. Musé, G. Sapiro
% 
% ***************************************************************************
% *   This program is free software; you can redistribute it and/or modify  *
% *   it under the terms of the GNU General Public License as published by  *
% *   the Free Software Foundation; either version 3 of the License, or     *
% *   (at your option) any later version.                                   *
% *                                                                         *
% *   You should have received a copy of the GNU General Public License     *
% *   along with this program; if not, write to the                         *
% *   Free Software Foundation, Inc.,                                       *
% *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
% ***************************************************************************
%
% Marcelo Fiori, mfiori@fing.edu.uy                                  (2013)


function [P,Pp]=graph_matching(A,B,parameters)

narginchk(2, 3);
if nargin<3
    parameters.verbose=1;
end

if isfield(parameters,'verbose')
    verbose = parameters.verbose;
else % set default value
    verbose = 1;
end

if isfield(parameters,'tol')
    tol = parameters.tol;
else % set default value
    tol=2e-2;
end

if isfield(parameters,'maxIter')
    maxIter = parameters.maxIter;
else % set default value
    maxIter=30000;
end


if isfield(parameters,'tol2')
    tol2 = parameters.tol2;
else % set default value
    tol2=9e-9;
end

if isfield(parameters,'N')
    N = parameters.N;
else % set default value
    N=100;
end

if isfield(parameters,'c')
    c = parameters.c;
else % set default value
    c=2;
end


p=size(A,1);


param.verbose=verbose;

forig = @(P) sum(sum(sqrt((A*P).^2 + (P*B).^2)));

P=ones(p)/p;

U=zeros(p);
W=zeros(p);

iter=0;

rhoA = max(eig(A'*A));
rhoB = max(eig(B'*B));
rho=max(rhoA,rhoB);
tau=0.8/rho;


var=1;
normAPPB=1;
normAPPB1=1;
fori=1;

Pmin=P;
fmin=1e10;
zigzag1=0;
Nzigzag = 10;

% Main loop
while (normAPPB>tol) && (normAPPB1>tol) && (var > tol2) && (iter < maxIter)

    iter=iter+1;
    normAPPB_o=normAPPB;
    Pold=P;
    fori_o=fori;
    
    %solve for alpha,beta
    [alpha,beta] = admom_sub_solve_for_alpha_beta(A,B,P,U,W,c);
    
    %solve for P
    param.tole = 1e-4;
    if zigzag1>Nzigzag
        P= admom_sub_solve_for_P_onestep(alpha,beta,A,B,U,W,P);
        zigzag1=0;
        Nzigzag = Nzigzag *1.2;
    else
        P = admom_sub_solve_for_P_linearized(alpha,beta,A,B,U,W,tau,P,param);
    end
    
    %update
    U = U + alpha - A*P;
    W = W + beta - P*B;
    
    fori = forig(P);
  
    % Each N iterations, compute the closest permutation matrix and check
    % if it gives a perfect match
    if (mod(iter,N)==0)
        corr=lapjv(-P,0.01);
        P1=perm2mat(corr);
        normAPPB1=norm(A*P1-P1*B,'fro');
        fau = forig(P1);
        if fau < fmin
            fmin=fau;
            Pmin=P1;
        end
        
    end
    
    forigi(iter)=fori;

    % if the optimization gets stuck, reinitialize with the identity matrix
    if (iter > 5)
        normAPPB=norm(A*P-P*B,'fro');
        var = abs(fori - fori_o) + abs(normAPPB- normAPPB_o);
        var=var/fori;
        zigzag = (forigi(iter-2)<forigi(iter-1)) * (forigi(iter-2)<forigi(iter-3)) * (forigi(iter)<forigi(iter-1)) * (forigi(iter-4)<forigi(iter-3)) * (forigi(iter-4)<forigi(iter-5));
        zigzag1 = zigzag1 + zigzag;
        
        if (iter==6) && (var<1e-7)
            var=1;
            P=eye(p);
        end
    end;
    
    if (verbose)    fprintf('it :%i  normAPPB: %1.7f  normAPPB1: %1.7f   forig: %1.7f  var: %1.10f  P-Pold: %1.8f \n',iter,normAPPB,normAPPB1,fori,var,norm(P-Pold,'fro')); end;
    
end

corr=lapjv(-P,0.01);
Pp=perm2mat(corr);
fau = forig(Pp);
if fmin < fau
    fau=fmin;
    Pp=Pmin;
end


end
