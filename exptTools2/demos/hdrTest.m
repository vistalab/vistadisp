% HDR test

d = loadDisplayParams('hdr1');
d = openScreen(d);


% load led order
load /Applications/MATLAB71/displays/hdr1/ledord.dat -ascii
ledord = ledord(1:759);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Black out LEDs (safety!)
backLightControl = zeros(2,d.numPixels(1));
%backLightControl = round(rand(2,d.numPixels(1))*255);
 
tex = Screen('MakeTexture', d.windowPtr, backLightControl);
srcRect = SetRect(0,0,size(backLightControl,2),size(backLightControl,1));
destRect = srcRect;
Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
Screen('Flip', d.windowPtr);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop over leds

tmp = backLightControl;
maxVal = 150;
for ii=ledord',%(ii=1:length(backLightControl(:)))
    tmp = backLightControl;
    tmp(2,ii+2) = maxVal;
    tex = Screen('MakeTexture', d.windowPtr, tmp);
    Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
    DrawFixation(d);
    Screen('Flip', d.windowPtr);
    pause();
end
tmp = backLightControl+20;
tex = Screen('MakeTexture', d.windowPtr, tmp);
Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
DrawFixation(d);
Screen('Flip', d.windowPtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% random manipulations of leds and foreground

tmp = backLightControl;
nLeds = length(ledord);
tmp(2,ledord(1:round(nLeds/3))'+2) = maxVal;
tex = Screen('MakeTexture', d.windowPtr, tmp);
srcRect = SetRect(0,0,size(backLightControl,2),size(backLightControl,1));
destRect = srcRect;
Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
Screen('Flip', d.windowPtr);

offset = 5;
otherimage = round(rand(1024-1-offset,1280)*255);
tex = Screen('MakeTexture', d.windowPtr, otherimage);
srcRect = SetRect(0,offset,size(otherimage,2),size(otherimage,1));
destRect = srcRect;
Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
Screen('Flip', d.windowPtr);

otherimage = round(rand(1024,1280)*255);
tmp = otherimage;
tmp(2,:) = 0;
tmp(2,ledord(1:round(nLeds/3))'+2) = maxVal;
tex = Screen('MakeTexture', d.windowPtr, tmp);
srcRect = SetRect(0,0,size(tmp,2),size(tmp,1));
destRect = srcRect;
Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
Screen('Flip', d.windowPtr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% show image

mypause = 2;

tmp =imread('~/Desktop/Trash-2006/SharpMeetingVan_hdr copy.bmp','bmp');
%tmp2 = zeros(size(tmp))+255;
%tmp2(2,:) = tmp(2,:);
%tmp= tmp2;
% this one does have info in second line
% and you can make the image non-hdr by setting the following line
%tmp(2,:,:) = 20;
%tmp(2,ledord(1:round(nLeds/3))'+2) = maxVal;
tex = Screen('MakeTexture', d.windowPtr, tmp);
srcRect = SetRect(0,0,size(tmp,2),size(tmp,1));
destRect = srcRect;
Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
Screen('Flip', d.windowPtr);

pause(mypause);

tmp =imread('~/Desktop/Trash-2006/SharpMeetingVan_hdr copy.bmp','bmp');
%tmp2 = zeros(size(tmp))+255;
% tmp2(2,:) = tmp(2,:);
%tmp= tmp2;
% this one does have info in second line
% and you can make the image non-hdr by setting the following line
tmp(2,:,:) = 50;
%tmp(2,ledord(1:round(nLeds/3))'+2) = maxVal;
tex = Screen('MakeTexture', d.windowPtr, tmp);
srcRect = SetRect(0,0,size(tmp,2),size(tmp,1));
destRect = srcRect;
Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
Screen('Flip', d.windowPtr);

pause(mypause);

tmp =imread('~/Desktop/Trash-2006/SharpMeetingVan_hdr copy.bmp','bmp');
tmp2 = zeros(size(tmp))+255;
tmp2(2,:) = tmp(2,:);
tmp= tmp2;
% this one does have info in second line
% and you can make the image non-hdr by setting the following line
%tmp(2,:,:) = 20;
%tmp(2,ledord(1:round(nLeds/3))'+2) = maxVal;
tex = Screen('MakeTexture', d.windowPtr, tmp);
srcRect = SetRect(0,0,size(tmp,2),size(tmp,1));
destRect = srcRect;
Screen('DrawTexture', d.windowPtr, tex, srcRect, destRect);
Screen('Flip', d.windowPtr);




