# -*- coding: utf-8 -*-
"""
Density tree
"""

import numpy as np
import random
#import DTnode

from collections import namedtuple
DTnode = namedtuple("DTnode", "points region")

#-----------------------------------------------------------------------------
def splitpoints(points,region,dimsplit):
    splitval = np.sum(region[dimsplit,:])/2.
    
    pointsLeft = []
    pointsRight = []

    for i in range(0, points.shape[0]):
        if points[i,dimsplit]< splitval:
            pointsLeft.append(i)
        else :
            pointsRight.append(i)
        # end if
    #end for
    
    assert len(pointsLeft)+len(pointsRight)==len(points),\
                                            'Wrong splitting of points!'        
                    
    pointsL = np.array(pointsLeft)
    pointsR = np.array(pointsRight)
    
    return pointsL, pointsR
#end point_in region

#-----------------------------------------------------------------------------    
#               Learning DT         
# we consider one class at time    

def DT_cut(leaves_list, parentnode, depth, dimsplit=0):
    
    print "Current depth {}". format(depth)        
    
    # if termination condition is satisfied
    if depth>=3:
        leafes_list = [leaf_list, node]
        return
    else:
        # if split further

        # split value : split on the middle of the interval
        splitval = np.sum(parentnode.region[dimsplit,:])/2.
        print "Split Interval: {}". format(splitval)
        
        # split region
        regionL = np.copy(parentnode.region)
        regionL[dimsplit,:] = [regionL[dimsplit,0], splitval]
        
        regionR = np.copy(parentnode.region)       
        regionR[dimsplit,:] = [splitval, regionR[dimsplit,1] ]           
        
        print "parent region: {}". format(parentnode.region)
        print "left region: {}". format(regionL)
        print "right region: {}". format(regionR)
        # split poins of the node according to the new regions
        pointsL, pointsR = splitpoints(parentnode.points,parentnode.region, dimsplit)

        print pointsL.shape
        print pointsR.shape
        # create two new nodes
        
        nodeL = DTnode(pointsL, regionL)
        nodeR = DTnode(pointsR, regionR)

        DT_cut(leaves_list, nodeL, depth+1, (dimsplit+1)%2)
        DT_cut(leaves_list, nodeR, depth+1, (dimsplit+1)%2)   
    # end if    
# end DT_cut()
    
def DT_learning_naive(trainingx, trainingy, c):
    # in this version wir use naive split criterion on the nodes of the DT
    print "Learning DT for the class {}". format(c)
    
    n = trainingx.shape[0]      # size of the training set
    d = trainingx.shape[1]      # size of the feature space
    
    # find  in training set all members of the class c
    xc = trainingx[trainingy==c, :]        
    nc = xc.shape[0]

    ## Priors
    prior = nc/float(n)
    
    ## Root node
    region = np.zeros((d,2), dtype = np.float32)
    for j in range(0,d):
        region[j,0] = np.min(xc[:,j])
        region[j,1] = np.max(xc[:,j])
    # end j        
        
    rootnode = DTnode(trainingx, region)
    print "root region: {}". format(rootnode.region)
    # build recursively a Density Tree and get all it's leaves 
    leavesnodes = []
    DT_cut(leavesnodes, rootnode, 0, 0)
    
    return prior,leavesnodes

    print
#end def DT_learning

#-----------------------------------------------------------------------------