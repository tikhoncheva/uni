"""
Graph drawing Algorithm from T.Kamada & S.Kawai f, 
"An Algorithm for drawing general undirected graphs", 1989 

"""


import numpy as np
import time

# ---------------------------------------------------------------------------
# Slow implementation with loops
# ---------------------------------------------------------------------------

#compute the partial derivatives of energy function
def dEnergyOfSprings_loops(n, p, k, l):
    
    dEx=np.zeros([n,1])
    dEy=np.zeros([n,1])
    # thats inefficient (use slicing, numpy sum ect.), but since its only O(n^2) and we already have O(n^3) it stays for now
    for m in range(n):
        for i in np.delete(range(n),m):
            dEx[m] += k[m,i] * ((p[0,m] - p[0,i]) - l[m,i] *(p[0,m] - p[0,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
            dEy[m] += k[m,i] * ((p[1,m] - p[1,i]) - l[m,i] *(p[1,m] - p[1,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
        # end for i
    # end for m      
    return dEx, dEy
#end EnergyOfSprings

# move one node
def moveNode_m_loops(n, p, k, l, eps, rhs, Delta_m, m):
    
    while(Delta_m > eps):
            Hess = np.zeros([2,2])
            for i in np.delete(range(n),m):
                Hess[0,0] += k[m,i] * (1 - l[m,i] *(p[1,m] - p[1,i])**2                / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
                Hess[1,1] += k[m,i] * (1 - l[m,i] *(p[0,m] - p[0,i])**2                / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
                Hess[0,1] += k[m,i] * (    l[m,i] *(p[1,m] - p[1,i])*(p[0,m] - p[0,i]) / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 ) 
            # end for i
            Hess[1,0]=Hess[0,1]
            
            incr = np.linalg.solve(Hess, rhs)
            p[:,m] = p[:,m] + incr.T

            # recalculate Delta[m]
            Ex_m = 0  
            Ey_m= 0
            for i in np.delete(range(n),m):
                Ex_m += k[m,i] * ((p[0,m] - p[0,i]) - l[m,i] *(p[0,m] - p[0,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
                Ey_m += k[m,i] * ((p[1,m] - p[1,i]) - l[m,i] *(p[1,m] - p[1,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) )
            #end for i 
            rhs = np.array([-Ex_m,-Ey_m])                    
            Delta_m = np.sqrt(Ex_m**2 + Ey_m**2)
        # end while(Delta[m] > eps):
            
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
    
   
#compute the partial derivatives of energy function   
def dEnergyOfSprings(n, pdist_xy, pdiff_x, pdiff_y, k, l):
          
    C = np.divide(l, pdist_xy.T)   # elementwise division  
    dEx = np.diag(np.dot(k, pdiff_x) - np.dot(k, np.multiply(C, pdiff_x)) )
    dEy = np.diag(np.dot(k, pdiff_y) - np.dot(k, np.multiply(C, pdiff_y)) )
    return dEx, dEy
#end EnergyOfSprings
    
# faster implementation without for loops    
def moveNode_m(n, p, pdist_xy, pdiff_x, pdiff_y, k, l, eps, rhs, Delta_m, m):
    
    while(Delta_m > eps):
            pdist_xy3 = np.power(pdist_xy,3)
            C = np.divide(l[m,:], pdist_xy3[:,m])   # const
            
            Hess = np.zeros([2,2])
            Hess[0,0] = np.sum(k[m,:]) - np.dot(k[m,:], np.multiply(C, pdiff_y[:,m] * pdiff_y[:,m]))
            Hess[1,1] = np.sum(k[m,:]) - np.dot(k[m,:], np.multiply(C, pdiff_x[:,m] * pdiff_x[:,m]))
            Hess[0,1] =                  np.dot(k[m,:], np.multiply(C, pdiff_x[:,m] * pdiff_y[:,m]))
            Hess[1,0] = Hess[0,1]
                                       
            incr = np.linalg.solve(Hess, rhs)
            p[:,m] = p[:,m] + incr.T
            
            # recalculate Delta_m
            pdist_xy, pdiff_x,pdiff_y = pdist(p) 
            C = np.divide(l[m,:], pdist_xy[m,:])   # elementwise division   
            Ex_m = np.dot(k[m,:], pdiff_x[:,m]) - np.dot(k[m,:], np.multiply(C, pdiff_x[:,m]))         
            Ey_m = np.dot(k[m,:], pdiff_y[:,m]) - np.dot(k[m,:], np.multiply(C, pdiff_y[:,m]))  
            
            Delta_m = np.sqrt(Ex_m **2 + Ey_m**2)
            rhs = np.array([-Ex_m,-Ey_m])  
            
        # end while(Delta[m] > eps):
            
    return p
#End modeNode_m      

# ---------------------------------------------------------------------------        
def Algorithm_KamadaKawai_step(n, p, k, l, eps, nit):

    starttime = time.time()        
    
    #compute the partial derivatives of energy function
    pdist_xy, pdiff_x,pdiff_y = pdist(p)    
    Ex, Ey = dEnergyOfSprings(n, pdist_xy, pdiff_x, pdiff_y, k, l)
    Delta = np.sqrt(np.square(Ex) + np.square(Ey))


    if np.max(Delta) > eps: 
        m = np.argmax(Delta)                
        # move node  m to its optimal position
        rhs = np.array([-Ex[m],-Ey[m]])
        p = moveNode_m(n, p, pdist_xy, pdiff_x, pdiff_y, k, l, eps, rhs, Delta[m], m)
                
    # end if(np.max(Delta)>eps):  

    stoptime = time.time()
    print "One step of the KamadaKawai Algorithm took {0:0.6f} sec". format(stoptime-starttime) 
    
    return p
# end Algorithm_KamadaKawai 
    

# ---------------------------------------------------------------------------        
def Algorithm_KamadaKawai(n, p, k, l, eps, nit):
    starttime = time.time()    

    maxit_outer = 0
    
    
    #compute the partial derivatives of energy function
    pdist_xy, pdiff_x,pdiff_y = pdist(p)    
    Ex, Ey = dEnergyOfSprings(n, pdist_xy, pdiff_x, pdiff_y, k, l)
    Delta = np.sqrt(np.square(Ex) + np.square(Ey))


    while(np.max(Delta)>eps and maxit_outer< nit):

        m = np.argmax(Delta)        
        
        # move node  m to its optimal position
        rhs = np.array([-Ex[m],-Ey[m]])
        p = moveNode_m(n, p, pdist_xy, pdiff_x, pdiff_y, k, l, eps, rhs, Delta[m], m)
                
        #recompute the partial derivatives of energy function
        eucdist, pdiff_x,pdiff_y = pdist(p)  
        Ex, Ey = dEnergyOfSprings(n, eucdist, pdiff_x, pdiff_y, k, l)
        Delta = np.sqrt(np.square(Ex) + np.square(Ey))
        
        maxit_outer += 1
    # end while(np.max(Delta)>eps):  

    stoptime = time.time()
    print "Draw the graph ({0:5d} nodes) with Algorithm of KamadaKawai: {1:0.6f} sec and {2:4d} steps". format(n, stoptime-starttime, maxit_outer) 
    
    return p, maxit_outer
# end Algorithm_KamadaKawai   
    
    
    

 
