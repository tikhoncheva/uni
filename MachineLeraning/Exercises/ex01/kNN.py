# k-Nearest Neighbor Classifier (default k=1)  
def kNN(x_training, y_training, x_test, k=1):
    
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
    return  y_pred
# end kNN