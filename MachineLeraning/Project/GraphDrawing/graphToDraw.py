#
## Definition of a graph G 
# nV   - number of vertices
# AdjM - adjazent matrix

import numpy as np

class Graph():
    
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