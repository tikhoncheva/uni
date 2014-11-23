"""
 Combine DT and naive Bayes

"""
import numpy as np

#-----------------------------------------------------------------------------
##                          Training
def training(trainingx, trainingy, c):
 
#end def naiveBayes_train
    
#-----------------------------------------------------------------------------  
##                          Naive Bayes Classifier
#
def naiveBayesClassifier(testx, p3, p8, p_k3, p_k8, dx):
    n = testx.shape[0]
    
    prediction = np.zeros(n, dtype = np.int8)
        
    for i in range(0,n):
        x = testx[i,:]
        
        # p(y = 3| x)
        
        l_y3_d1 = np.floor(x[0]/dx[0])+1 # bin number
        p_x_y3_d1 = p_k3[0,l_y3_d1-1]

        l_y3_d2 = np.floor(x[1]/dx[1])+1 # bin number
        p_x_y3_d2 = p_k3[1,l_y3_d2-1]
        
        p_y3_x = p_x_y3_d1*p_x_y3_d2*p3
        
        # p(y = 8| x)

        l_y8_d1 = np.floor(x[0]/dx[0])+1 # bin number
        p_x_y8_d1 = p_k8[0,l_y8_d1-1]

        l_y8_d2 = np.floor(x[1]/dx[1])+1 # bin number
        p_x_y8_d2 = p_k8[1,l_y8_d2-1]
        
        p_y8_x = p_x_y8_d1*p_x_y8_d2*p8
        
        # argmax (p_y3_x, p_y8_x) 
        #print p_y3_x
        if p_y3_x>p_y8_x :
            prediction[i] = 3
        else:
            prediction[i] = 8
        # end if        
        
    # end for i
    return prediction
#end def naiveBayesClassifier

#-----------------------------------------------------------------------------