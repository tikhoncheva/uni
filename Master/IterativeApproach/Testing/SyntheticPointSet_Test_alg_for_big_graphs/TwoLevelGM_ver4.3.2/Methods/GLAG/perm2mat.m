%% 
% P = perm2mat(p)
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

function P=perm2mat(p)

n=max(size(p));
P=zeros(n);
for k=1:n
   P(k,p(k))=1;
end;

