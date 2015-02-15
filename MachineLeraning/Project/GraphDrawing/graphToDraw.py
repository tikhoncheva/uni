#
## Definition of a graph G + additional functions to initialise nodes of the graph on the plane and calculate graph distances
#

import numpy as np

def k_neighborhood(v, dist, k):

    Nk = np.where(dist[v,:]<=k )
    
    return np.delete(Nk, v)
#end k_neighborhood
    
    
def floyed(A,n):
    
    dist = np.array(A)  #A is given as Gewichtsmatrix 
    for k in range(n):
        for i in range(n):
            for j in range(n):
                dist[i,j] = min(dist[i,j],dist[i,k]+dist[k,j])
    dist[range(n),range(n)] = 0
    
    return dist
# end floyed
    
def dijkstra(A,start):    
    n = A.shape[0] 
    shortest_dist = np.zeros(n, dtype = np.float32)
    V = range(0,n)
    
    for i in V:
        shortest_dist[i] = np.Infinity 
    # end for v 
    shortest_dist[start] = 0
    
    while len(V)!=0:
        i = V.pop(np.argmin(shortest_dist[V]))  # vertex with the smallest distance up to now
        for j in V:
            if A[i,j]==1:   # j is a neighbor of i in V
                tmp = shortest_dist[i] + A[i,j]
                if tmp < shortest_dist[j]:
                    shortest_dist[j] = tmp
                # end if we found a shorter way to j
            # end if
        #end for all neighbors of i in the graph
    # while V is not empty    
    
    return shortest_dist   
#end dijkstra    
    
def dist_with_DijkstraAlg(A):
    n = A.shape[0]
    dist = np.zeros((n,n), dtype = np.float32)
    for i in range(0,n):
        dist[i] = dijkstra(A,i) 
    # end for i
    return dist
#end dist_with_DijkstraAlg(A):
    
   
def init_particles(n,L_0):
    #Initializing p_1, ..., p_n as 2 x n array particles
    particles = np.zeros([2,n])
    for k in range(n):
        particles[0,k] = L_0 * np.cos(2*np.pi*k/n)        
        particles[1,k] = L_0 * np.sin(2*np.pi*k/n)
    return particles
# end def init_particles(n,L_0)



    
class Graph():
    # nV   - number of vertices
    # AdjM - adjazent matrix
    def __init__(self, nV, AdjM):
        self.nV = nV
        self.AdjM = AdjM
        
    def display(self):
        for i in range(0,self.nV):
            print self.AdjM[i,:]
            
    def get_A(self):
        return self.AdjM
        
    def get_n(self):
        return self.nV
# --------------------------------------------------------------------

# --------------------- small test --------------------------------------            
testMpaper = np.array([[np.Infinity,1,np.Infinity,np.Infinity,1,np.Infinity],
                       [1,np.Infinity,np.Infinity,1,1,np.Infinity],
                       [np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,1],
                       [np.Infinity,1,1,np.Infinity,np.Infinity,1],
                       [1,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                       [np.Infinity,np.Infinity,1,1,np.Infinity,np.Infinity]])

if __name__ == "__main__": 
    A = testMpaper
    n = np.size(A,0)
 
    G = Graph(n,A)
    G.display()