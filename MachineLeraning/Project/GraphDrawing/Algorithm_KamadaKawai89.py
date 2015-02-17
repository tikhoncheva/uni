# -*- coding: utf-8 -*-
"""
Created on Tue Feb 10 08:43:24 2015

@author: kitty
"""

import numpy as np
import time

def dEnergyOfSprings(n, p, k, l):
    #compute the partial derivatives of energy function
    
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


# ---------------------------------------------------------------------------
def moveNode_m(n, p, k, l, eps, Ex, Ey, Delta_m, m):
    
    while(Delta_m > eps):
            Hess = np.zeros([2,2])
            for i in np.delete(range(n),m):
                Hess[0,0] += k[m,i] * (1 - l[m,i] *(p[1,m] - p[1,i])**2                / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
                Hess[1,1] += k[m,i] * (1 - l[m,i] *(p[0,m] - p[0,i])**2                / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
                Hess[0,1] += k[m,i] * (    l[m,i] *(p[1,m] - p[1,i])*(p[0,m] - p[0,i]) / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 ) 
            # end for i
            Hess[1,0]=Hess[0,1]
            
            incr = np.linalg.solve(Hess, np.array([-Ex[m],-Ey[m]]))
            p[:,m] = p[:,m] + incr.T

            # recalculate Delta[m]
            Ex[m] = 0  
            Ey[m] = 0
            for i in np.delete(range(n),m):
                Ex[m] += k[m,i] * ((p[0,m] - p[0,i]) - l[m,i] *(p[0,m] - p[0,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
                Ey[m] += k[m,i] * ((p[1,m] - p[1,i]) - l[m,i] *(p[1,m] - p[1,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) )
            #end for i 
            Delta_m = np.sqrt(Ex[m]**2 + Ey[m]**2)
        # end while(Delta[m] > eps):
            
    return p
#End modeNode_m    


# ---------------------------------------------------------------------------        
def mainAlgorithm(n, p, k, l, eps, nit):
    starttime = time.time()    
    
    maxit_outer=0 
    #compute the partial derivatives of energy function
    Ex, Ey = dEnergyOfSprings(n, p, k, l)    
    Delta = np.sqrt(Ex*Ex + Ey*Ey)
    
    while(np.max(Delta)>eps and maxit_outer< nit):
        m = np.argmax(Delta)
        
        # move one node to its optimal position
        p = moveNode_m(n, p, k, l, eps, Ex, Ey, Delta[m], m)
                
        #recompute the partial derivatives of energy function
        Ex, Ey = dEnergyOfSprings(n, p, k, l)
        Delta = np.sqrt(Ex*Ex + Ey*Ey)    
        
        maxit_outer += 1
    # end while(np.max(Delta)>eps):  

    stoptime = time.time()
    print "Draw the graph ({0:5d} nodes) with Algorithm of KamadaKawai: {1:0.6f} sec and {2:4d} steps". format(n, stoptime-starttime, maxit_outer) 
    
    return p, maxit_outer
# end newtonraphson    