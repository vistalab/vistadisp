function maskImg = makeSplineMask(font, r, c, thick)

splineNum = 0;
clear fontParts;
for(ii=1:length(font))
    for(jj=1:length(font(ii).spline))
        splineNum = splineNum+1;
        fontParts(splineNum) = font(ii).spline(jj);
    end
end
fontParts = repmat(fontParts,1,ceil(1.5*c/r));

fontParts = fontParts(randperm(length(fontParts)));
ry = linspace(-r/2, r/2, length(fontParts));
rx = linspace(-r/2, c+r/2, length(fontParts));
rx = rx(randperm(length(rx)));
ry = rx(randperm(length(rx)));
clear im sp;
for(ii=1:length(fontParts))
    xOff = rx(ii); 
    yOff = ry(ii);
    sp(ii) = scaleSpline(fontParts(ii), r*.15, r*.15, r*.85, r*.85, xOff, yOff);
end
maskImg = renderSpline(sp, r, c, thick);
%figure; imagesc(im); truesize; axis off;

return;