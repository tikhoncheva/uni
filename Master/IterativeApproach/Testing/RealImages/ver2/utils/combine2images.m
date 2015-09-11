% combine two images in one by putting them one next to the other
function img3 = combine2images(img1, img2)

    ihight = max(size(img1,1),size(img2,1));
    if size(img1,1) < ihight
      img1(ihight,1,1) = 0;
    end
    if size(img2,1) < ihight
      img2(ihight,1,1) = 0;
    end

    img3 = cat(2,img1,img2);

end