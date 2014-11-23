# -*- coding: utf-8 -*-
"""
Density tree
"""

import numpy as np
import matplotlib.pyplot as plot
import random
#import DTnode

from collections import namedtuple
DTnode = namedtuple("DTnode", "points p region")

# volume of a region
def volume(region):
    V = 1.
    d = region.shape[0]
    for j in range(0,d):
        V *= region[j,1]-region[j,0] 
    # end j    
    return V   
#end volume    
    
def point_in_region(x, region):
    flag = True
    d = region.shape[0]
    for j in range(0,d):
        if (x[j]<region[j,0] or x[j]>region[j,1]):
            flag = False            
            return flag
        # end if    
    # end j    
    return flag   
# end point_in_region
#-----------------------------------------------------------------------------
def splitpoints(points,region,splitval, splitdim):

    # create two arrays bigger than we actually need
    # we will delete zero entries afterwards    
    pointsLeft = np.zeros(points.shape, dtype = np.int32)
    pointsRight = np.zeros(points.shape, dtype = np.int32)
    
    nLeft = 0
    nRight = 0    

    for i in range(0, points.shape[0]):
        if points[i,splitdim]< splitval:
            pointsLeft[nLeft,:] = points[i,:]
            nLeft += 1 
        else :
            pointsRight[nRight,:] = points[i,:]
            nRight += 1 
        # end if
    #end for
    
    pointsLeft = pointsLeft[0:nLeft,:]
    pointsRight = pointsRight[0:nRight,:]
    
    assert pointsLeft.shape[0]+pointsRight.shape[0]==points.shape[0],\
                                            'Wrong splitting of points!'        
                        
    return pointsLeft, pointsRight
#end point_in region

#-----------------------------------------------------------------------------    
#                            Splitting criteria
# split on the middle of the interval in next dimension
def splitnaive(node, depth):
    d = node.points.shape[1]
    
    splitdim = depth%d;
    splitval =  np.sum(node.region[splitdim,:])/2.   
    
    return splitval, splitdim
# end splitnaive
    
# select theoretically best split
def splitclever(node):
    x = node.points
    d = x.shape[1]
    n = x.shape[0]
    eps = 0.001
    
    loss = np.zeros((2*n,d), dtype = np.float32 )
    for j in range(0,d):
        splitdim = j
        ind = np.argsort(node.points[:,j])
        for i in range(0,n):
            for s in [-1,1]:
                splitval = x[ind[i],j]+s*eps
                # new regions
                regionL = np.copy(node.region)
                regionL[splitdim,:] = [regionL[splitdim,0], splitval]
            
                regionR = np.copy(node.region)       
                regionR[splitdim,:] = [splitval, regionR[splitdim,1] ]           
                
                if volume(regionL)==0 or volume(regionR==0):
                    continue
                
                # split poins of the node according to the new regions
                pointsL, pointsR = splitpoints(x,node.region, \
                                                    splitval, splitdim)
                if pointsL.size ==0:
                    nleft = 0
                else:
                    nleft = pointsL.shape[0]
                # end if    
    
                if pointsR.size ==0:
                    nright = 0
                else:
                    nright = pointsR.shape[0]
                # end if    
                
                
                loss[2*i+(s+1)/2,j] = np.square(nleft/float(n))/volume(regionL) + \
                            np.square(nright/float(n))/volume(regionR)
            # end for s
        # end for i    
    #end for j
    maxval = loss.max()
    splitval, splitdim  = np.where(loss==maxval[0])       
    print maxval
    print splitval, splitdim
    
    return splitval, splitdim
# end splitnaive
#-----------------------------------------------------------------------------    
#               Learning DT         
# we consider one class at time    

def DT_cut(n, leaveslist, parentnode, depth, splitmethod):

    # if termination condition is satisfied:    
    pointsdensity = parentnode.points.shape[0]/float(n)
    # if min density is reached or region has only few points 
    if parentnode.p>=0.0001 or pointsdensity<0.001: # if maximal depth of the tree is reached
#    if depth>5:
        leaveslist.append(parentnode)
        return
    else: # if split further
        if splitmethod == 'naive':
            # split value : split on the middle of the interval
            splitval, splitdim = splitnaive(parentnode, depth)
        # end if naive
        else :
            # select theoretically best split
            splitval, splitdim = splitclever(parentnode)            
        # end if clever   
        
        # new regions
        regionL = np.copy(parentnode.region)
        regionL[splitdim,:] = [regionL[splitdim,0], splitval]
        
        regionR = np.copy(parentnode.region)       
        regionR[splitdim,:] = [splitval, regionR[splitdim,1] ]           
        
        # split poins of the node according to the new regions
        pointsL, pointsR = splitpoints(parentnode.points,parentnode.region, \
                                                splitval, splitdim)
        if pointsL.size ==0:
            nleft = 0
        else:
            nleft = pointsL.shape[0]
        # end if    

        if pointsR.size ==0:
            nright = 0
        else:
            nright = pointsR.shape[0]
        # end if    
                
        # calculate density of the new nodes
        pL = nleft/float(n)/volume(regionL)
        pR = nright/float(n)/volume(regionR)        
        
        # create two new nodes        
        nodeL = DTnode(pointsL, pL, regionL)
        nodeR = DTnode(pointsR, pR, regionR)

        DT_cut(n, leaveslist, nodeL, depth+1, splitmethod)
        DT_cut(n, leaveslist, nodeR, depth+1, splitmethod)   
    # end if    
# end DT_cut()
    
def DT_learning(trainingx, trainingy, c, splitmethod):
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
        
    leavesnodes = []
