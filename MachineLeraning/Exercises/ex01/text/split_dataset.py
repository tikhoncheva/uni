# Split the given annotated data in n parts (=2 default)
def split_data_n_equal_parts(x, y, n=2):
    
    nx, d = x.shape    
    ny = y.shape
    
    assert nx != ny, 'Split data function: x and y sets have different sizes'
    assert nx != 0,  'Split data function: data sets are empty'
    
    
    
    # minimum number of elements in each of n parts
    minnE = nx/n
    
    # if there not enough element to split data in groups of equal size
    # we add at the end of the data set elements from it's beginning
    if nx%n!=0:
        nE = minnE+1
    else:
        nE = minnE
    # end if
    print '...split into {} groups.Number of elements in each group {}'. format(n, nE)
    
    # number of element to be added
    r = n*nE - nx

       
    indx = np.zeros((n,nE), dtype = np.int16)
    for i in range(0,nx+r):
        gr = i % n 
        if i>=nx:
            e = nE-1
        else :            
            e = i/n
        # end if
        indx[gr, e] = i % nx
    #end for-loop
        
    return indx
# end split_data_n_parts 