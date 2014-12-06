"""
Exercise 4 : Generative Non-parametric Classofocation

"""

import numpy as np
import matplotlib.pyplot as plot
from scipy.sparse.linalg import lsqr


#-----------------------------------------------------------------------------
def makeA(shape, alphas):
    assert shape[0]==shape[1], 'Expect square matrix'
    
    N = shape[0]    # NxN shape of the image
    M = len(alphas) # number of alphas
    K = int(N*np.sqrt(2))
    
    if K%2==0:
        K = K + 1   # sensor length is always a odd number
    
    sensorcenter = np.zeros((2,K), dtype = np.float32)
    A = np.zeros((N*N, M*K), dtype = np.float32)    
    
    for a in range(0,1):
        
        alpha = alphas[a]
        ralpha = np.pi*(alpha+90)/180. # alpha in radians
                        
        for s in range(0,K):
            if alpha==0:
                sensorcenter[0][s]= 0
                sensorcenter[1][s]= K -s -1 - (K-1)/2
            else :                 
                sensorcenter[0][s]= np.cos(ralpha)*(K - s - 1 - (K-1)/2 )
                sensorcenter[1][s]= np.sin(ralpha)*(K - s - 1 - (K-1)/2 )
        # end for i
        
        print sensorcenter
        
        
        # for each pixel calculate contribution to absorption along a rai
        for i in range(0,N*N):
                            
            # pixel coordinates
            # shift coordinate center to the picture center
#            if N%2==0:
#                x = i/N - N/2 + 0.5
#                y = N -i%N - N/2 -0.5
#            else:
#                x = i/N - (N-1)/2
#                y = N - 1 - i%N - (N-1)/2   
#            #end if    
                        
            if N%2==0:
                y = N/2 - 0.5 - i/N
                x = i%N - N/2 + 0.5
            else:
                y = (N-1)/2 - i/N
                x = i%N - (N-1)/2 
            #end if    
            
#            print x,y
            
            # px,py - projection of the pixel on the sensor 
            if alpha==0:           
                py = y
                px = 0                    
            else:
                px = (y*np.tan(ralpha)-x)/(np.tan(ralpha)*np.tan(ralpha)-1)
                py = np.tan(ralpha)*px
            # end if
            
            pixelcontribution = np.abs(x*np.tan(ralpha)-y)/ \
                               np.sqrt(np.tan(ralpha)*np.tan(ralpha) + 1)
            
            print "Projection of point {},{} is {},{}. Dist = {}". format(x,y,px,py, pixelcontribution)
            #distance between projection of (x,y) and centers of the sensorpixel
            dist =  np.zeros(K, dtype = np.float32)
            for s in range(0,K):
                dist[s] = (sensorcenter[0][s]-px)*(sensorcenter[0][s]-px)\
                        + (sensorcenter[1][s]-py)*(sensorcenter[1][s]-py)
                dist = np.sqrt(dist)
            #end for s
            ind = np.argsort(dist)
            
            if np.abs(dist[ind[0]]-0.5)<0.001:
                print "hit between two sensor pixels"
                # if ray meets sensor in between of two sensor pixels
                dist1 = np.sqrt((sensorcenter[0][ind[0]]-x)*(sensorcenter[0][ind[0]]-x)\
                      + (sensorcenter[1][ind[0]]-y)*(sensorcenter[1][ind[0]]-y))
                dist2 = np.sqrt((sensorcenter[0][ind[1]]-x)*(sensorcenter[0][ind[1]]-x)\
                      + (sensorcenter[1][ind[1]]-y)*(sensorcenter[1][ind[1]]-y))                                  
                # intensity of the ray is devided between those pixels
                A[i][a*K+ind[0]] += pixelcontribution*dist1/(dist1+dist2) 
                A[i][a*K+ind[1]] += pixelcontribution*dist2/(dist1+dist2)
            else:
                A[i][a*K+ind[0]] += pixelcontribution
            #end if                
        # end for i
   
#   # end for alpha     
    return A
# end def makeA    
#-----------------------------------------------------------------------------
#                            Main Function
def main():
    plot.close('all')  
    
    print
    print "Construction of A"
    print
    
    Atest = makeA([5,5], [-90, -33, -12, 3, 21, 42, 50, 86])

    f = plot.figure()
    plot.gray()
    plot.imshow(Atest.transpose(), interpolation = 'nearest')
    plot.title("Matrix A")    
    plot.show()
    f.savefig("matrixA.png")
    
    print
    print "Reconstruction of the Image"
    print
    
    print
    print "Minimization of the radiation dose"
    print
    
 #end main

   
if __name__ == "__main__":
    main()
