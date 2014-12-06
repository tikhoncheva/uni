# -*- coding: utf-8 -*-
"""
Density tree
"""

import numpy as np
import matplotlib.pyplot as plot
import random

from collections import namedtuple
DTnode = namedtuple("DTnode", "depth points p region")

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
def splitpoints(points,region, splitval, splitdim):

    # create two arrays bigger than we actually need
    # we will delete zero entries afterwards    
    pointsLeft = np.zeros(points.shape, dtype = np.int32)
    pointsRight = np.zeros(points.shape, dtype = np.int32)
    
    nLeft = 0
    nRight = 0    

    for i in range(0, points.shape[0]):
        if splitval-points[i,splitdim] >= 0.1:
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
# split on the middle of two samples
def splitnaive(node):
    points = node.points
    d = points.shape[1]
    n = points.shape[0]
    
    nr = 40;
   
    loss = np.zeros((nr-1,d), dtype = np.float32 )
    splitvalues = np.zeros((nr-1,d), dtype = np.float32)

    for j in range(0,d):
        ind = np.argsort(points[:,j])

        dx = (points[ind[n-1],j]-points[ind[0],j])/float(nr + 1)

        for ii in range(0,nr-1):           

            splitval = points[ind[0],j] + dx*(ii+1);
            splitvalues[ii,j] = splitval
            
            # new regions
            regionL = np.copy(node.region)
            regionL[j,:] = [node.region[j,0], splitval]

            if volume(regionL)<=0.1:
                continue
                
            regionR = np.copy(node.region)       
            regionR[j,:] = [splitval, node.region[j,1] ]           

            if volume(regionR<=0.1):
                continue
                
            # split poins of the node according to the new regions
            pointsL, pointsR = splitpoints(points,node.region, \
                                                    splitval, j)
            nleft = pointsL.shape[0]
            nright = pointsR.shape[0]
                                
            loss[ii,j] = np.square(nleft /float(n))*(volume(node.region)/volume(regionL)) + \
                         np.square(nright/float(n))*(volume(node.region)/volume(regionR))
        # end for i    
    #end for j
                   
    maxval = loss.max()
    valInd, dimInd  = np.where(loss==maxval)       
    splitval = splitvalues[valInd[0], dimInd[0]]    
       
    return splitval, dimInd[0]    
# end splitnaive

    
# select theoretically best split
def splitclever(node, eps):
    x = node.points
    d = x.shape[1]
    n = x.shape[0]
    
    loss = np.zeros((2*n,d), dtype = np.float32 )
    splitvalues = np.zeros((2*n,d), dtype = np.float32)
    for j in range(0,d):
        
        ind = np.argsort(node.points[:,j])
        for i in range(0,n):
            for s in [-1,1]:
                splitval = x[ind[2*i],j]+s*eps
                splitvalues[2*i+(s+1)/2,j] = splitval
                
                # new regions
                regionL = np.copy(node.region)
                regionL[j,:] = [regionL[j,0], splitval]
                
                if volume(regionL)<=0.1:
                    continue
                
                regionR = np.copy(node.region)       
                regionR[j,:] = [splitval, regionR[j,1] ]           
                
                if volume(regionR<=0.1):
                    continue
                
                # split poins of the node according to the new regions
                pointsL, pointsR = splitpoints(x,node.region, \
                                                    splitval, j)
                nleft = pointsL.shape[0]
                nright = pointsR.shape[0]
                    
                loss[2*i+(s+1)/2,j] = np.square(nleft/float(n))/volume(regionL) + \
                            np.square(nright/float(n))/volume(regionR)
            # end for s
        # end for i    
    #end for j                      

    maxval = loss.max()
    valInd, dimInd  = np.where(loss==maxval)       
    splitval = splitvalues[valInd[0], dimInd[0]]        
    
    return splitval, dimInd
