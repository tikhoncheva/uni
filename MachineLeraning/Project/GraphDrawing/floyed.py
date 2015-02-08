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

def newtonraphson(length,p,k,n,eps):
    #compute the partial derivatives    
    Ex=np.zeros([n,1])
    Ey=np.zeros([n,1])
    # thats inefficient (use slicing, numpy sum ect.), but since its only O(n^2) and we already have O(n^3) it stays for now
    for m in range(n):
        for i in np.delete(range(n),m):
            Ex[m] += k[m,i] * ((p[0,m] - p[0,i]) - length[m,i] *(p[0,m] - p[0,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
            Ey[m] += k[m,i] * ((p[1,m] - p[1,i]) - length[m,i] *(p[1,m] - p[1,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
    
    Delta = np.sqrt(Ex*Ex + Ey*Ey)
    maxit_outer=0
    while(np.max(Delta)>eps and maxit_outer<n+1):
        m = np.argmax(Delta)
        maxit_in=0
        while(Delta[m] > eps and maxit_in<1000):
            Hess = np.zeros([2,2])
            for i in np.delete(range(n),m):
                Hess[0,0] += k[m,i] * (1 - length[m,i] *(p[1,m] - p[1,i])**2 / ( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
                Hess[0,1] += k[m,i] * (length[m,i] *(p[1,m] - p[1,i])*(p[0,m] - p[0,i]) / (( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5) ) 
                Hess[1,1] += k[m,i] * (1 - length[m,i] *(p[0,m] - p[0,i])**2 / ( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
            Hess[1,0]=Hess[0,1]
            
            incr = np.linalg.solve(Hess, np.array([-Ex[m],-Ey[m]]))
            #print p[:,m], incr.T , p[:,m] + incr.T
            p[:,m] = p[:,m] + incr.T

#            Ex=np.zeros([n,1])
#            Ey=np.zeros([n,1])           
#            for j in range(n):
#                for i in np.delete(range(n),j):
#                    Ex[j] += k[j,i] * ((p[0,j] - p[0,i]) - length[j,i] *(p[0,j] - p[0,i]) / np.sqrt(( (p[0,j] - p[0,i])**2 + (p[1,j] - p[1,i])**2)) ) 
#                    Ey[j] += k[j,i] * ((p[1,j] - p[1,i]) - length[j,i] *(p[1,j] - p[1,i]) / np.sqrt(( (p[0,j] - p[0,i])**2 + (p[1,j] - p[1,i])**2)) )   

            Ex[m] = 0  
            Ey[m] = 0
            for i in np.delete(range(n),m):
                Ex[m] += k[m,i] * ((p[0,m] - p[0,i]) - length[m,i] *(p[0,m] - p[0,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
                Ey[m] += k[m,i] * ((p[1,m] - p[1,i]) - length[m,i] *(p[1,m] - p[1,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) )
            #unsure if I have to update the hole vector Ex and Ey or only the entry Ex[m]                
                
            Delta[m] = np.sqrt(Ex[m]**2 + Ey[m]**2)
            maxit_in +=1

        maxit_outer+=1
       
    return p
# end newtonraphson    

