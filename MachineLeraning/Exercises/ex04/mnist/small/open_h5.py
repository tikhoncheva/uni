import numpy as np
import vigra
import h5py

print
print "either open via vigra:"
print

test_path     = "test.h5"
training_path = "test.h5"

images_train = vigra.readHDF5(test_path, "images")
labels_train = vigra.readHDF5(test_path, "labels")

images_test = vigra.readHDF5(training_path, "images")
labels_test = vigra.readHDF5(training_path, "labels")

print np.shape(images_train)
print np.shape(labels_train)
print np.shape(images_test)
print np.shape(labels_test)

print
print "or via h5py"
print

f = h5py.File(test_path)
images_test = f["images"].value
labels_test = f["labels"].value
f.close()

f = h5py.File(training_path)
images_train = f["images"].value
labels_train = f["labels"].value
f.close()

print np.shape(images_train)
print np.shape(labels_train)
print np.shape(images_test)
print np.shape(labels_test)