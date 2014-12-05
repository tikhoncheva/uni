"""
Calculate the correct classification rate

"""

import numpy as np

# y_pred predicted labeles
# y_test correct labels
# D  - labels set
# print_confMatrix print conflict Matrix true/false

def correctClassRate(y_pred, y_test, D, print_confMatrix = False):
    n = len(D)
    
    # calculate confusion matrix
    confusionM = np.zeros((n,n), dtype = np.float16)    
    for i in range(0,n):
        # find positions of the digit D[i] in test set and    
        # get predicted values on the corresponding positions
        predict = y_pred[y_test == D[i]]
        
        votes_bin = np.bincount(predict, minlength = 10)
        confusionM[i,:] = np.array(votes_bin[D])
    # end for-loop
        
    if print_confMatrix:
        print
        print 'Confusion Matrix '
        print confusionM
    # end if print_confMatrix
    
    # correct classification rate
    ccr = np.trace(confusionM)/len(y_test)
    return  ccr
# end correctClassRate
