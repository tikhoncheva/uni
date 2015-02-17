
"""
Graph Drawing Algorithm from D.Harel & Y.Koren "A fast multi-scale mathod for 
drawing large graphs", 2002 
"""

import random 
import time
import numpy as np

from Algorithm_KamadaKawai89_kN import mainAlgorithm as Algorithm_KamadaKawai
from graphToDraw import *


#----------------------------------------------------------------------------
## return max_{v in S} min_{u in S} dist[u][v]
# S         set of nodes
# dist      distance matrix
def max_min_dist(dist):
    n = dist.shape[0]
    
    cdist  = dist.copy() # copy local distance matrix
    cdist[range(n),range(n)] = np.Infinity # set infinity on the diagonal
    
    min_u = np.zeros(n, dtype = np.int8)
    for u in range(0,n):
        min_u[u] = min(cdist[u,:])
    # end for u
    return max(min_u)
#end  max_min_dist(S, dist):
 
 
#----------------------------------------------------------------------------
## KCenters clustering
#---------------------------------------------------------------------------- 
# n         number of nodes in the graph
# dist      distance Matrix 
# k         number of clusters
#
# S          Subset of V, |S|=k, indices of k cluster centers
# affinity   array, that for each vertex from V contains index of the cluster
#            this vertex belongs to
def KCenters(n, dist, k):
    
    # copy of dist matrix with zeros on the main diagonal
    cdist = dist.copy()
    cdist[range(n), range(n)] = 0

    S = []      
    V = range(0,n)
    
    u= random.randint(0,n-1) # return random node in V(G)    
    S.append(u) 
    V.remove(u)

    for i in range(1,k):
        #u = argmax_{w in V} min{s in S} d_ws
        dist_to_S = np.min(dist[:,S], axis=1)
        u = np.argmax(dist_to_S)

        S.append(u)
        V.remove(u)
    #end for i 
    
    affinity = np.zeros(n, dtype = np.int8)
    for i in range(0,n):
        affinity[i] = S[np.argmin(cdist[i,S])]
    #end for i    
    
    return S, affinity
# end KCenters
   
#----------------------------------------------------------------------------    
## LocalLayout : find a locally nice layout (modification of Algorithm of T.Kamada & S.Kawai)
#----------------------------------------------------------------------------   
# dist      disantce matrix between all pairs of nodes
# p         current coordinates of nodes
# radius    radius of neighborhood
# maxit     maximum number of iterations
# K         strength of spring
# L_0       side of the display area
   
def LocalLayouts(radius, p, dist, k, l, maxit):
    
    n = p.shape[1]     

    pnew, it = Algorithm_KamadaKawai(radius, n, p, dist, k, l, maxit)
    
    return pnew, it
#end  LocalLayouts


## Algorithm from Harel & Korel
# n  number of nodes in the given graph G, |V| = n
# p  random start layout (2xn)
#
#
def Algorithm_HarelKoren(n, p, dist, k, l, maxit):
    starttime = time.time()
    
    # constants
    rad = 7         # radius of local neighborhoods
    it = 4          # number of iterations for the Kamada's and Kawai's algorithm 
    ratio = 3       # ratio between vertices of two consecutive levels
    minSize = 10    # size of the coarsest graph

    steps = 0       # number of iterations
    stepsKK = 0     # number of local beautifications
    maxit = 1000    # maximal number of iterations
    
    m = minSize
    
    while (m<=n and steps<maxit):
        centers, affinity = KCenters(n, dist, m)

        # coarser graph
        p_local = p[:,centers]
        
        dist_local = np.asarray(dist[np.ix_(centers,centers)])
        k_local =  np.asarray(k[np.ix_(centers,centers)])       
        l_local =  np.asarray(l[np.ix_(centers,centers)])       
        radius = max_min_dist(dist_local) * rad        
        
        # local refinement       
        p_local, stepsKK =  LocalLayouts(radius, p_local, dist_local, k_local, l_local, it*n)
        
        p[:, centers] = p_local
        for v in range(0,n):
            rand  = [random.random(), random.random()] # random noise  (0,0)<rand<(1,1)
            p[0,v] = p[0,affinity[v]] + 0.1*rand[0]
            p[1,v] = p[1,affinity[v]] + 0.1*rand[1]
        #end for v
        m = m * ratio
        steps +=1
    #end while loop    
        
    stoptime = time.time()
    print "Draw the graph ({0:5d} nodes) with Algorithm of HarelKoren: {1:0.6f} sec and {2:4d} steps". format(n, stoptime-starttime, steps)
    
    return p, steps
# end Algorithm_HarelKoren():