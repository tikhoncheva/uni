"""
Exercise 4 : Tree structure

"""

class DTnode(object):
    def __init__(self, ind, points, region, left = None, right = None):
        self.ind = ind
        self.points = points      # number of the points in the region
        self.region = region    # region
        self.left = left        # left son 
        self.right = right      # right son
    # def __init__
        
    def insert_left(self, ind, points, region):
        self.left = DTnode(ind, points, region, left = None, right = None)        
   # end insert_left 
    
    def insert_right(self, ind, points, region):
        self.right = DTnode(ind, points, region, left = None, right = None)        
   # end insert_right

    def search(self, ind): #returns True if value is in the tree
        if self.ind == ind:
            return True
        else:
            if self.left != None:
                return self.left.search(ind)
            else:
                return False
            if self.right != None:
                    return self.right.search(ind)
            else:
                return False                    
#    def search(self, vind):
        
    # def search        
