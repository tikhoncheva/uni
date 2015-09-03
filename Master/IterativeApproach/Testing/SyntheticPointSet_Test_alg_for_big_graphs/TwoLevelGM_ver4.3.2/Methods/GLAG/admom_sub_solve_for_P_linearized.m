%% 
% P = admom_sub_solve_for_P_linearized(alpha,beta,A,B,U,W,tau,Pk,parameters)
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

function P = admom_sub_solve_for_P_linearized(alpha,beta,A,B,U,W,tau,Pk,parameters)

C = alpha+U;
D = beta + W;

if isfield(parameters,'tole')
    tole = parameters.tole;
else % set default value
    tole=1e-5;
end

f = norm(C-A*Pk,'fro')^2 + norm(D-Pk*B,'fro')^2;
f2=f+1;

k=0;
while (f2 > f) && (k<10)
    k=k+1;
    R1 = Pk + tau*A'*(C-A*Pk)/k;
    R2 = Pk + tau*(D-Pk*B)*B'/k;
    
    P= project_DS((R1+R2)/2,tole);
    f2 = norm(C-A*P,'fro')^2 + norm(D-P*B,'fro')^2;
    
end



end
