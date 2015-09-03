%% 
% Ps = project_DS(Ti,varargin)
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


function xk=project_DS(Ti,varargin)

tol=1e-5;
if ~isempty(varargin)
    tol=varargin{1};
end


n=size(Ti,1);

var=1;

Jn=ones(n)/n;
W=eye(n)-Jn;

xk=Ti;

iter=0;
max_iter=200;
while (var>tol) && (iter < max_iter)
    
    iter=iter+1;
    xkold = xk;

    yk =  W*(xk)*W + Jn;
    xk = max(0,yk);

    var = norm(xk- xkold,1);

end

end
