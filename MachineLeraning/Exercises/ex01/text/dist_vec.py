# Euclidean distance between two sets of points
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