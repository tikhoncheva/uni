%% 
% P= admom_sub_solve_for_P_onestep(alpha,beta,A,B,U,W,Pk)
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


function P2= admom_sub_solve_for_P_onestep(alpha,beta,A,B,U,W,Pk)

C = alpha+U;
D = beta + W;

f = norm(C-A*Pk,'fro')^2 + norm(D-Pk*B,'fro')^2;

eta=0.7;

max_iter_in=50;
N=5;

step=1;
grad = A'*(C-A*Pk) + (D-Pk*B)*B';

notGoodEnough=1; iter_in=0;

while (notGoodEnough) && (iter_in < max_iter_in)
    iter_in=iter_in+1;
    P1 = Pk+step*grad;
    P2= project_DS(P1);
    
    for i=1:N
        a=1/i;
        Pc = (1-a)*Pk + a*P2;
        fc = norm(C-A*Pc,'fro')^2 + norm(D-Pc*B,'fro')^2;
        if fc < f
            P2=Pc;
            notGoodEnough=0;
            break;
        end
    end

    step=step*eta;
    
end
    
end
