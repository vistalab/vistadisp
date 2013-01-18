% Font pertubation algorithm:
%  - Fit a spline to each character (use these splines to 
%		generate the "standard" fonts)
%	- Perturb the splines by a variable amount to produce
%		the pseudofonts.
%

addpath /home/bob/matlab/fonts

n = 50;
%r = 105; c = 105;
r = 300; c = 150;
cmap = [1 1 1; 0 0 0];
thick = 5;

% spline for any form
% spline = getSplinePts('letters.tif');
% image(renderSpline(scaleSpline(spline,c*.2,r*.2,c*.8, r*.8), r, c, thick)+1);
% colormap(cmap);truesize;axis off;

% spline for right-leaning line segments
lsR(1).x = linspace(0,.5,5);
lsR(1).y = linspace(0,1,5);
lsR(2).x = linspace(.25,.75,5);
lsR(2).y = linspace(0,1,5);
lsR(3).x = [.5, .75, 1.0];
lsR(3).y = [0, .5, 1];
lsRIm = renderSpline(scaleSpline(lsR,c*.2,r*.2,c*.8, r*.8), r, c, thick);
%figure; image(lsRIm+1); colormap(cmap); truesize; axis off;

% spline for left-leaning line segments
lsL(1).x = linspace(.5,0,5);
lsL(1).y = linspace(0,1,5);
lsL(2).x = linspace(.75,.25,5);
lsL(2).y = linspace(0,1,5);
lsL(3).x = [1.0, .75, 0.5];
lsL(3).y = [0, .5, 1];
lsLIm = renderSpline(scaleSpline(lsL,c*.2,r*.2,c*.8, r*.8), r, c, thick);
%figure; image(lsLIm+1); colormap(cmap); truesize; axis off;

% spline for a letter "B"
%b(1).x = [.25, .45, .675, .45, .25];
b(1).x = [.1, .5, .75, .5, .1];
b(1).y = [1, 1, .8, .6, .6];
b(2).x = [.1, .65, .9, .65, .1];
b(2).y = [.6 .6 .3 0 0];
b(3).x = [.1, .1, .1];
b(3).y = [0, .6, 1];
bIm = renderSpline(scaleSpline(b, c*.1, r*.1, c*.9, r*.9), r, c, thick);
figure; image(bIm+1); colormap(cmap); truesize; axis off;
% spline for a letter "A"
a(1).x = linspace(.25,.5,5);
a(1).y = linspace(0,1,5);
a(2).x = linspace(.75,.5,5);
a(2).y = linspace(0,1,5);
a(3).x = [.375, .5, .675];
a(3).y = [.5, .5, .5];
aIm = renderSpline(scaleSpline(a,c*.2,r*.2,c*.8, r*.8), r, c, thick);
%figure; image(aIm+1); colormap(cmap); truesize; axis off;

% morphed spline
%w = [0,logspace(-1,0,4)];
w = linspace(0,1,7);
%w = linspace(0,.9,7)+.05;
nLevels = length(w);
clear im;
for(ii=1:nLevels)
    clear ms;
    for(jj=1:length(ls))
        ms(jj).x = w(ii).*lsR(jj).x + (1-w(ii)).*b(jj).x;
        ms(jj).y = w(ii).*lsR(jj).y + (1-w(ii)).*b(jj).y;
    end
    im(:,:,ii) = renderSpline(scaleSpline(ms,c*.2,r*.2,c*.8, r*.8), r, c, thick);
end
montage = makeMontage(im(:,:,:)+1, [], [], nLevels);
figure; image(montage); colormap(cmap); truesize; axis off;
colDiff = [0,0,0;0,0,-.35];
for(ii=1:size(im,3))
    fname = ['B_' num2str(round(w(ii)*100),'%03d') '_dist05'];
    fname = fullfile('/home/bob/SIRL/splineFonts', fname);
    imwrite(im(:,:,ii)+1, cmap, [fname '_1.bmp']);
    imwrite(im(:,:,ii)+1, cmap-colDiff, [fname '_2.bmp']);
    disp(fname); 
end
%imwrite(montage, cmap, 'b_to_lines_dist05.tif', 'tiff');
% msIm = renderSpline(scaleSpline(ms,c*.2,r*.2,c*.8, r*.8), r, c, thick);
% figure; image(msIm+1); colormap(cmap); truesize; axis off;

% morphed spline
%w = [0,logspace(-1,0,4)];
w = linspace(0,1,7);
%w = linspace(0,.9,7)+.05;
nLevels = length(w);
clear im;
for(ii=1:nLevels)
    clear ms;
    for(jj=1:length(ls))
        ms(jj).x = w(ii).*lsR(jj).x + (1-w(ii)).*a(jj).x;
        ms(jj).y = w(ii).*lsR(jj).y + (1-w(ii)).*a(jj).y;
    end
    im(:,:,ii) = renderSpline(scaleSpline(ms,c*.2,r*.2,c*.8, r*.8), r, c, thick);
