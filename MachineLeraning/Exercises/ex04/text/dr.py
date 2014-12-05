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