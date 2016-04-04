function GT = assignGT_etikhonc(view, F1, F2, knownGT)

    feat2 = view(2).feat(:,1:2);
    feat1 = view(1).feat(:,1:2);
    
    Idx1 = knnsearch(feat1,F1);
    Idx2 = knnsearch(feat2,F2);
    GT(:,1) = Idx1(knownGT(:,1));
    GT(:,2) = Idx2(knownGT(:,2));


end
