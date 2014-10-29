"""
Exercise 2 : LDA/QDA and the Nearest Mean Classifier

"""

import numpy as np
import matplotlib.pyplot as plot

import time

from sklearn.datasets import load_digits
from sklearn import cross_validation
# ----------------------------------------------------------------------------    

def NearestMean(x_training, y_training, x_test):
    
    nTr, dTr = x_training.shape
    nTest, dTest = x_test.shape
    
    assert dTr==dTest, 'Images in training and test sets have different size'

    labels = np.unique(y_training)
    nClasses= len(labels)
    
    # Compute class mean
    class_average = np.zeros((nClasses, dTr) , dtype = np.float16)   
    for l in range(0,nClasses):
        # for each class 
        ind = (y_training==labels[l])
        class_l = x_training[ind,:]
        nL = len(class_l) # number of elements in the class with label l
        class_average[l,:] = np.sum(class_l[:,:], axis = 0)/float(nL)

    # end for l
    
    prediction = np.zeros(nTest, dtype = np.int8) 
    
    for i in range(0,nTest):
        # for each test image
        dist = class_average - x_test[i,:]
        dist = np.sqrt(np.sum(np.square(dist), axis = 1))
        
        min_dist = np.argmin(dist)
        prediction[i] = labels[min_dist]
    # end for i 
    return prediction
# end NearestMean
# ----------------------------------------------------------------------------    
    
# ----------------------------------------------------------------------------    
# ----------------------------------------------------------------------------    
def main():

        
    plot.close('all')    

#   Task 1 : Data Preparation       
    
    print '------------------------------------------------------------------'
    print ' 1 Data Preparation  '
    print '------------------------------------------------------------------'
    
    digits = load_digits()
    print digits.keys()
    
    data = digits['data']
    images = digits['images']
    target = digits['target']

    print 'Size of the whole digit set {}'. format(digits.data.shape)

    
    # we consider only 1s and 7s
    
    ind1 = (target==1)
    ind7 = (target==7)

    x_17 = data[ind1+ind7]
    y_17 = target[ind1+ind7]

   
    n,d = x_17.shape    
    print 'Size of the set of 1s and 7s {}'. format(n)   

    # split the filtered data set in a training and test set
    x_train, x_test, y_train, y_test = cross_validation.train_test_split(x_17,y_17, \
                                                    train_size = 0.6, test_size = 0.4, random_state = 0)
                                                    
    # 1.1 Dimension Reduction
    
    # Calculate the average digit 1
    #average1 = np.zeros((1,d), dtype = np.float16)
    x_1 = data[ind1]
    average1 = np.sum(x_1[:,:], axis = 0)/float(n)

    # Calculate the average digit 7
    x_7 = data[ind7]
    average7 = np.sum(x_7[:,:], axis = 0)/float(n)
    
    # Differences between average1 and average7
    diff17 = np.abs(average1-average7)
    
    # Sort in descending order
    diff_sortInd = np.argsort(diff17); 
    diff_sortInd = diff_sortInd[::-1]
    
    # leave only indices of the two first elements (correspond to max diff between average digits)
    diff_sortInd = diff_sortInd[0:2:1]
    
    x_train = x_train[:,diff_sortInd]
    x_test = x_test[:,diff_sortInd]
    
    n,d = x_train.shape    

    print 'Dimension of the feature space after dimension reduction {}'. format(d) 
     
    nTrain = len(x_train)
    nTest = len(x_test)
    
    print
    print '------------------------------------------------------------------'
    print ' 2 Nearest mean '    
    print '------------------------------------------------------------------'
    
    y_predict = NearestMean(x_train, y_train, x_test)
    print 'Test-Predict: {}'. format(y_test-y_predict)

        
    return 0
    
if __name__ == "__main__":
    main()

