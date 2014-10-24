    digits = load_digits()
    print digits.keys()
    
    data = digits['data']
    images = digits['images']
    target = digits['target']
    target_names = digits['target_names']
    
    print 'Size of the digit set {}'. format(digits.data.shape)
    #print np.dtype(data) # TypeError :data type not understood
    
    # get all images with 3
    img3 = images[target == 3 ]
    # show the first one
    img = img3[0]
    assert 2 == np.size(np.shape(img))
    
    plot.figure()
    plot.gray();
    plot.imshow(img, interpolation = 'nearest');
    plot.show()
