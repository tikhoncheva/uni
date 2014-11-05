# LDA Prediction    
def perform_lda(mu0, mu1, covmat0, covmat1, p0, p1, testx):
    n2 = testx.shape[0]

    lda_predict = np.zeros(n2, dtype = np.int8)    
    for i in range(0,n2):
        
        # k =0
        b_0 = - np.log(np.linalg.det(2*np.pi*covmat0))/2. - np.log(p0)

        covmat0_inv = np.linalg.inv(covmat0)        
        
        w_0 = np.dot(covmat0_inv, mu0.T)        
        
        b_0 = -b_0 - np.dot( mu0, w_0) /2. 
        
        y0 = np.dot( testx[i], w_0) + b_0
        
        # k =1
        b_1 = - np.log(np.linalg.det(2*np.pi*covmat1))/2. - np.log(p1)

        covmat1_inv = np.linalg.inv(covmat1)        
        
        w_1 = np.dot(covmat1_inv, mu1.T)        
        
        b_1 += np.dot( mu1, w_1) /2. 
        
        y1 = - np.dot( testx[i], w_1) - b_1
        
        # argmax (y0, y1) 
        if y1>y0 :
            lda_predict[i] = 1
        else:
            lda_predict[i] = 0
        # end if    
    # end for i
    
    return lda_predict
#end perform_lda
