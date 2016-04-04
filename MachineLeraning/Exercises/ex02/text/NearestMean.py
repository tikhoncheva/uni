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