# Euclidean distance between two sets of points	
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