function [im]  = scissionSingleCycle(stimulus, display)

%% From cocSingleFrame & Multipleframe


numImages = round(1/(stimulus.frequency * stimulus.stimframe));
stimsize  = stimulus.radius;
m         = angle2pix(display,stimsize)*2; %(width in pixels)
n         = angle2pix(display,stimsize)*2; %*2; %(height in pixels)
% test 
 m = 600; n = m;

CenterX = m/2; CenterY = n/2;

[screenx, screeny] = meshgrid(1:m, 1:n);
% [x,y]  = meshgrid(linspace(-stimsize,stimsize,n),linspace(stimsize,-stimsize,m));
% to get xy coordinate corresponded with visual angle
minCmapVal = min([display.stimRgbRange]);
maxCmapVal = max([display.stimRgbRange]);

if nargin == 3, showProgess = showProgressFlag; else showProgess = false; end

if showProgess,
    fprintf('[%s]:Creating %d images:',mfilename,numImages); end

im = zeros(m,n,numImages+1,'uint8');
im1frame = zeros(m, n,'uint8');
startphase = 0;


%% make single cycle stimulus
    targetRadius = round(m * .3);       
    disparity = -.05 * m;
    shapeList = {'circle', 'square', 'circularAnnulus', 'squareAnnulus'}';
    shape = shapeList{1};
    stereoFlag = false;
    
    for imgNum = 1:numImages
        t = 2*pi*imgNum/numImages;
        targetRange = [0 1];% - sin(ph) /4;
        surroundRange = [0.25 .75] + sin(t) /4 ;

        %define the target and surround masks (1 where present, 0 where absent)
        targetMask = sqrt((screenx - CenterX).^2 + (screeny - CenterY).^2) < targetRadius;    
        surroundMask = 1 - targetMask;

        targetStereoMask = sqrt(((screenx - CenterX) - disparity).^2 + (screeny - CenterY).^2) < targetRadius;
        surroundStereoMask = 1 - targetStereoMask;

        %define the target and surround intensities
        targetIntensities = rand(size(im1frame)) * diff(targetRange)  + min(targetRange);
        surroundIntensities = rand(size(im1frame)) * diff(surroundRange) + min(surroundRange);

        %combine target and surround masks and intensities
        target = targetMask .* targetIntensities;
        surround = surroundMask .* surroundIntensities;
        targetStereo = targetStereoMask .* targetIntensities;
        surroundStereo = surroundStereoMask .* surroundIntensities;

        im1frame = target+surround;
        im1frame  = round(im1frame  * 254 + 1);

        im1frameStereo = targetStereo + surroundStereo;
        im1frameaStereo = round(im1frameStereo  * 254 + 1);

           %convert the image into a movie frame
            if stereoFlag,
                im(:,:,imgNum) = im2frame([im1frame imStereo],gray); 
            else
                im(:,:,imgNum) = im1frame;
            end
            
        end 

%     tmp = y;%; .* mask;
%     images(:,:,imgNum) = minCmapVal+ceil((maxCmapVal-minCmapVal) .* (tmp+1)./2);
     if showProgess,  fprintf('.');drawnow; end


% mean luminance
 im(:,:,end) = im(:,:,end).*0+minCmapVal+ceil((maxCmapVal-minCmapVal)./2);
if showProgess,  fprintf('Done.\n');drawnow; end

return 