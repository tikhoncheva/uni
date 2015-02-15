
"""
Graph Drawing Algorithm from D.Harel & Y.Koren "A fast multi-scale mathod for 
drawing large graphs", 2002 
"""

import random 
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
# G         G = (V,E)
# dist      distance Matrix 
# k         number of clusters
#
# S          Subset of V, |S|=k, indices of k cluster centers
# affinity   array, that for each vertex from V contains index of the cluster
#            this vertex belongs to
def KCenters(G, dist, k):
  
    n = G.get_n()
    
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
# L         current coordinates of nodes
# radius    radius of neighborhood
# maxit     maximum number of iterations
def LocalLayouts(dist, p, radius, K, L_0, eps, maxit):
    n = p.shape[1]     

    pnew, step = Algorithm_KamadaKawai(n, p, radius, dist, K, L_0, eps, maxit)
    
    return pnew
#end  LocalLayouts


## Algorithm from Harel & Korel
# G  given graph, |V| = n
# L  random start layout (2xn)
#
#
def Algorithm_HarelKoren(G, L, K, L_0, eps, maxit):
    print "Start Algorithm of Harel & Koren..."

    # constants
    rad = 7         # radius of local neighborhoods
    it = 4          # number of iterations for the Kamada's and Kawai's algorithm 
    ratio = 3      # ratio between vertices of two consecutive levels
    minSize = 2    # size of the coarsest graph
    maxit = 1000
    steps = 0
    
    # number of nodes in the graph
    n = G.get_n()
    # get adjacency matrix of the Graph
    A = G.get_A()
    # calculate graph distance
    dist = floyed(A,n)
    
    k = minSize
    
    while (k<=n and steps<maxit):
        centers, affinity = KCenters(G, dist, k)

        # coarser graph
        L_local = L[:,centers]
        dist_local = np.asarray(dist[np.ix_(centers,centers)])
        
        radius = max_min_dist(dist_local) * rad        
        
        # local refinement       
        L_local =  LocalLayouts(dist_local, L_local, radius, K, L_0, eps, it*n)
        
        L[:, centers] = L_local
        for v in range(0,n):
            rand  = [random.random(), random.random()] # random noise  (0,0)<rand<(1,1)   
            L[0,v] = L[0,affinity[v]] + rand[0]
            L[1,v] = L[1,affinity[v]] + rand[1]
        #end for v
        k = k * ratio
        steps +=1
    #end while loop    
    print "................. end"
    return L, steps
# end Algorithm_HarelKoren():