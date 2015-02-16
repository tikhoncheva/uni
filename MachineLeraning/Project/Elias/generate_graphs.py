# -*- coding: utf-8 -*-
"""
Created on Sat Feb 14 15:09:36 2015

@author: elias
"""

import numpy as np

#import matplotlib.pyplot as plot
#
#import time
#
#from floyed import *


def load_graph():

    graph = np.loadtxt('3elt2.rmf',dtype='int',skiprows=1,usecols = (1,2,3))
    
    n_vertices = int(np.max(graph))
    n_edges = np.size(graph,0)
    
    
    graph_Matrix = np.zeros([n_vertices,n_vertices])
    
    for i in range(n_edges):
        graph_Matrix[graph[i,0]-1,graph[i,1]-1] = graph[i,2]    #edge with weight
    
    return graph_Matrix



    
def generate_full_binary_tree(n):
    #n is number of layers
    m = 2**n-1
    graph = np.zeros([m,m])
    for i in range(2**(n-1)-1):
        graph[i,2*i+1], graph[i,2*i+2] = 1,1
        graph[2*i+1,i], graph[2*i+2,i] = 1,1    

    graph = 1./graph        
    return graph






def generate_graph(v,e):
    # A simple algorithm to produce not necercarilly connected graphs
    #Mainly for testing purposes
    assert v <= e+1  
    
    M = v*(v-1)/2 - e
    graph = np.ones([v,v])
    auxarray = []
    for i in range(0,v):
        for j in range(i+1,v):
            auxarray.append([i,j])
            

    k=0
    while( k <M):
        rand = random.choice(auxarray)
        if np.sum(graph[rand[0],:] ==2) or np.sum(graph[:,rand[1]] ==2) :
            auxarray.remove(rand)
            continue
        graph[rand[0],rand[1]] ,graph[rand[1],rand[0]]  = 0 , 0
        auxarray.remove(rand)
        k += 1
        

#        if not auxarray:
#            print 'Not enough edges'
#            break
        
    graph = 1./graph
    return graph
    



