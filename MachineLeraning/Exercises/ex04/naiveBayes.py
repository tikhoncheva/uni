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
    L = np.zeros(d, dtype = np.int32)
    for j in range(0,d):
	# for each dimension apply Freeman-Diaconis Rule
        ind_sort =  np.argsort(trainingx[:,j]); # j-th feature dimension
        IQR = trainingx[ind_sort[3*n/4],j] - trainingx[ind_sort[n/4],j]        
        dx[j] = 2*IQR/np.power(n, 1/3.)        
        if dx[j]<0.01:
           dx[j] =  1/np.power(n, 1/3.)  
        m_j = (trainingx[ind_sort[n-1],j]-trainingx[ind_sort[0],j])/dx[j]   
        L[j] = np.ceil(m_j)
    # end for j
        
    return L, dx
# end chooseBinSize

#-----------------------------------------------------------------------------
##                          Naive Bayes Training
# determine priors  and likelihoods (for each feature and class individual 
# histogram <=> 4 histogramms  for two classes and two dimensions ) 
def naiveBayes_train_single_class(trainingx, trainingy, c, L, dx):
    # we consider one class c
    #    
    # trainingx is our training set    
    # trainingy are class labels for each element from trainingx
    # dx bin width
    # L number of bins pro dimension
    
    n = trainingx.shape[0]      # size of the training set
    d = trainingx.shape[1]      # size of the feature space
    
    # find  in training set all members of the class c
    xc = trainingx[trainingy==c, :]        # Class of digit c
    nc = xc.shape[0]

    ## Priors
    prior = nc/float(n)
    
    ## Likelihood p(x|y=c)
    
    histograms = [] 
  
    for j in range(0,d):
        
        histogram = np.zeros(L[j], dtype = np.float32)
        
        for i in range(0,nc):    
            l = np.ceil(xc[i,j]/dx[j]) # bin 
            if l>=L[j]:
                l= L[j]
            # end if
            histogram[l-1] = histogram[l-1] + 1
        # end for i=1..nc
        histogram = histogram/float(nc)    
        histograms.append(histogram)
    #end for j=1..d                 

    return prior, histograms
#end def naiveBayes_train
    
#-----------------------------------------------------------------------------  
##                          Naive Bayes Classifier
# p3(8) priors
# p_k3(8): d rows correspond to 1D histograms pro class and dimension
def naiveBayesClassifier(testx, p3, p8, p_k3, p_k8, L, dx):
    n = testx.shape[0]
    d = testx.shape[1]
    
    prediction = np.zeros(n, dtype = np.int8)
        
    for i in range(0,n):
        x = testx[i,:]
        
        # p(y = 3| x)
        # p(y = 8| x)        
        p_y3_x = p3;
        p_y8_x = p8;
        for j in range(0,d):
            l = np.ceil(x[j]/dx[j]) # bin number         
            if l>L[j]:
                l= L[j]             
            p_y3_x *= p_k3[j][l-1]
            p_y8_x *= p_k8[j][l-1]           
        # end for j

        # argmax (p_y3_x, p_y8_x)
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
    
    d = len(pdf)    # number of dimension
    
    newnumber = np.zeros(d, dtype = np.int32)
    # calculate cumulative distribution function (cdf) from pdf
    cdf = []
    for j in range(0, d):
        cdf.append(np.cumsum(np.sort(pdf[j])) )
    # end for
        
    for j in range(0,d):
        # randomly select a uniformly distribut number in range [0., 1.)
        alpha = random.uniform(0,1)    
        # calculate quantile on the level alpha
        dist = abs(cdf[j] - alpha)
        binx = np.argsort(dist)
        
        newnumber[j] = np.floor(dx[j]*binx[0])
    # for j    
    return newnumber
# def generate_number(pdf)