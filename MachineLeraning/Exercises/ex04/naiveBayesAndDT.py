"""
 Combine DT and naive Bayes

"""
import numpy as np
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
    
#-----------------------------------------------------------------------------
##                          Training
#def training(trainingx, trainingy, c):
# 
##end def naiveBayes_train
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
    
#    loss = np.zeros((n-1,d), dtype = np.float32 )
    nr = 40;
   
    loss = np.zeros((nr-1,d), dtype = np.float32 )
    splitvalues = np.zeros((nr-1,d), dtype = np.float32)

    for j in range(0,d):
        ind = np.argsort(points[:,j])

        dx = (points[ind[n-1],j]-points[ind[0],j])/float(nr + 1)
#        for i in range(0,n-1):
        for ii in range(0,nr-1):           
#            i = np.random.randint(0,n-1);    
#            eps = (points[ind[i+1],j]-points[ind[i],j])/2.
#            splitval = (points[ind[i],j]+points[ind[i+1],j])/2.
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
#
# Generate Number from the given pdf
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
    newnumber = np.zeros(d, dtype = np.float32) 
    for j in range(0,d):
        a = selectednode.region[j,0]
        b = selectednode.region[j,1]
        
        alpha = random.uniform(0,1)
        # transforme random number in [0,1) in random number in [a,b)
        newnumber[j] = a + alpha*(b-a)
    # for j    
    return newnumber
# def generate_number(pdf)    

#-----------------------------------------------------------------------------