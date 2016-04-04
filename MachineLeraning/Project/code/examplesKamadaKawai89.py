## Examples from paper of Kamada, Kawai 
# " An Algorithm for drawing general undirected graphs"
#
import numpy as np

def examplePicture2():
    A = np.array([[np.Infinity,1,np.Infinity,np.Infinity,1,np.Infinity],
                  [1,np.Infinity,np.Infinity,1,1,np.Infinity],
                  [np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,1],
                  [np.Infinity,1,1,np.Infinity,np.Infinity,1],
                  [1,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,np.Infinity,1,1,np.Infinity,np.Infinity]])
 
    return A
# end exampleAbb2()
    
def examplePicture3a():
    A = np.array([[np.Infinity,1,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [1,np.Infinity,1,1,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [1,1,np.Infinity,np.Infinity,1,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,1,np.Infinity,np.Infinity,1,np.Infinity,1,1,np.Infinity,np.Infinity],
                  [np.Infinity,1,1,1,np.Infinity,1,np.Infinity,1,1,np.Infinity],
                  [np.Infinity,np.Infinity,1,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,1,1],
                  [np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity],
                  [np.Infinity,np.Infinity,np.Infinity,1,1,np.Infinity,1,np.Infinity,1,np.Infinity],
                  [np.Infinity,np.Infinity,np.Infinity,np.Infinity,1,1,np.Infinity,1,np.Infinity,1],
                  [np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,1,np.Infinity]])
 
    return A
# end examplePicture3a
    
def examplePicture5a():
    A = np.array([[np.Infinity,1,np.Infinity,np.Infinity,1,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [1,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,1,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity,1,1],
                  [np.Infinity,np.Infinity,1,np.Infinity,1,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity],
                  [1,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity],
                  [1,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,np.Infinity,np.Infinity,1,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity,1],
                  [np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity]])
 
    return A
# end examplePicture5

def example_edgecrossing():
    A = np.array([[np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity,np.Infinity],
                  [1,np.Infinity,np.Infinity,1,np.Infinity,1,np.Infinity,np.Infinity],
                  [np.Infinity,1,1,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,1,1,np.Infinity],
                  [np.Infinity,np.Infinity,1,np.Infinity,1,np.Infinity,np.Infinity,1],
                  [np.Infinity,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity,np.Infinity],
                  [np.Infinity,np.Infinity,np.Infinity,np.Infinity,np.Infinity,1,np.Infinity,np.Infinity]])
    return A
# end example_edgecrossing    
    