#     build recursively a Density Tree and get all it's leaves  
    rootnode = DTnode(xc, 1/volume(region), region)
#    rootnode = DTnode(xc, 1, region)
    DT_cut(nc, leavesnodes, rootnode, 0, splitmethod)

        
        
    return prior,leavesnodes
#end def DT_learning_naive
#-----------------------------------------------------------------------------
    
def DT_Classifier_2classes(testx, prior1, prior2, DT1, DT2, c = [3,8]):
    n = testx.shape[0]
    
    prediction = np.zeros(n, dtype = np.int8)
    
    for i in range(0,n):
        x = testx[i,:]
            
        # p(y = 3| x)
        # find right bin in DT:
        likelihood1 = 0
        for node in DT1:
            if point_in_region(x, node.region):
                likelihood1 = node.p
                break 
            # end if
        # end for node
        p_y1_x = likelihood1*prior1
           
        # p(y = 8| x) 
        # find right bin in DT:
        likelihood2 = -1
        for node in DT2:
            if point_in_region(x, node.region):
                likelihood2 = node.p
                break 
            # end if
        # end for node        
        p_y2_x = likelihood2*prior2
           
        # argmax (p_y3_x, p_y8_x) 
        if p_y1_x>p_y2_x :
            prediction[i] = c[0]
        else:
            prediction[i] = c[1]
        # end if        
           
    # end for i
    
    
    return prediction
# end DT_Classifier
#-----------------------------------------------------------------------------
def DT_visualize2D(leaveslist, trainingx, trainingy, c, saveName):

    d = trainingx.shape[1]      # size of the feature space
    
    assert d==2, 'I can visualize density trees only for two features :('
    
    # find  in training set all members of the class c
    xc = trainingx[trainingy==c, :]        
    
    d1min = np.ceil(np.min(xc[:,0]))
    d1max = np.ceil(np.max(xc[:,0]))
    
    d2min = np.ceil(np.min(xc[:,1]))
    d2max = np.ceil(np.max(xc[:,1]))
    
    img = np.zeros((d1max-d1min, d2max-d2min), dtype = np.float64)

    pmax = 0.  
    for node in leaveslist:
        if node.p>pmax:
            pmax = node.p
        xmin = np.ceil(node.region[0,0])
        xmax = np.ceil(node.region[0,1])
        
        ymin = np.ceil(node.region[1,0])
        ymax = np.ceil(node.region[1,1])

        img[xmin:xmax, ymin:ymax] = node.p
    #end for    
    
    im = np.array(img * 255/pmax, dtype = np.uint8)
    
    f = plot.figure() 
    plot.gray()
    plot.imshow(im.transpose(), interpolation = 'nearest')       
    plot.title("2D Density tree for class %d" %c)
    plot.xlabel('d1')
    plot.ylabel('d2')    

    plot.show()
   
    f.savefig(saveName)  
# end DT_visualize(DT)
#-----------------------------------------------------------------------------   
# traverse the density tree: go left with probability q and right with 
# probability 1-q
def DT_traverse(N, qmin, qmax, q, parentnode, depth):

    # if termination condition is satisfied (same as in construction of DT)
    pointsdensity = parentnode.points.shape[0]/float(N)
    if parentnode.p>=0.0001 or pointsdensity<0.001: 
#    if depth>5:
        return parentnode
    else:
        # split value : split on the middle of the interval
    
        splitval, splitdim = splitnaive(parentnode, depth)

        # split poins of the node according to the new regions
        pointsL, pointsR = splitpoints(parentnode.points,parentnode.region, splitval, splitdim)
        
        x = random.uniform(qmin,qmax)        
        if x<=q:
            # split region
            region = np.copy(parentnode.region)
            region[splitdim,:] = [region[splitdim,0], splitval]            
            points = pointsL
        else:
            # split region
            region = np.copy(parentnode.region)       
            region[splitdim,:] = [splitval, region[splitdim,1] ]
            points = pointsR
        # else if
        
        # calculate new p
        q *= points.shape[0]/float(N)
        
        # go deeper
        node = DTnode(points, points.shape[0]/float(N)/volume(region), region)
        return DT_traverse(N, qmin, qmax, q, node, depth+1)
    # end if    
# end DT_traverse()
        
## Generate Number from the given pdf
# samply in each of d dimensions independently
def generate_number(DT, trainingx,trainingy, c):
    # find  in training set all members of the class c
    xc = trainingx[trainingy==c, :]        
    N = xc.shape[0]
    d = xc.shape[1]

    ## Root node
    region = np.zeros((d,2), dtype = np.float32)
    for j in range(0,d):
        region[j,0] = np.min(xc[:,j])
        region[j,1] = np.max(xc[:,j])
    # end j   
        
    rootnode = DTnode(xc, 1/volume(region), region)
    pmin = 1.
    pmax = 0.
    for node in DT:
        if node.p>pmax:
            pmax = node.p
        if node.p<pmin:
            pmin = node.p
    #end for    
        
    # number of all points, probability to go left, root node, depth
    selectednode = DT_traverse(N, pmin, pmax, 0.5, rootnode, 0) 
    # in the leaf node sample uniformly in each direction
    newnumber = np.zeros(d, dtype = np.int32) 
    for j in range(0,d):
        a = selectednode.region[j,0]
        b = selectednode.region[j,1]
        
        alpha = random.random()
        # transforme random number in [0,1) in random number in [a,b)
        newnumber[j] = np.floor(a + alpha*(b-a))
    # for j    
    return newnumber
# def generate_number(pdf)    