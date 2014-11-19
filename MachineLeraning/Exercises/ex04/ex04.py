"""
Exercise 4 : Generative Non-parametric Classofocation

"""

import numpy as np
import matplotlib.pyplot as plot
import vigra
import h5py

import random
import DTnode

#-----------------------------------------------------------------------------
#                          Dimension Reduction Function
# size(x) = n x d.
# size(dr(x)) = n x 2
def dr(x, y, d=[3,8]):
    # Calculate the average digit d[0]
    x_1 = x[y==d[0]]
    n1 = len(x_1)
    average1 = np.sum(x_1[:,:], axis = 0)/float(n1)

   
    # Calculate the average digit d[1]
    x_2 = x[y==d[1]]
    n2 = len(x_2)
    average2 = np.sum(x_2[:,:], axis = 0)/float(n2)
    
    # Differences between average1 and average7
    diff = np.abs(average1-average2)
    
    # Sort in descending order
    diff_sortInd = np.argsort(diff); 
    diff_sortInd = diff_sortInd[::-1]
    
    # leave only indices of the two first elements 
    # It means, we choose two dimensions, where average digits have highest 
    # difference
    diff_sortInd = diff_sortInd[0:2:1]
    
    xn = x[:,diff_sortInd]
    
    return xn
    
#end def dr
    
#-----------------------------------------------------------------------------
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
    print 'Total number of bins {}'. format(L)
    
    # recalculate bin width according to the new bin size L
    for j in range(0,d):
        dx[j] = (np.max(trainingx[:,j])-np.min(trainingx[:,j]))/float(L-1)
    # end for j 
    
    return L, dx
# end chooseBinSize


#                          Naive Bayes Training
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
    
#
#                          Naive Bayes Classifier
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
#               DT        
    
def points_in_region(points,region,dimsplit):
    splitval = np.sum(region[dimsplit,:])/2.
    
    points_left = []
    points_right = []

    for i in range(0, points.shape[0]):
        if points[i,dimsplit]< splitval:
            points_left.append(i)
        else :
            points_right.append(i)
        # end if
    #end for
    return splitval, points_left, points_right
#end point_in region    
     
#               Learning DT         
# we consider one class at time    
def DT_learning_naive(trainingx, trainingy, c):
    # naive split criterion
    stack = []
    
    n = trainingx.shape[0]      # size of the training set
    d = trainingx.shape[1]      # size of the feature space
    
    # find  in training set all members of the class c
    xc = trainingx[trainingy==c, :]        # Class of digit c
    nc = xc.shape[0]

    ## Priors
    prior = nc/float(n)
    
    ## Root node
    ind = 0
    region = np.zeros((d,2), dtype = np.float32)
    for j in range(0,d):
        region[j,0] = np.min(xc[:,j])
        region[j,1] = np.min(xc[:,j])
    # end j        
#    tree = DTnode(ind, range(0,nc), region)
    tree = DTnode.DTnode(ind, range(0,nc), region)
    
    dimsplit = 0
    
    splitval, points_left, points_right = points_in_region(xc,region,dimsplit)

    # left node        
    region_left = region
    region_left[dimsplit] = [region[dimsplit,0], splitval]
    tree.insert_left(ind+1, points_left, region_left)
    #right node        
    region_right = region
    region_right[dimsplit] = [splitval, region[dimsplit,1] ]
    tree.insert_right(ind+1, points_right, region_right)
        
    stack.append(DTnode.DTnode(ind+1, points_left, region_left))
    stack.append(
    DTnode.DTnode(ind+1, points_right, region_right))
    
    while stack:
        currnode = stack.pop()
        
        
        
    # end while
    
    return prior


#end def DT_learning
    
