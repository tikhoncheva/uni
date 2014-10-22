"""
Created on Thu Oct 16 18:08:28 2014

@author: kitty

"""

import numpy as np
import matplotlib.pyplot as plt

def factorial(n):
    
    if (n==1 or n==0):
        ans = 1
    else :
        ans = n*factorial(n-1)
    
    return ans


def main():
    # Task 1 ; Plot sin(x) for x=-1..1. Label the axes and add a title. Save figure as png    

    plt.close('all')
    
    x = np.linspace(-1,1,100)
    y = np.sin(x)
    
    f = plt.figure()
    plt.title('y=sin(x), x=[-1,1]')
    plt.xlabel('x')
    plt.ylabel('y')
    line = plt.plot(x, y, '-', linewidth = 2)
    plt.show()
    f.savefig('task1.png')
    
    # Task 2: Calculate 5!

    print '0! = {}'. format(factorial(0))    
    print '1! = {}'. format(factorial(1))
    print '5! = {}'. format(factorial(5))
    
    # Task 3: find and output eigenvalues and eigenvectors of the matrix A
    A = np.asarray([[4,0,-1],[2,5,4],[0,0,5]])
    
    print 'Matrix A = {}'. format(A)
    
    # w = eigenvalues
    # v = eigenvectors, v[:,i] corresponds to eigenvalue w[i]
    w, v = np.linalg.eig(A)
    m,n = v.shape
    print 'Eigenvalues of A = {}'. format(w)
    print 'Eigenvectors of A = {}'. format(v)
    # Task 4: Concatenate the eigenvectors as columns in a matrix P
    P = np.zeros((m,n), dtype = np.float16)
    P = v
    
    # compute P^(-1)
    Pinv = np.linalg.inv(P)
    
    # Calculate B = P EV P^(-1), where EV = diag(evalue1, evalue2, ...)
    
    EV = np.diag(w)
    B = np.dot(P, np.dot(EV,Pinv))
    
    print 'Matrix B = {}'. format(B)
    # confirm that A==B
    assert np.all(A==B)
    
    return 0
    
if __name__ == "__main__":
    main()    