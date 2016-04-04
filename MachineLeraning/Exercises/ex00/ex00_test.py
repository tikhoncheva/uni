# -*- coding: utf-8 -*-
"""
Created on Thu Oct 16 18:08:28 2014

@author: kitty
"""
# Task1: Fizzdizz - game
for i in range(0, 100):
    if (i%3==0):
        print "fizz"
    
    if (i%5==0):
        print "dizz"
    else:
        print i
print "end"

#Task 2 :

s = "Hello"
print s[1:]
print s[2:4]
print s[0:-1:2]
print s[::2]
            
#Task3 Numpy

import numpy

a = numpy.zeros((4, 6), dtype = numpy.uint8)
print a.ndim
print a.shape, a.shape[0], a.shape[1]
print a.dtype

b = numpy.random.random(a.shape)
 
c = a + b;
d = a*b
e = a/(b+1)
f = numpy.sqrt(b)

a[:] = 1
a[1,2] = 2

s = numpy.sum(a)
# assert s == 7

a[:,0] = 42
a[0, ...] = 42

aa = numpy.asarray([[2,5,4,3,1],[1,2,1,5,7]])
print aa.shape
print aa
print numpy.where(aa==2)
print numpy.where(aa==4)
print aa[numpy.where(aa==1)]

# Task 4

import vigra
img = vigra.impex.readImage('./myImages.png')
img.shape




            
    