# -*- coding: utf-8 -*-
"""
 Naive Bayes

"""
import numpy as np
import random

#-----------------------------------------------------------------------------
# 			Choose proper bin size
def chooseBinSize(trainingx):
  
    n = trainingx.shape[0]
    d = trainingx.shape[1]
    
    # Choose bin width 
    dx = np.zeros(d, dtype = np.float128)
    m = np.zeros(d, dtype = np.int32)
    for j in range(0,d):
	# for each dimension apply Freeman-Diace Rule
        ind_sort =  np.argsort(trainingx[:,j]); # j-th feature dimension
        IQR = trainingx[ind_sort[3*n/4],j] - trainingx[ind_sort[n/4],j]        
        dx[j] = 2*IQR/np.power(n, 1/3.)        
        if dx[j]<0.01:
           dx[j] =  3.5/np.power(n, 1/3.)        
        m_j = (np.max(trainingx[:,j])-np.min(trainingx[:,j]))/dx[j]   
        m[j] = np.floor(m_j) + 1       
    # end for j
        
    L = np.min(m);  # total number of bins as minimum over all bin sizes
		    # in all dimensions
#    print 'Total number of bins {}'. format(L)
    
    # recalculate bin width according to the new bin size L
    for j in range(0,d):
        dx[j] = (np.max(trainingx[:,j])-np.min(trainingx[:,j]))/float(L-1)
    # end for j 
    
    return L, dx
# end chooseBinSize

#-----------------------------------------------------------------------------
##                          Naive Bayes Training
# determine priors  and likelihoods (for each feature and class individual 
# histogram <=> 4 histogramms   ) 
def naiveBayes_train_single_class(trainingx, trainingy, c, dx, L):
    # we consider one class c
    #    
    # trainingx is our training set    
    # trainingy are class labels for each element from trainingx
    # dx bin width
    # L total number of bins pro dimension
    
    n = trainingx.shape[0]      # size of the training set
    d = trainingx.shape[1]      # size of the feature space
    
    # find  in training set all members of the class c
    xc = trainingx[trainingy==c, :]        # Class of digit c
    nc = xc.shape[0]

    ## Priors
    prior = nc/float(n)
    
    ## Likelihood p(x|y=c)
    
    likelihood = np.zeros((d, L), dtype = np.float32)
  
    for j in range(0,d):
        for i in range(0,nc):    
            l = np.floor(xc[i,j]/dx[j])+1 # bin 
            if l>=L+1:
                print xc[i,j]
            likelihood[j, l-1] = likelihood[j, l-1] + 1
        # end for i=1..nc
        likelihood[j,:] = likelihood[j,:]/float(nc)    
    #end for j=1..d                 
    
    return prior, likelihood
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
## Generate Number from the given pdf
# samply in each of d dimensions independently
def generate_number(pdf,dx):
    
    d = pdf.shape[0]    # number of dimension
    
    newnumber = np.zeros(d, dtype = np.int32)
    # calculate cumulative distribution function (cdf) from pdf
    cdf = np.zeros(pdf.shape, dtype = np.float32)
    for j in range(0, d):
        cdf[j,:] = np.cumsum(pdf[j,:])
    # end for
        
    for j in range(0,d):
        # randomly select a uniformly distribut number in range [0., 1.)
        alpha = random.random()
        # calculate quantile on the level alpha
        dist = abs(cdf[j,:] - alpha)
        binx = np.argsort(dist)
        
        newnumber[j] = np.floor(dx[j]*binx[0])+1
    # for j    
    return newnumber
# def generate_number(pdf)