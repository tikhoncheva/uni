# -*- coding: utf-8 -*-
"""
Created on Thu Jan 29 15:07:12 2015

@author: elias
"""

import numpy as np


def floyed(A,n):
    dist = np.array(A)  #A is given as Gewichtsmatrix 
    for k in range(n):
        for i in range(n):
            for j in range(n):
                dist[i,j] = min(dist[i,j],dist[i,k]+dist[k,j])
#    dist[range(n),range(n)] = 0
    print dist
    
    return dist
# end floyed
    
#okay jetzt versteh ich was marshall macht, findet nur raus ob überhaupt ein
#pfad exisitiert, wahrscheinlich ünnütz für unsere Zwecke, da nur zusammenhängende
#Graphen gegeben sein sollten
def warshall(A, n):
    #A Adjazenz Matrix, n column length of A
    dist = np.array(A)
    for k in range(n):
        for i in range(n):
            if dist[i,k] == 1:
                for j in range(n):
                    if dist[k,j] == 1 :
                        dist[i,j] = 1
    return dist
# end  warshall  
    
def init_particles(n,L_0):
    #Initializing p_1, ..., p_n as 2 x n array particles
    particles = np.zeros([2,n])
    for k in range(n):
        particles[0,k] = L_0 * np.cos(2*np.pi*k/n)        
        particles[1,k] = L_0 * np.sin(2*np.pi*k/n)
    return particles
# end def init_particles(n,L_0)

