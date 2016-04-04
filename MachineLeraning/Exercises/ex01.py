# -*- coding: utf-8 -*-
"""
Created on Mon Oct 20 15:54:58 2014

@author: kitty
"""

import numpy as np
import vigra
import sklearn
import matplotlib.pyplot as plot

l = [[1,2,3,4,5],[11,12,13,14,15]]
b = np.array([[1,1,0,1,0],[0,1,0,1,0]])

a = np.array(l)
print a[b.astype(np.bool)]

a = np.random.random((12,12))
plot.figure(1)
plot.gray()
plot.imshow(a, interpolation = 'nearest')

plot.figure(2)
plot.imshow(a>0.5, interpolation = 'nearest')