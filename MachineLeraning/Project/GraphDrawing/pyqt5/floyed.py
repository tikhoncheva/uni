# -*- coding: utf-8 -*-
"""
Created on Thu Jan 29 15:07:12 2015

@author: elias
"""
import numpy as np

import matplotlib.pyplot as plot

# from pylab import *

#testing matrix as weight matrix
testM = [[0,1,2,1,np.Infinity],[1,0,np.Infinity,1,np.Infinity],[1.5,np.Infinity,0,np.Infinity,np.Infinity],[1,1,np.Infinity,0,1],[np.Infinity,np.Infinity,np.Infinity,1,0]]
testM=np.array(testM)
#testing matrix as adjazenz Matrix
testMa = [[1,1,0,1,0],[1,1,0,1,0],[0,0,1,0,0],[1,1,0,1,1],[0,0,0,1,1]]

testMpaper = np.array([[np.Infinity,1,np.Infinity,np.Infinity,1,np.Infinity],[1,np.Infinity,np.Infinity,1,1,np.Infinity],[np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,1],[np.Infinity,1,1,np.Infinity,np.Infinity,1],[1,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity],[np.Infinity,np.Infinity,1,1,np.Infinity,np.Infinity]])

def floyed(A,n):
    dist = np.array(A)  #A is given as Gewichtsmatrix 
    for k in range(n):
        for i in range(n):
            for j in range(n):
                dist[i,j] = min(dist[i,j],dist[i,k]+dist[k,j])
    return dist
    
    
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
    
def init_particles(n,L_0):
    #Initializing p_1, ..., p_n as 2 x n array particles
    particles = np.zeros([2,n])
    for k in range(n):
        particles[0,k] = L_0 * np.cos(2*np.pi*k/n)        
        particles[1,k] = L_0 * np.sin(2*np.pi*k/n)
    return particles
    
    



def plotGraph(A,particls,n, fileNameToSave):
    f = plot.figure()
    plot.gray()
    #axis('equal')
    plot.scatter(particls[0,],particls[1,])
    for i in range(n):
        for j in range(i+1,n):
            if A[i,j] < np.Infinity :
                plot.plot([particls[0,i],particls[0,j]],[particls[1,i],particls[1,j]])
    
    plot.show()
    f.savefig(fileNameToSave)


#haupt algo
A = testMpaper
n = np.size(A,0)

dist = floyed(A,n)

L_0 = 1     #constant
L = L_0 / np.max(dist)
K = 1       #constant

length = L * dist #length is matrix l_ij all those matrices (d, l k) are bigger than needed 
k = K * 1./(dist**2) #Attention, infinity on diagonals, we dont need them so i dont care atm

p =  init_particles(n,L_0)  #particles p1, ... ,pn




def newtonraphson(length,p,k,n):
    #compute the partial derivatives
    Ex=np.zeros([n,1])
    Ey=np.zeros([n,1])
    # thats inefficient (use slicing, numpy sum ect.), but since its only O(n^2) and we already have O(n^3) it stays for now
    for m in range(n):
        for i in np.delete(range(n),m):
            Ex[m] += k[m,i] * ((p[0,m] - p[0,i]) - length[m,i] *(p[0,m] - p[0,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
            Ey[m] += k[m,i] * ((p[1,m] - p[1,i]) - length[m,i] *(p[1,m] - p[1,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
    
    Delta = np.sqrt(Ex*Ex + Ey*Ey)
    
    eps=0.5
    maxit_outer=0
    while(np.max(Delta)>eps and maxit_outer<5):
        m = np.argmax(Delta)
        maxit_in=0
        print ('delta m ' , Delta[m], m)
        while(Delta[m] > eps and maxit_in<10):
            Hess = np.zeros([2,2])
            for i in np.delete(range(n),m):
                Hess[0,0] += k[m,i] * (1 - length[m,i] *(p[1,m] - p[1,i])**2 / ( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
                Hess[0,1] += k[m,i] * (length[m,i] *(p[1,m] - p[1,i])*(p[0,m] - p[0,i]) / (( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5) ) 
                Hess[1,1] += k[m,i] * (1 - length[m,i] *(p[0,m] - p[0,i])**2 / ( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
            Hess[1,0]=Hess[0,1]
            
            incr = np.linalg.solve(Hess, np.array([-Ex[m],-Ey[m]]))
            #print p[:,m], incr.T , p[:,m] + incr.T
            p[:,m] = p[:,m] + incr.T

#            Ex[m] = 0  
#            Ey[m] = 0            
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
            print (Delta[m])
            maxit_in +=1
        maxit_outer+=1
    return p
#kleiner test
plotGraph(A,p,n, "start.png")
pa = newtonraphson(length,p,k,n)
plotGraph(A,pa,n, "end.png")

