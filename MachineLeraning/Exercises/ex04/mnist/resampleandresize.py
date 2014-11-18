import os, struct
from array import array
from cvxopt.base import matrix
import os.path
import numpy as np
import vigra

def read(digits, dataset = "training", path = "."):
    """
    Python function for importing the MNIST data set.
    """

    if dataset is "training":
        # fname_img = os.path.join(path, 'train-images-idx3-ubyte')
        # fname_lbl = os.path.join(path, 'train-labels-idx1-ubyte')

        fname_img = path+"train-images.idx3-ubyte"
        fname_lbl = path+"train-labels.idx1-ubyte"
    elif dataset is "testing":
        # fname_img = os.path.join(path, 't10k-images-idx3-ubyte')
        # fname_lbl = os.path.join(path, 't10k-labels-idx1-ubyte')
        fname_img = path+"t10k-images.idx3-ubyte"
        fname_lbl = path+"t10k-labels.idx1-ubyte"
    else:
        raise ValueError, "dataset must be 'testing' or 'training'"

    flbl = open(fname_lbl, 'rb')
    magic_nr, size = struct.unpack(">II", flbl.read(8))
    lbl = array("b", flbl.read())
    flbl.close()

    fimg = open(fname_img, 'rb')
    magic_nr, size, rows, cols = struct.unpack(">IIII", fimg.read(16))
    img = array("B", fimg.read())
    fimg.close()

    ind = [ k for k in xrange(size) if lbl[k] in digits ]
    images =  matrix(0, (len(ind), rows*cols))
    labels = matrix(0, (len(ind), 1))
    for i in xrange(len(ind)):
        images[i, :] = img[ ind[i]*rows*cols : (ind[i]+1)*rows*cols ]
        labels[i] = lbl[ind[i]]

    return images, labels


def downsapmple(set, labels, how_often):
    set_n = np.shape(set)[0]
    assert np.shape(labels)[0] == set_n, str(np.shape(labels)[0])+" "+str(set_n)

    set_new = np.zeros((set_n * how_often, 9, 9))
    labels_new = np.zeros((set_n * how_often))

    count0 = 0
    count1 = 0

    for i in range(set_n):
        img = set[i]
        lab = labels[i,0]

        # sample from image
        for m in range(how_often):
            id_new = (how_often * i) + m
            sigmas = np.random.normal(loc=1.0, scale=1, size=2)
            sigmas[sigmas < 0.5] = 0.5
            ofsets = np.random.normal(loc=0.0, scale=0.8, size=2)

            img_new = vigra.sampling.resamplingGaussian(
                img.astype(np.float32), sigmaX=sigmas[0], sigmaY=sigmas[1],
                                        samplingRatioX=0.35, samplingRatioY=0.35,
                                        offsetX=ofsets[0], offsetY=ofsets[1])

            set_new[id_new, :, :] = img_new
            labels_new[id_new] = lab

            if lab == 0:
                count0 += 1
            if lab == 1:
                count1 += 1

    return set_new, labels_new


if __name__ == "__main__":

    mnist_path = "original/"
    wanted_digits = [0,1,2,3,4,5,6,7,8,9]

    print "loading trainingset"
    images_train, labels_train =  read( wanted_digits,
                                        dataset="training",
                                        path = mnist_path )
    images_train = np.reshape(images_train, (np.shape(images_train)[0], 28, 28))

    print "loading testset"
    images_test, labels_test =  read(   wanted_digits,
                                        dataset="testing",
                                        path = mnist_path )
    images_test = np.reshape(images_test, (np.shape(images_test)[0], 28, 28))

    print "downsample train"
    images_train_new, labels_train_new = downsapmple(images_train, labels_train[:,0], 2)

    print "downsample test"
    images_test_new,  labels_test_new  = downsapmple(images_test, labels_test[:,0], 10)

    labels_train = np.array(labels_train)
    labels_test = np.array(labels_test)

    path_train_new = "small/train.h5"
    path_test_new = "small/test.h5"

    save = 0
    if save:
        vigra.writeHDF5(images_train_new, path_train_new, "images")
        vigra.writeHDF5(labels_train_new, path_train_new, "labels")

        vigra.writeHDF5(images_test_new, path_test_new, "images")
        vigra.writeHDF5(labels_test_new, path_test_new, "labels")