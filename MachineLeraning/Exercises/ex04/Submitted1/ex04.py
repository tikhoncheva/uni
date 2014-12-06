"""
Exercise 4 : Generative Non-parametric Classofocation

"""

import numpy as np
import matplotlib.pyplot as plot
import vigra

import time

from correctClassificationRate import correctClassRate

from naiveBayes import chooseBinSize
from naiveBayes import naiveBayes_train_single_class
from naiveBayes import naiveBayesClassifier
from naiveBayes import generate_number as generate3naiveBayes

from densityTree import point_in_region
from densityTree import DT_learning
from densityTree import DT_visualize2D
from densityTree import DT_Classifier_2classes
from densityTree import generate_number as generate3DT

from naiveBayesAndDT import generate_number as generate3
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
#                   Plot 1D histograms
def plot_histogram(pdf,dx, title = 'Histograms for each of d dimensions',\
                                             imageName = 'histogram.png'):
    
    f, (ax1, ax2) = plot.subplots(1, 2, sharey=True)
    
    f.suptitle(title, fontsize=14)
    ax1.set_xlabel('x')
    ax1.set_ylabel('Probability') 
    
    ax2.set_xlabel('x')
    ax1.set_ylabel('Probability') 
    
    ax1.set_title('d=1')
    ax2.set_title('d=2')
    
    
    for i in range(0,len(pdf[0])):
        # subplot 1
        ax1.plot([i*dx[0], i*dx[0], (i+1)*dx[0],(i+1)*dx[0]], \
                 [0, pdf[0][i], pdf[0][i], 0 ], 'r-')
        ax1.set_xlim([0,len(pdf[0])*dx[0]])                 
    for i in range(0,len(pdf[1])):        
        # subplot 2
        ax2.plot([i*dx[1], i*dx[1], (i+1)*dx[1],(i+1)*dx[1]], \
                 [0, pdf[1][i], pdf[1][i], 0 ], 'b-')
        ax2.set_xlim([0,len(pdf[0])*dx[1]])
    # end for

    plot.show()
    
    f.savefig(imageName)    
#end def      

#-----------------------------------------------------------------------------
#                   Plot 2D Likelihood
def plot_likelihood(pdf, dx, title = 'likelihood',\
                                             imageName = 'likelihood.png'):
    L1 = len(pdf[0]) # number of bins in the first histogram
    L2 = len(pdf[1]) # number of bins in the second histogram    
    
    img = np.zeros((np.ceil(L1*dx[0]),np.ceil(L2*dx[1])), dtype = np.float64)

    for i in range(0,L1):
        for j in range(0,L2):
            img[np.ceil(i*dx[0]):np.ceil((i+1)*dx[0]),\
                np.ceil(j*dx[1]):np.ceil((j+1)*dx[1])] = pdf[0][i]*pdf[1][j]
        #end for j    
    #end for i
        
    f = plot.figure() 
    plot.gray()
    plot.imshow(img.transpose(), interpolation = 'nearest')       
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
  
    # Dimension reduction

    rimages_train_38 = dr(images_train_38, labels_train_38, [3,8])
    rimages_test_38 = dr(images_test_38, labels_test_38, [3,8])
    
    print 'Size of the training set of 3s and 8s: {}'. format(np.shape(rimages_train_38))
    print 'Size of the test set of 3s and 8s: {}'. format(np.shape(rimages_test_38))
          
    
    print
    print "1 Naive Bayes"
    print
    print "1.1 Classification"
    print
    
    # Training: priors and likelihood for each d=1,2
    # for each feature and class individual histograms <=> 4 histogramms   
    
    n = rimages_train_38.shape[0]
    d = rimages_train_38.shape[1]
    
    # Choose bin width 
    L, dx = chooseBinSize(rimages_train_38)


    # train classifier for each class separatly                        
    p3, pdf3 = naiveBayes_train_single_class(rimages_train_38, \
                                                  labels_train_38, 3, L, dx)
    p8, pdf8 = naiveBayes_train_single_class(rimages_train_38, \
                                                  labels_train_38, 8, L, dx)
                                                    
    rimages_test_38_predict = naiveBayesClassifier(rimages_test_38, \
                                                p3, p8, pdf3, pdf8, L, dx)
                                                
    ccr_naiveBayes = correctClassRate(rimages_test_38_predict,\
                                      labels_test_38, [3,8], \
                                      print_confMatrix = True)            
                                            
    print 'Correct Classification rate on the test set:{}'.format(ccr_naiveBayes)   
    print 'Error rate on the test set:{}'.format(1-ccr_naiveBayes)   

    
    plot_histogram(pdf3, dx, "Histograms of the class 3", "histograms3.png")
    plot_histogram(pdf8, dx, "Histograms of the class 8", "histograms8.png")
    
    plot_likelihood(pdf3, dx, "Likelihoods of the class 3", "likelihoods3.png")
    plot_likelihood(pdf8, dx, "Likelihoods of the class 8", "likelihoods8.png")

    print
    print "1.2 Generate Threes"
    print
    
    # use function  naiveBayes_train_single_class to compute the likelihood 
    # for all feature dimension

    n = images_train_38.shape[0]
    d = images_train_38.shape[1]
    
    # Choose bin width 
    L, dx = chooseBinSize(images_train_38)

    # train classifier for each class separatly                        
    p3, pdf3 = naiveBayes_train_single_class(images_train_38, \
                                                  labels_train_38, 3, L, dx)    
    # generate 3 new threes
    new3th = np.zeros((3,d), dtype = np.int32)
    for i in range(0,3) :    
        new3th[i,:] = generate3naiveBayes(pdf3, dx)
        
        img = new3th[i,:].reshape(np.sqrt(d),np.sqrt(d))
        plot.figure()
        plot.gray()
        plot.imshow(img);
        plot.show()
    # end for i
        
  
    print
    print "2 Density Tree"
    print
    print "Naive splitting"
    print  

    
    tstart = time.time()
    
    # class 3    
    prior3, DT3 = DT_learning(rimages_train_38, labels_train_38, 3, 'naive')            
    DT_visualize2D(DT3, rimages_train_38, labels_train_38, 3, "naiveDT3.png")        
    # class 8
    prior8, DT8 = DT_learning(rimages_train_38, labels_train_38, 8, 'naive')        
    DT_visualize2D(DT8, rimages_train_38, labels_train_38, 8, "naiveDT8.png")        
    
    tstop = time.time()
    print "DT learning time (naive splitting) {}". format(tstop-tstart)
        
    tstart = time.time()    
    rimages_test_38_predict = DT_Classifier_2classes(rimages_test_38, 
                                                prior3, prior8, DT3, DT8, [3,8])
    tstop = time.time()
    print "DT classification time (naive splitting) {}". format(tstop-tstart)
                                                
    ccr_DT = correctClassRate(rimages_test_38_predict,\
                                      labels_test_38, [3,8], \
                                      print_confMatrix = True)     

    print 'Correct Classification rate on the test set:{}'.format(ccr_DT)   
    print 'Error rate on the test set:{}'.format(1-ccr_DT)                 
      
    print 
    print 'Generate new threes: '
    
    d = images_train_38.shape[1]

    # new threes
    new3th = np.zeros((3,d), dtype = np.int32)    
    for i in range(0,3) :    
        new3th[i,:] = generate3DT(images_train_38, labels_train_38, 3 )
        img = new3th[i,:].reshape(np.sqrt(d),np.sqrt(d))
        
        plot.figure()
        plot.gray()
        plot.imshow(img);
        plot.show()
    # end for i
      
    print
    print "Clever splitting"
    print