#-----------------------------------------------------------------------------
#               Generate a digit of the given class from the given pdf for each of d dimensions    
def generate_number(pdf,dx):
    
    d = pdf.shape[0]    # number of dimension
    L = pdf.shape[0]    # number of bins pro dimension
    
    # because of independent of the features
    # we can samle separately in each of d dimensions
    
    # calculate d cdf-s from a given pdf
    cdf = np.zeros(pdf.shape, dtype = np.float32) # cumulative distributed function
    for j in range(0, d):
        cdf[j,:] = np.cumsum(pdf[j,:])
    # end for
        
    newnumber = np.zeros(d, dtype = np.int32)        
    for j in range(0,d):
        # randomly select a uniformly distributed number in range [0., 1.)
        alpha = random.random()
        # calculate quantile on the level alpha
        dist = abs(cdf[j,:] - alpha)
        binx = np.argsort(dist)
        
        newnumber[j] = np.floor(dx[j]*binx[0])+1
    # for j    
    return newnumber
# def generate_number(pdf)
    
#-----------------------------------------------------------------------------
#                   Calculate the correct classification rate
# D  - labels set
#
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

#-----------------------------------------------------------------------------
#                   Plot 1D histograms
def plot_histogram(pdf,dx, title = 'Histograms for each of d dimensions',\
                                             imageName = 'histogram.png'):
    
    m = pdf.shape[1]
    f, (ax1, ax2) = plot.subplots(1, 2, sharey=True)
    
    f.suptitle(title, fontsize=14)
    ax1.set_xlabel('x')
    ax1.set_ylabel('Probability') 
    
    ax2.set_xlabel('x')
    ax1.set_ylabel('Probability') 
    
    ax1.set_title('d=1')
    ax2.set_title('d=2')
    
    
    for i in range(0,m):
        # subplot 1
        ax1.plot([i*dx[0], i*dx[0], (i+1)*dx[0],(i+1)*dx[0]], \
                 [0, pdf[0,i], pdf[0,i], 0 ], 'r-')
        ax1.set_xlim([0,m*dx[0]])                 
        # subplot 2
        ax2.plot([i*dx[1], i*dx[1], (i+1)*dx[1],(i+1)*dx[1]], \
                 [0, pdf[1,i], pdf[1,i], 0 ], 'b-')
        ax2.set_xlim([0,m*dx[1]])
    # end for

    plot.show()
    
    f.savefig(imageName)    
#end def      

#-----------------------------------------------------------------------------
#                   Plot 1D histograms
def plot_likelihood(pdf,dx, title = 'likelihood',\
                                             imageName = 'likelihood.png'):
    L = pdf.shape[1] # number of bins
    img = np.zeros((L,L), dtype = np.float64)

    for i in range(0,L):
        img[i,:] = pdf[0,:]*pdf[1,i]
    #end for
        
    f = plot.figure() 
    plot.gray()
    plot.imshow(img, interpolation = 'nearest')       
    plot.title(title)
    plot.xlabel('d1')
    plot.ylabel('d2')    

    plot.show()
    
    f.savefig(imageName)    
#end def      
 
#-----------------------------------------------------------------------------
#                            Main Function
def main():
    plot.close('all')  
    
#       0 Read data, selecting digits 3 and 8, dimension reduction
    print
    print "Read data, selecting digits 3 and 8, dimension reduction"
    print
    
    test_path     = "test.h5"
    training_path = "train.h5"
    
    images_train = vigra.readHDF5(test_path, "images")
    labels_train = vigra.readHDF5(test_path, "labels")
    
    images_test = vigra.readHDF5(training_path, "images")
    labels_test = vigra.readHDF5(training_path, "labels")
    
    print 'Size of the training set: {}'. format(np.shape(images_train))
    print np.shape(labels_train)
    print 'Size of the test set: {}'. format(np.shape(images_test))
    print np.shape(labels_test)
    
    # Reshape data

    n = images_train.shape[0]
    d = images_train.shape[1]
    images_train  =  images_train.reshape(n,d*d)
    
    n = images_test.shape[0]
    assert d!=images_test.shape[0], 'Test and training sets have different dim'
    images_test  =  images_test.reshape(n,d*d)

    # Select 3s and 8s 

    ind3 = (labels_train==3)
    ind8 = (labels_train==8)

    images_train_38 = images_train[ind3+ind8]
    labels_train_38 = labels_train[ind3+ind8]
    
    ind3 = (labels_test==3)
    ind8 = (labels_test==8)

    images_test_38 = images_test[ind3+ind8]
    labels_test_38 = labels_test[ind3+ind8]

    
    # Dimension Reduction
     
     
