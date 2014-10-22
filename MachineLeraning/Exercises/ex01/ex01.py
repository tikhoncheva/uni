"""
Created on Mon Oct 20 16:07:47 2014

@author: kitty
"""

import vigra
import numpy as np
import matplotlib.pyplot as plot
import sklearn

import time

from sklearn.datasets import load_digits
from sklearn import cross_validation

# Euclidean distance between two sets of points
# ----------------------------------------------------------------------------
# realisation with loops
def dist_loop(training, test):
    
    n1, d = training.shape
    n2, d1 = test.shape
       
    assert n1 != 0, 'Training set is empty'
    assert n2 != 0, 'Test set is empty'
    assert d==d1, 'Images in training and test sets have different size'

    tstart = time.time()
    
    dist =  np.zeros((n1,n2), dtype = np.float32)
    
    for i in range(0,n1):
        for j in range(0,n2):
            diff = training[i,:]-test[j,:]
            dist[i,j] = np.sum(np.square(diff), axis=0)
    
    dist = np.sqrt(dist)
    tstop = time.time()
    
    return dist, tstop-tstart
# end dist_loops
# ----------------------------------------------------------------------------    
# realisation with vectors
def dist_vec(training, test):
    
    n1, d = training.shape
    n2, d1 = test.shape
       
    assert n1 != 0, 'Training set is empty'
    assert n2 != 0, 'Test set is empty'
    assert d==d1, 'Images in training and test sets have different size'
     
    tstart = time.time()
   
    train_squared = np.sum(np.square(training), axis = 1)
    test_squared = np.sum(np.square(test), axis = 1)
    
    A = np.tile(train_squared, (n2,1)) # n2xn1 matrix
    A = A.transpose((1,0))    # n1xn2 matrix    
    B = np.tile(test_squared, (n1,1) ) # n2xn2 matrix

    a = np.tile(training, (1,1,1)) # 1xn1x64 matrix
    a = a.transpose((1,0,2))    # n1x1x64 matrix
    b = np.tile(test, (1,1,1) ) # 1xn2x64 matrix
    
    C = np.tensordot(a,b, [[1,2],[0,2]])
    
    dist = A + B - C - C
    
    dist = np.sqrt(dist)
    np.float16(dist)
    
    tstop = time.time()
    
    return dist, tstop-tstart    
# end dist_vec
# ----------------------------------------------------------------------------

# k-Nearest Neighbor Classifier (default k=1)  
def kNN(x_training, y_training, x_test, y_test, k=1):
    
    nTr, dTr = x_training.shape
    nTest, dTest = x_test.shape
    
    assert k <= nTr, 'kNN Error: k cannot be larger than size of training set'
    
    # compute distance between all points in training and test sets   
    dist, time = dist_vec(np.array(x_training), np.array(x_test))
    
    # sort each column of the dist matrix in descending order
    # save indices that would sort the matrix
    dist_sortInd = np.argsort(dist, axis = 0); 
    
    # leave only k nearest neighbors : rows 1:k in the sorted array
    dist_sortInd = dist_sortInd[0:k,:]
    
    # classification results (for k>1 : the majority vote from k-nearest neighbors)
    y_pred = np.zeros(nTest, dtype = np.int8) 

    for i in range(0,nTest):
        votes = y_training[dist_sortInd[:,i]] # k votes
        # take the majority vote in each column
        votes_bin = np.bincount(votes)
        y_pred[i] = np.argmax(votes_bin)   
    # end for loop
    
    # Calculate Correct Classification rate
    diff  = y_pred - y_test;
    correct_results = (diff==0)
    
    rate_correct = float(len(correct_results))/nTest 
    return  y_pred, rate_correct
# end kNN
    
# ----------------------------------------------------------------------------    
def main():
    
    plot.close('all')    
    
    # 1 Exploring the Data
    
    digits = load_digits()
    print digits.keys()
    
    data = digits['data']
    images = digits['images']
    target = digits['target']
    target_names = digits['target_names']
    
    print 'Size of the digit set {}'. format(digits.data.shape)
    #print np.dtype(data) # TypeError :data type not understood
    
    # get all images with 3
    img3 = images[target == 3 ]
    # show the first one
    img = img3[0]
    assert 2 == np.size(np.shape(img))
    
#    plot.figure()
#    plot.gray();
#    plot.imshow(img, interpolation = 'nearest');
#    plot.show()
    
    ## 2 Nearest Neighbor Classifier
    # Write a NN-Classifier that distinguishes the digit '3' from all other digits
    
    np.set_printoptions(precision=5)
    
#    # 2.1 Split data into a training-/test set
#    
#    x_all = data
#    y_all = target
#    
#    x_train, x_test, y_train, y_test = cross_validation.train_test_split(x_all,y_all, \
#                                                    test_size = 0.4, random_state = 0)
#    
#    # 2.2 Distance function computation using loops
#    
#    dist1, time1 = dist_loop(np.array(x_train), np.array(x_test))
#    
#    print 'Distance(loops) between ''1'' and ''3'':'
##    print dist1
#    print 'Spend time: {}'. format(time1)
#    
#    # 2.3 Distance function computation using vectorization
#
#    dist2, time2 = dist_vec(np.array(x_train), np.array(x_test))
#    
#    print 'Distance(vec) between ''1'' and ''3'':'
##    print dist2
#    print 'Spend time: {}'. format(time2)
#    
#    # Compare results from 2.2 and 2.4
#    similar = np.allclose(dist1, dist2, rtol=1e-05, atol=1e-08)
#    assert similar, 'Functions dist_loop and dist_vec do not provide similar results'
    
    # 2.4 A NN-Classifier
        
    # Indices of images with '1','3' and '7' on them
    ind1 = (target==1)
    ind3 = (target==3)
    ind7 = (target==7)
    
    # Save images with '1' and '3'
    x13 = data[ind1+ind3]
    y13 = target[ind1+ind3]
    # split sets into training and test sets
    x13_train, x13_test, y13_train, y13_test = cross_validation.train_test_split(x13,y13, \
                                                    test_size = 0.4, random_state = 0)
              
    y13_predict, rate13 = kNN(x13_train,y13_train, x13_test, y13_test, 1)                                   
    print 'Choose between 1 and 3. Correct classification rate: {}'. format(rate13)
    
        
        
    # end for loop
    
    # Save images with '3' and '7'
    x37 = data[ind7+ind3]
    y37 = target[ind7+ind3]
    # split sets into training and test sets
    x37_train, x37_test, y37_train, y37_test = cross_validation.train_test_split(x37,y37, \
                                                    test_size = 0.4, random_state = 0)
    
    y37_predict, rate37 = kNN(x37_train,y37_train, x37_test, y37_test, 1)                                   
    print 'Choose between 7 and 3. Correct classification rate: {}'. format(rate37)
                                 
    
    return 0
    
if __name__ == "__main__":
    main()