end
montage = makeMontage(im(:,:,:)+1, [], [], nLevels);
figure; image(montage); colormap(cmap); truesize; axis off;
colDiff = [0,0,0;0,0,-.3];
for(ii=1:size(im,3))
    fname = ['A_' num2str(round(w(ii)*100),'%03d') '_dist05'];
    fname = fullfile('/home/bob/SIRL/splineFonts', fname);
    imwrite(im(:,:,ii)+1, cmap, [fname '_1.bmp']);
    imwrite(im(:,:,ii)+1, cmap-colDiff, [fname '_2.bmp']);
    disp(fname);
end



% perturb spline
curveStdev = 0.1;
endStdev = 0.1;
flipudProb = 0;
fliplrProb = 0;
nSamples = 5;
fName = ['B'];
nLevels = length(curveStdev);
nLevels = 5;
pSpline = b;
clear im;
for ii=1:nLevels
    im(:,:,ii) = renderSpline(scaleSpline(pSpline,c*.2,r*.2,c*.8, r*.8), r, c, thick);
    pSpline = perturbSpline(pSpline, curveStdev, endStdev, flipudProb, fliplrProb);
end
%figure;
montage = makeMontage(im(:,:,:)+1, [], [], nLevels);
image(montage); colormap(cmap); truesize; axis off;
%imwrite(montage, cmap, [fName '.tif'], 'tiff');

% spline for a letter "A"
spline(1).x = [.25, .375, .5];
spline(1).y = [0, .5, 1];
spline(2).x = [.75, .675, .5];
spline(2).y = [0, .5, 1];
spline(3).x = [.375, .5, .675];
spline(3).y = [.5, .5, .5];

curveStdev = [0 .05 .1 .15 .2 .25];
endStdev = [0 .05 .1 .15 .2 .25];
flipudProb = 0;
fliplrProb = 0;
nSamples = 5;
fName = ['A'];
nLevels = length(curveStdev);
for ii=1:nLevels
    for jj=1:nSamples
        pSpline = perturbSpline(spline, curveStdev(ii), endStdev(ii), flipudProb, fliplrProb);
        im(:,:,(jj-1)*nLevels+ii) = renderSpline(scaleSpline(pSpline,c*.2,r*.2,c*.8, r*.8), r, c, thick);
    end
end
%figure;
montage = makeMontage(im(:,:,:)+1, [], [], nLevels);
image(montage); colormap(cmap); truesize; axis off;
%imwrite(montage, cmap, [fName '.tif'], 'tiff');



% spline for a kana character
baseName = 'kana';
spline(1).x = [0.10 0.03 0.00 0.01 0.05 0.07 0.10 0.20 0.32 0.50 0.69];
spline(1).y = [0.90 0.60 0.44 0.33 0.20 0.39 0.50 0.68 0.73 0.75 0.77];
spline(2).x = [0.47 0.51 0.56 0.57 0.50 0.45];
spline(2).y = [1.00 0.98 0.90 0.40 0.20 0.12];
im(:,:,1) = renderSpline(scaleSpline(spline,c*.2,r*.2,c*.8, r*.8), r, c, thick);
image(im(:,:,1)+1);colormap(cmap);truesize;axis off;

% spline for a hebrew "het"
baseName = 'het';
spline(1).x = [0.05 0.05 0.15];
spline(1).y = [0.20 0.78 0.90];
spline(2).x = [0 0.00 0.10 0.66 0.64 0.60 0.56];
spline(2).y = [1 0.95 0.90 0.90 0.80 0.76 0.20];

im(:,:,1) = renderSpline(scaleSpline(spline,c*.2,r*.2,c*.8, r*.8), r, c, thick);
figure; image(im(:,:,1)+1);colormap(cmap);truesize;axis off;

% perturb spline
curveStdev = .2;
endStdev = 0;
flipudProb = 0;
fliplrProb = 0;
nSamples = 15;

fName = [baseName num2str(curveStdev*100,'%.2d') '_' num2str(endStdev*100,'%.2d')];

for i=2:nSamples+1
   pSpline = perturbSpline(spline, curveStdev, endStdev, flipudProb, fliplrProb);
   im(:,:,i) = renderSpline(scaleSpline(pSpline,c*.2,r*.2,c*.8, r*.8), r, c, thick);
end
%figure;
montage = makeMontage(im(:,:,1:16)+1);
image(montage); colormap(cmap); truesize; axis off;
imwrite(montage, cmap, [fName '.tif'], 'tiff');

