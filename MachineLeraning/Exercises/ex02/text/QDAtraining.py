def compute_qda(trainingy, trainingx):
    # size(trainingx) = n1 x d
    # size(trainingy) = n1
    # d = 2
    d = trainingx.shape[1]

    # select element from each class
    x0 = trainingx[trainingy==0, :]        # Class of 0 (digit 1)
    n0 = x0.shape[0]
    
    x1 = trainingx[trainingy==1, :]    # Class of 1 (digit 7)
    n1 = x1.shape[0]
    
    # Compute the class means
    mu0 = np.sum(x0[:,:], axis = 0)/float(n0)   
    mu1 = np.sum(x1[:,:], axis = 0)/float(n1)

    # Compute the covariance matrices
    
    covmat0 = np.zeros((d, d), dtype = np.float32);
    for i in range(0,d):
        for j in range(0,d):
            covmat0[i,j] = np.dot(x0[:,i]-mu0[i], x0[:,j]-mu0[j])/x0.shape[0]
        # end for j
    # end for i
    
    covmat1 = np.zeros((d, d), dtype = np.float32);
    for i in range(0,d):
        for j in range(0,d):
            covmat1[i,j] = np.dot(x1[:,i]-mu1[i], x1[:,j]-mu1[j])/x1.shape[0]
        # end for j
    # end for i
    
    #Compute the priors
    p0 = float(n0)/(n0+n1)
    p1 = float(n1)/(n0+n1)

    return mu0,mu1,covmat0,covmat1,p0,p1
# end compute_qda   