function display_inputimages( status, cdata )
% display the input images
    
    if cdata.bPair
        imgInput = appendimages( cdata.view(1).img, cdata.view(2).img );
        str_out = sprintf('%s and %s', cdata.view(1).fileName, cdata.view(2).fileName);     
    else
        imgInput = [ cdata.view(1).img ];
        str_out = sprintf('%s', cdata.view(1).fileName);     
    end
    imgInput = double(imgInput)./255;

    %hFigMain = figure(5002);
    imshow(imgInput);
    %set( gca,'Position',[0,0,1,1]); 
    title(str_out);
    %pause;