#    rimages_train = dr(images_train, labels_train, range(0,10))
#    rimages_test = dr(images_test, labels_test, range(0,10))    
# 
#    print 'Size of the training set after dimension reduction: {}' \
#                                            . format(np.shape(rimages_train))
#    print 'Size of the test set set after dimension reduction: {}' \
#                                            . format(np.shape(rimages_test))
#    
    # Select 3s and 8s after dimension reduction

    rimages_train_38 = dr(images_train_38, labels_train_38, [3,8])
    rimages_test_38 = dr(images_test_38, labels_test_38, [3,8])

    
#    ind3 = (labels_train==3)
#    ind8 = (labels_train==8)
#
#    rimages_train_38 = rimages_train[ind3+ind8]
#    labels_train_38 = labels_train[ind3+ind8]
#    
#    ind3 = (labels_test==3)
#    ind8 = (labels_test==8)
#
#    rimages_test_38 = rimages_test[ind3+ind8]
#    labels_test_38 = labels_test[ind3+ind8]
    
    print 'Size of the training set of 3s and 8s: {}'. format(np.shape(rimages_train_38))
    print 'Size of the test set of 3s and 8s: {}'. format(np.shape(rimages_test_38))
          
#                                1 Naive Bayes
    
    print
    print "1 Naive Bayes"
    print
    print "1.1 Classification"
    print
    
    # Training: priors and likelihood for each d=1,2
    # for each feature and class individual histograms <=> 4 histogramms   
    
    # choose bin size
    L, dx = chooseBinSize(rimages_train_38)
    
    # train classifier for each class separatly                        
    p3, pdf3 = naiveBayes_train_single_class(rimages_train_38, \
                                                  labels_train_38, 3, dx, L)
    p8, pdf8 = naiveBayes_train_single_class(rimages_train_38, \
                                                  labels_train_38, 8, dx, L)
    # test classifier on the test set
    rimages_test_38_predict = naiveBayesClassifier(rimages_test_38, \
                                                p3, p8, pdf3, pdf8, dx)
                                                
    ccr_naiveBayes = correctClassRate(rimages_test_38_predict,\
                                      labels_test_38, [3,8], \
                                      print_confMatrix = True)            
                                            
    print 'Correct Classification rate on the test set:{}'.format(ccr_naiveBayes)   
    print 'Error rate on the test set:{}'.format(1-ccr_naiveBayes)   

#    plot_histogram(pdf3, dx, "Histograms of the class 3", "histograms3.png")
#    plot_histogram(pdf8, dx, "Histograms of the class 8", "histograms8.png")
    
#    plot_likelihood(pdf3, dx, "Likelihoods of the class 3", "likelihoods3.png")
#    plot_likelihood(pdf8, dx, "Likelihoods of the class 8", "likelihoods8.png")


    print
    print "1.2 Generate Threes"
    print
    
    # use function  naiveBayes_train_single_class to compute the likelihood 
    # for all feature dimension

    # choose bin size
    L, dx = chooseBinSize(images_train_38)

    # train classifier for each class separatly                        
    p3, pdf3 = naiveBayes_train_single_class(images_train_38, \
                                                  labels_train_38, 3, dx, L)    

    
    # generate 5 new threes
    new3th = np.zeros((5,d), dtype = np.int32)
    for i in range(0,5) :    
        new3th[i,:] = generate_number(pdf3, dx)
        
        img = new3th[i,:].reshape(np.sqrt(d),np.sqrt(d))
        f = plot.figure()
        plot.gray()
        plot.imshow(img);
        plot.show()
    # end for i
  
    print
    print "2 Density Tree"
    print
    print "2.1 Building the DT. Naive splitting"
    print  
    
#    for c in [3,8]:
#        DT_learning_naive(images_train_38, labels_train_38, c)        
#    # end for
        
    print "2.2 Classification"
    print

    print "2.3 Generate Threes"
    print
    
    print    
    print "3 Combine DT and Naive Bayes"
    print
    
if __name__ == "__main__":
    main()