# QDA Prediction    
def perform_qda(mu0, mu1, covmat0, covmat1, p0, p1, testx):
    n2 = testx.shape[0]

    qda_predict = np.zeros(n2, dtype = np.int8)    
    for i in range(0,n2):
        
        # k =0
        b_0 = -np.log(np.linalg.det(2*np.pi*covmat0))/2. - np.log(p0)
        
        covmat0_inv = np.linalg.inv(covmat0)
        
        testx_centered0 = testx - mu0
        
        y0 =  - np.dot ( np.dot(testx_centered0[i], covmat0_inv), \
                         testx_centered0[i].T)/2. - b_0
        
        # k =1
        b_1 = -np.log(np.linalg.det(2*np.pi*covmat1))/2. - np.log(p1)
        covmat1_inv = np.linalg.inv(covmat1)

        testx_centered1 = testx - mu1
        
        y1 = - np.dot ( np.dot(testx_centered1[i], covmat1_inv), \
                        testx_centered1[i].T)/2. - b_1
        
        # argmax (y0, y1) 
        if y1>y0 :
            qda_predict[i] = 1
        else:
            qda_predict[i] = 0
        # end if    
    # end for i
    
    return qda_predict
#end perform_qda