# end splitclever
#-----------------------------------------------------------------------------        
#               Learn DT
def DT_learning(trainingx, trainingy, c, splitmethod):
    
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
      
    # build  a Density Tree and get all it's leaves  
      
    rootnode = DTnode(0, xc, 1/volume(region), region) #(depth, points, p, region)
    leaveslist = []

    stack = []
    stack.append(rootnode)
    
    while stack:
        
        currentnode = stack.pop()
  
        # if termination condition is satisfied (min number of points in bin):
        if currentnode.points.shape[0] < 200: 
            leaveslist.append(currentnode)
        else: # if split further
        
            if splitmethod == 'naive':
                # split value : split on the middle of two samples
                splitval, splitdim = splitnaive(currentnode) 
            else :
                # select theoretically best split
                splitval, splitdim = splitclever(currentnode, 0.5)            
            # end if clever
                 

            # new regions
            regionL = np.copy(currentnode.region)
            regionL[splitdim,:] = [regionL[splitdim,0], splitval]
            
            regionR = np.copy(currentnode.region)       
            regionR[splitdim,:] = [splitval, regionR[splitdim,1] ]           
            
            # split poins of the node according to the new regions
            pointsL, pointsR = splitpoints(currentnode.points,currentnode.region, \
                                                    splitval, splitdim)
                
            nleft = pointsL.shape[0]                  
            nright = pointsR.shape[0]                
                    
            # calculate density of the new nodes
            pL = nleft/float(nc) /volume(regionL)
            pR = nright/float(nc)/volume(regionR)        
                                   
            # create two new nodes      (depth, points, p, region)
            nodeL = DTnode(currentnode.depth + 1, pointsL, pL, regionL)
            nodeR = DTnode(currentnode.depth + 1, pointsR, pR, regionR)

            l = currentnode.region[splitdim,1]-currentnode.region[splitdim,0]   
            
            # check, if we try to split too close to region bounds
            if (splitval-currentnode.region[splitdim,0] >= 1 \
             and splitval-currentnode.region[splitdim,0] < l ):
                stack.append(nodeL) # if not add node to stack                
            else :
                leaveslist.append(nodeL) # else set node to a leaf node

            
            # check, if we try to split too close to region bounds
            if (currentnode.region[splitdim,1]-splitval >= 1 
                and currentnode.region[splitdim,1]-splitval < l ):
                stack.append(nodeR) # if not add node to stack                
            else :
                leaveslist.append(nodeR) # else set node to a leaf node

                
        # end if        
    # end while stack
                
    return prior,leaveslist
#end def DT_learning_naive
#-----------------------------------------------------------------------------
    
def DT_Classifier_2classes(testx, prior1, prior2, DT1, DT2, c = [3,8]):
    
    print "start classifier"
    
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
def DT_traverse(rootnode):
    
    n = rootnode.points.shape[0]
    
    stack = []
    stack.append(rootnode)
    q = 0.5
                
    while stack:
        
        currentnode = stack.pop()
  
        # if termination condition is satisfied (min number of points in bin):
        if currentnode.points.shape[0] < 200:
            return currentnode
        else: # if split further
        
            splitval, splitdim = splitnaive(currentnode) 

            # split poins of the node according to the new regions
            pointsL, pointsR = splitpoints(currentnode.points,currentnode.region, \
                                                    splitval, splitdim)
            q = pointsL.shape[0]/float(currentnode.points.shape[0]) 
            x = random.uniform(0,1)        
            if x<=q:
                # split region
                region = np.copy(currentnode.region)
                region[splitdim,:] = [region[splitdim,0], splitval]            
                points = pointsL
            else:
                # split region
                region = np.copy(currentnode.region)       
                region[splitdim,:] = [splitval, region[splitdim,1] ]
                points = pointsR
            # end if
                
            # calculate new p
            p =  points.shape[0]/float(n) /volume(region)
        
            # go deeper
            node = DTnode(currentnode.depth+1, points, p, region)
        
            l = currentnode.region[splitdim,1]-currentnode.region[splitdim,0]   
            
            # check, if we try to split too close to region bounds
            if (splitval-currentnode.region[splitdim,0] >= 1 \
             and splitval-currentnode.region[splitdim,0] < l ):
                stack.append(node) # if not add node to stack
            else:
                return node
            # end if
        # end if        
    # end while stack
# end DT_traverse()
        
## Generate Number from the given pdf
# samply in each of d dimensions independently
def generate_number(trainingx, trainingy, c):
    # find  in training set all members of the class c
    xc = trainingx[trainingy==c, :]        
    d = trainingx.shape[1]      # size of the feature space
    
    ## Root node
    region = np.zeros((d,2), dtype = np.float32)
    for j in range(0,d):
        region[j,0] = np.min(xc[:,j])
        region[j,1] = np.max(xc[:,j])
    # end j   
    
    # build  a Density Tree and traverse it into depth    
    rootnode = DTnode(0, xc, 1/volume(region), region) #(depth, points, p, region)
    
    selectednode = DT_traverse(rootnode)


    # in the leaf node sample uniformly in each direction
    newnumber = np.zeros(d, dtype = np.int32) 
    for j in range(0,d):
        a = selectednode.region[j,0]
        b = selectednode.region[j,1]
        
        alpha = random.uniform(0,1)
        # transforme random number in [0,1) in random number in [a,b)
        newnumber[j] = np.floor(a + alpha*(b-a))
    # for j    
    return newnumber
# def generate_number(pdf)    