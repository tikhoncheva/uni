## Examples from paper of Kamada, Kawai 
# " An Algorithm for drawing general undirected graphs"
#

import random
import numpy as np
from generate_graphs import load_adjM, load_coord



def example_3elt():
    
    A = load_adjM('../instances/3elt.rmf')
    n = np.size(A,0) 
    A = A[0:n,0:n]
    p = load_coord('../instances/3elt.xyz',n)
    
    return A,p
# end example_3elt()

# square grid graph 
def example_grid(nn):
    n = int(np.sqrt(nn))
    
    A = np.zeros([nn,nn])
    for i in range(1,n-1):
        for j in range(1,n-1):
            A[n*i+j, n*i + (j-1)],A[n*i + (j-1), n*i+j] = 1,1
            A[n*i+j, n*i + (j+1)],A[n*i + (j+1), n*i+j] = 1,1
            A[n*i+j, n*(i-1) + j],A[n*(i-1) + j, n*i+j] = 1,1
            A[n*i+j, n*(i+1) + j],A[n*(i+1) + j, n*i+j] = 1,1
        #end for j
    #end for i
    
    for i in range(1, n):
        A[i-1,i], A[i,i-1] = 1, 1
        A[n*(n-1) + i-1, n*(n-1) + i], A[n*(n-1) + i, n*(n-1) + i-1] = 1, 1

        A[n*(i-1), n*i], A[n*i, n*(i-1)] = 1, 1
        A[n*(i-1) + n-1 , n*i+n-1],A[n*i+n-1, n*(i-1) + n-1] = 1, 1
    #end for i        
    
    A[np.where(A==0)] = np.Infinity
    
    return A
# end example_grid
    
# sparse square grid graph : 1/4 of the edges omitted at random
def example_sgrid(nn):
    n = int(np.sqrt(nn))
        
    A = np.zeros([nn,nn])
    for i in range(1,n-1):
        for j in range(1,n-1):
            A[n*i+j, n*i + (j-1)],A[n*i + (j-1), n*i+j] = 1,1
            A[n*i+j, n*i + (j+1)],A[n*i + (j+1), n*i+j] = 1,1
            A[n*i+j, n*(i-1) + j],A[n*(i-1) + j, n*i+j] = 1,1
            A[n*i+j, n*(i+1) + j],A[n*(i+1) + j, n*i+j] = 1,1
        #end for j
    #end for i
    
    for i in range(1, n):
        A[i-1,i], A[i,i-1] = 1, 1
        A[n*(n-1) + i-1, n*(n-1) + i], A[n*(n-1) + i, n*(n-1) + i-1] = 1, 1

        A[n*(i-1), n*i], A[n*i, n*(i-1)] = 1, 1
        A[n*(i-1) + n-1 , n*i+n-1],A[n*i+n-1, n*(i-1) + n-1] = 1, 1
    #end for i        
    
    #delete ramdomly 1/4 of edges
    nedges = 2*n*n - 2*n
    A = np.reshape(A, (nn*nn))
    for e in range(0, int(nedges/3)):
        edgelist = np.where(A==1)[0]
        rande = edgelist[random.randint(0,len(edgelist)-1)]
        A[rande] = 0
    #end    
    A = np.reshape(A, (nn,nn))
    for i in range(0,n):
        for j in range (0,n):
            if A[i,j]==0:
                A[j,i]=0
            #end if
        #end for j
    #end for i
        
    A[np.where(A==0)] = np.Infinity
    
    return A
# end example_grid
    