#    # class 3    
#    prior3, DT3 = DT_learning(rimages_train_38, labels_train_38, 3, 'clever')        
#    DT_visualize2D(DT3, rimages_train_38, labels_train_38, 3, "naiveDT3.png")        
#    # class 8
#    prior8, DT8 = DT_learning(rimages_train_38, labels_train_38, 8, 'clever')        
#    DT_visualize2D(DT8, rimages_train_38, labels_train_38, 8, "naiveDT8.png")        
#    
#        
#    rimages_test_38_predict = DT_Classifier_2classes(rimages_test_38, 
#                                                prior3, prior8, DT3, DT8, [3,8])
#                                                
#    ccr_DT = correctClassRate(rimages_test_38_predict,\
#                                      labels_test_38, [3,8], \
#                                      print_confMatrix = True)     
#
#    print 'Correct Classification rate on the test set:{}'.format(ccr_DT)   
#    print 'Error rate on the test set:{}'.format(1-ccr_DT)           
#   
#    print   
#    print "Generate Threes"
#    print
    
    print    
    print "3 Combine DT and Naive Bayes"
    print
    
    
    n = images_train_38.shape[0]
    d = images_train_38.shape[1]


    print    
    print "Learning phase"
    print
    
    # train 1D-histogramms for each feature and class      
    
    tstart = time.time() 
    L, dx = chooseBinSize(images_train_38) # number of bins, bins size
    
    # pdf dxL matrices                  
    prior3, pdf3 = naiveBayes_train_single_class(images_train_38, \
                                                  labels_train_38, 3, L, dx)    
    prior8, pdf8 = naiveBayes_train_single_class(images_train_38, \
                                                  labels_train_38, 8, L, dx)    
    # compute the cdf of each histogramm
    cdf3 = [] 
    cdf8 = []
    pdf3sorted = []
    pdf8sorted = []
    for j in range(0, d):
        tmp = np.sort(pdf3[j])
        pdf3sorted.append(tmp)
        cdf3.append(np.cumsum(tmp) )

        tmp = np.sort(pdf8[j])
        pdf8sorted.append(tmp)        
        cdf8.append(np.cumsum(tmp) )
    # end for                                               

    tstop = time.time()
    print "Learning 1D histograms and computing cdf's took {} sec".\
                                                        format(tstop-tstart)
    
    # map data to copula using rank order transformation
    u = np.zeros(images_train_38.shape, dtype = np.float32)
    for j in range(0,d):
        ind = np.argsort(images_train_38[:,j])
        u[:,j] = ind[:]/float(n+1)
    # end for j    
    
    print
    print "Generate threes"
    
    new3th = np.zeros((3,d), dtype = np.int32)  
    for i in range(0,3) :

        u1 = generate3(u, labels_train_38 , 3 )

        for j in range(0,d):
            dist =abs(cdf3[j] - u1[j])
            binx = np.argsort(dist)
            new3th[i,j] = np.floor(dx[j]*binx[0]/2.)
        # end for j
        img = new3th[i,:].reshape(np.sqrt(d),np.sqrt(d))
        
        plot.figure()
        plot.gray()
        plot.imshow(img);
        plot.show()
     #end for i
 #end main

   
if __name__ == "__main__":
    main()