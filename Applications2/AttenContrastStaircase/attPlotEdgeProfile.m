%plot the luminance profile of a coc edge
display          = cocInitDisplay;
stimParams       = cocInitStimParams(display);
display          = cocInitFixParams(display, stimParams);

stimParams.type = 'coc';
%get the image
[im x y] = cocSingleFrame(stimParams, display);

%add a fixation
im(x<3.25 & x > 2.75 & y<1&y>-1) = max(im(:));
figure; 
subplot(2,1,1)
mesh(x, y, im)
h = round(size(x,2)/2);
subplot(2,1,2)
plot(x(h,:), im(h,:))

title('sigmaL = ??; sigmaH = ??')