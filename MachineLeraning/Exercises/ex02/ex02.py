"""
Exercise 2 : LDA/QDA and the Nearest Mean Classifier

"""

import numpy as np
import matplotlib.pyplot as plot

import time

from sklearn.datasets import load_digits
from sklearn import cross_validation
# ----------------------------------------------------------------------------    
# Dimension Reduction Function
# size(x) = n x d.
# size(dr(x)) = n x 2
def dr(x, y):
    
    # Calculate the average digit 1
    x_1 = x[y==1]
    n1 = len(x_1)
    average1 = np.sum(x_1[:,:], axis = 0)/float(n1)

#    # Show average 1
#    f = plot.figure()
#    plot.title('An Average 1')
#    plot.gray()
#    plot.imshow(np.reshape(average1, (8,8)), interpolation = 'nearest');
#    plot.show()
#    f.savefig('average1.png')
    
    # Calculate the average digit 7
    x_7 = x[y==7]
    n7 = len(x_7)
    average7 = np.sum(x_7[:,:], axis = 0)/float(n7)
#    # Show average 7
#    f = plot.figure()
#    plot.title('An Average 7')
#    plot.gray()
#    plot.imshow(np.reshape(average7, (8,8)), interpolation = 'nearest');
#    plot.show()
#    f.savefig('average7.png')

    
    # Differences between average1 and average7
    diff17 = np.abs(average1-average7)
    
    # Sort in descending order
    diff_sortInd = np.argsort(diff17); 
    diff_sortInd = diff_sortInd[::-1]
    
    # leave only indices of the two first elements (correspond to max diff between average digits)
    diff_sortInd = diff_sortInd[0:2:1]
    
    xn = x[:,diff_sortInd]
    
    return xn
    
#end def dr
# ----------------------------------------------------------------------------    
## Draw a scatter plot of sets of points x1, x2 
# x_i in R^(n_i,2), i=1,2
    
def scatterplot(x,y):
    
    x_1 = x[y==1]

    x_7 = x[y==7]
        
#    f = plot.figure()        
#    plot.title('Scatter plot')
#    plot.xlabel('X axis')
#    plot.ylabel('Y axis')    
#    plot.scatter(x_1[:,0],x_1[:,1], marker="x", c="r", label = '1')
#    plot.scatter(x_7[:,0],x_7[:,1], marker="o", c="b", label = '7')
#    plot.legend(framealpha=0.5)
#
#    plot.show()
#    f.savefig('Scatterplot of the training set.png')    
# end def      
# ----------------------------------------------------------------------------    
## QDA Training
# mu0, mu1 mean vectors
# covmat0, covmat1 covariance matrix
# p0, p1 priors (scalars)
def compute_qda(trainingy, trainingx):
    
    # select element from each class
    x0 = trainingx[:,trainingy==0]        # Class of 0 (digit 1)
    n0 = len(x0)
    
    x1 = trainingx[:,trainingy==1]    # Class of 1 (digit 7)
    n1 = len(x1)
    
    # Compute the class means
    mu0 = np.sum(x0[:,:], axis = 1)/float(x0.shape[1])   
    mu1 = np.sum(x1[:,:], axis = 1)/float(x0.shape[1])

    # Compute the covariance matrices
    
    covmat0 = np.zeros((x0.shape[0],x0.shape[0]), dtype = np.float32);
    for i in range(0,x0.shape[0]):
        for j in range(0,x0.shape[0]):
            covmat0[i,j] = np.dot(x0[i]-mu0[i], x0[j]-mu0[i])/x0.shape[1]
        # end for j
    # end for i
    
    covmat1 = np.zeros((x1.shape[0],x1.shape[0]), dtype = np.float32);
    for i in range(0,x1.shape[0]):
        for j in range(0,x1.shape[0]):
            covmat1[i,j] = np.dot(x1[i]-mu1[i], x1[j]-mu1[i])/x1.shape[1]
        # end for j
    # end for i    
    
    #Compute the priors
    p0 = float(n0)/(n0+n1)
    p1 = float(n1)/(n0+n1)

    return mu0,mu1,covmat0,covmat1,p0,p1
# end compute_qda    
# ----------------------------------------------------------------------------        
def perform_qda(mu0, mu1, covmat0, covmat1, p0, p1, testx):
    n2 = testx.shape[1]    
    qda_predict = np.zeros(n2, dtype = np.int8)
    
    for i in range(0,n2):
        # k =0
        b_0 = - np.log(np.linalg.det(2*np.pi*covmat0))/2. - np.log(p0)
        
        covmat0inv = np.linalg.inv(covmat0)
        
        y0 = np.dot ( np.dot((testx[:,i]-mu0).T, covmat0inv), testx[:,i] - mu0)/2. + b_0
        
        # k =1
        b_1 = - np.log(np.linalg.det(2*np.pi*covmat1))/2. - np.log(p1)
        covmat1inv = np.linalg.inv(covmat1)
        y1 = np.dot ( np.dot((testx[:,i]-mu1).T, covmat1inv), testx[:,i] - mu1)/2. + b_1
        
        
        if y1>y0 :
            qda_predict[i] = 1
        else:
            qda_predict[i] = 0
        # end if    
    # end for i
    

    return qda_predict
#end perform_qda
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
                                                
    # 1.1 Dimension Reduction
                                                
    x_17 = dr(x_17, y_17)
    print x_17.shape
    
    # split the filtered data set in a training and test set
    x_train, x_test, y_train, y_test = cross_validation.train_test_split(x_17,y_17, \
                                                    train_size = 0.6, test_size = 0.4, random_state = 0)
     
    nTrain = len(x_train)
    nTest = len(x_test)
    
    
    # 1.2 Scatterplot
    # Draw distribution of the training samples in the feature space
    scatterplot(x_train, y_train)
        
    print
    print '------------------------------------------------------------------'
    print ' 2 Nearest mean '    
    print '------------------------------------------------------------------'
    
    y_predict = NearestMean(x_train, y_train, x_test)
#    print 'Test-Predict: {}'. format(y_test-y_predict)

    print
    print '------------------------------------------------------------------'
    print ' QDA '    
    print '------------------------------------------------------------------'

    ## 3.1 QDA - Training

    # mu0, mu1 mean vectors
    # covmat0, covmat1 covariance matrix
    # p0, p1 priors (scalars)
    y_train01 = np.zeros(nTrain, dtype = np.int8)
    y_train01[y_train==7] = 1 # 0<->1, 1<->7
        
    mu0,mu1,covmat0,covmat1,p0,p1 = compute_qda(y_train01, x_train.T)
    qda_predict = perform_qda(mu0, mu1, covmat0, covmat1, p0, p1, x_test.T )
#    print 'Test-Predict: {}'. format(qda_predict-y_tes)    
        
    return 0
    
if __name__ == "__main__":
    main()

