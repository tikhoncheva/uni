
"""
Modification of the graph drawing Algorithm from T.Kamada & S.Kawai for purpose of
local beatification used in algorithm from D.Harel and Y.Koren, 
"A fast multi-scale mathod for drawing large graphs", 2002 

"""

import numpy as np
from graphToDraw import *

# ---------------------------------------------------------------------------
# Slow implementation with loops
# ---------------------------------------------------------------------------

#compute the partial derivatives of energy function
def dEnergyOfSprings_loop(radius, n, p, dist, k, l):
    dEx=np.zeros([n,1])
    dEy=np.zeros([n,1])
    # thats inefficient (use slicing, numpy sum ect.), but since its only O(n^2) and we already have O(n^3) it stays for now
    for m in range(n):
        for i in k_neighborhood(dist[m,:], radius):
            div = np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2))
            dEx[m] += k[m,i] * ((p[0,m] - p[0,i]) - l[m,i] *(p[0,m] - p[0,i]) / div ) 
            dEy[m] += k[m,i] * ((p[1,m] - p[1,i]) - l[m,i] *(p[1,m] - p[1,i]) / div ) 
        # end for i
    # end for m      
    return dEx, dEy
#end EnergyOfSprings


# ---------------------------------------------------------------------------
def moveNode_m_loop(radius, p, dist_m, k_m, l_m, Ex_m, Ey_m, m ):
        
    Hess = np.zeros([2,2])
    for i in k_neighborhood(dist_m, radius):
        div = ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 
        Hess[0,0] += 2* k_m[i] * (1 - l_m[i] *(p[1,m] - p[1,i])**2                / div )
        Hess[1,1] += 2* k_m[i] * (1 - l_m[i] *(p[0,m] - p[0,i])**2                / div )  
        Hess[0,1] += 2* k_m[i] * (    l_m[i] *(p[1,m] - p[1,i])*(p[0,m] - p[0,i]) / div ) 
    # end for i
    Hess[1,0]=Hess[0,1]
            
    delta = np.linalg.solve(Hess, np.array([-Ex_m,-Ey_m]))
    p[:,m] = p[:,m] + delta.T

    return p
#End modeNode_m    

# ---------------------------------------------------------------------------
# Faster implementation without loops
# ---------------------------------------------------------------------------

# pairwise euclidean distance between points in 2D
# points    array of n points in R^2

# pdiff     pairwise difference between coordinates (pdiff[:,m] = x_m*1-x)
# dist      pairwise euclidean distance
def pdist(points):
    d, n = points.shape
    assert n != 0, "Empty set of points"
    assert d == 2, "Points are not in 2D"
    
    x = points[0,:]
    y = points[1,:]
    
    nx = np.tile(x,(n,1))
    ny = np.tile(y,(n,1))
    
    pdiff_x = nx - nx.transpose() 
    pdiff_y = ny - ny.transpose() 
    
    dist = np.square(pdiff_x) + np.square(pdiff_y)
    dist = np.sqrt(dist)
    
    dist[range(n), range(n)] = np.Infinity  # to avoid nan, because we nedd to divide by dist

    return dist, pdiff_x, pdiff_y
# end pdist   
    
# ---------------------------------------------------------------------------    
# compute the partial derivatives of energy function 
def dEnergyOfSprings(radius, n, pdist_xy, pdiff_x, pdiff_y, k, l):
      
    C = np.divide(l, pdist_xy.T)   # elementwise division  
    dEx = np.diag(np.dot(k, pdiff_x) - np.dot(k, np.multiply(C, pdiff_x)) )
    dEy = np.diag(np.dot(k, pdiff_y) - np.dot(k, np.multiply(C, pdiff_y)) )
    return dEx, dEy
#end EnergyOfSprings

# ---------------------------------------------------------------------------
# move one node to it optimal position

def moveNode_m(radius, p, pdist_xy, pdiff_x, pdiff_y, k, l, rhs, m ):
    
    pdist_xy3 = np.power(pdist_xy,3)
    C = np.divide(l[m,:], pdist_xy3[:,m])   # const
            
    Hess = np.zeros([2,2])
    Hess[0,0] = np.sum(k[m,:]) - np.dot(k[m,:], np.multiply(C, pdiff_y[:,m] * pdiff_y[:,m]))
    Hess[1,1] = np.sum(k[m,:]) - np.dot(k[m,:], np.multiply(C, pdiff_x[:,m] * pdiff_x[:,m]))
    Hess[0,1] =                  np.dot(k[m,:], np.multiply(C, pdiff_x[:,m] * pdiff_y[:,m]))
    Hess[1,0] = Hess[0,1]
                                       
    incr = np.linalg.solve(Hess, rhs)
    p[:,m] = p[:,m] + incr.T
            
    return p
#End modeNode_m    
# ---------------------------------------------------------------------------            
# ---------------------------------------------------------------------------        
def Algorithm_KamadaKawai_kN(radius, n, p, dist, k, l , nit):
    
    it=0 
    neighborhood = (dist<radius)
    
    k1 = k.copy()
    k1[~neighborhood] = 0
    l1 = l.copy()
    l1[~neighborhood] = 0
    
    #compute the partial derivatives of energy function
    pdist_xy, pdiff_x,pdiff_y = pdist(p)  
       
    #compute the partial derivatives of energy function
    Ex, Ey = dEnergyOfSprings(radius, n, pdist_xy, pdiff_x, pdiff_y, k1, l1)
    Delta = np.sqrt(np.square(Ex) + np.square(Ey))
    
    while(it< nit):
        m = np.argmax(Delta)
        
        # move one node
        rhs = np.array([-Ex[m],-Ey[m]])
        p = moveNode_m(radius, p, pdist_xy, pdiff_x, pdiff_y, k1, l1, rhs, m)
        
        #recompute the partial derivatives of energy function      
        pdist_xy, pdiff_x,pdiff_y = pdist(p)  
        Ex, Ey = dEnergyOfSprings(radius, n, pdist_xy, pdiff_x, pdiff_y, k1, l1)
        Delta = np.sqrt(np.square(Ex) + np.square(Ey))
        
        it += 1
    # end while(np.max(Delta)>eps):   
    return p, it
# end newtonraphson    