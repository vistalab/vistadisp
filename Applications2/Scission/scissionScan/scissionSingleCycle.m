function [im,misc]  = scissionSingleCycle(stimulus, display, showProgressFlag)


if nargin == 3, showProgess = showProgressFlag; else showProgess = false; end

frameUpdateFrequency = stimulus.frameUpdateFrequency;
SizeRatio = stimulus.SizeRatio / 2;

CDotCont  = stimulus.CentralDotsContrast;
CFiltElip = stimulus.CentralFilterEliplisity;
CFiltSize = stimulus.CentralFilterSize;
CFiltType = stimulus.CentralFilterType;

SDotCont  = stimulus.SurroundDotsContrast;
SFiltElip = stimulus.SurroundFilterEliplisity;
SFiltSize = stimulus.SurroundFilterSize;
SFiltType = stimulus.SurroundFilterType;


%% From cocSingleFrame & Multipleframe

numImages = round(1/(stimulus.frequency * stimulus.stimframe));
stimsize  = stimulus.radius;
m         = round(angle2pix(display, stimsize)*2); %(width in pixels)
n         = round(angle2pix(display, stimsize)*2); %*2; %(height in pixels)
% for test 
% m = 300; n = m; 

CenterX = m/2; CenterY = n/2;
[screenx, screeny] = meshgrid(1:m, 1:n);


% numImages = 30;
% [x,y]  = meshgrid(linspace(-stimsize,stimsize,n),linspace(stimsize,-stimsize,m));
% to get xy coordinate corresponded with visual angle
% minCmapVal = min([display.stimRgbRange]);
% maxCmapVal = max([display.stimRgbRange]);

if showProgess,
    fprintf('[%s]:Creating %d images:',mfilename,numImages); end

im = zeros(m,n,numImages,'uint8');
im1frame = zeros(m, n,'uint8');

startphase = 0;

%% make spatial Filter
    switch lower (stimulus.type)
        case {'filtersizechange'}
            stimulus.Filtering = true;
            if stimulus.CfiltOn == 1

                CFiltSize = CFiltSize * stimulus.HowManyTimesFiltSize;        
                tFilter   = fspecial(CFiltType, [round(m) round(n/CFiltElip)], CFiltSize);
                tFilter   = imresize(tFilter, [m n]);

            else
                tFilter   = fspecial(CFiltType, [round(m) round(n/CFiltElip)], CFiltSize);
                tFilter   = imresize(tFilter, [m n]);
            end

            if stimulus.SfiltOn == 1

                SFiltSize = SFiltSize * stimulus.HowManyTimesFiltSize;
                sFilter   = fspecial(SFiltType, [m round(n/SFiltElip)], SFiltSize);
                sFilter   = imresize(sFilter, [m n]);
            else
                sFilter =   fspecial(SFiltType, [m round(n/SFiltElip)], SFiltSize);
                sFilter   = imresize(sFilter, [m n]);
            end

        case{'surroundrotation','centsurroundrotation'}
            stimulus.Filtering = true;

            tFilter =   fspecial(CFiltType, [m round(n/CFiltElip)], CFiltSize);
            tFilter =   imresize(tFilter, [m n]);

            sFilter =   fspecial(SFiltType, [m round(n/SFiltElip)], SFiltSize);
            sFilter =   imresize(sFilter, [m n]);
        
        otherwise          
            if stimulus.Filtering == true;
            
                tFilter =   fspecial(CFiltType, [m round(n/CFiltElip)], CFiltSize);
            tFilter =   imresize(tFilter, [m n]);

            sFilter =   fspecial(SFiltType, [m round(n/SFiltElip)], SFiltSize);
            sFilter =   imresize(sFilter, [m n]);
            
            end

    end

%% rotate spatial filter

switch lower(stimulus.type)
    case {'surroundrotation'}
        
        sFilter =   imrotate(sFilter, stimulus.RotDeg);
        tmp = size(sFilter);

        if tmp(1) ~= m,
            CenterPointSurroudFiltter = round(tmp ./ 2);
            StartXYtoCrop = CenterPointSurroudFiltter - (m ./2);
            a = StartXYtoCrop(1); b = StartXYtoCrop(1) + m; c = StartXYtoCrop(2); d = StartXYtoCrop(2) + n;
            sFilter = sFilter(a:b, c:d); 
            sFilter = imresize(sFilter, [m n]);
        end

    case {'centsurroundrotation'}
               
        sFilter = imrotate(sFilter, stimulus.RotDeg);
        tmp     = size(sFilter);
    
        if tmp(1) ~= m,
            CenterPointSurroudFiltter = round(tmp ./ 2);
            StartXYtoCrop = CenterPointSurroudFiltter - (m ./2);
            a = StartXYtoCrop(1); b = StartXYtoCrop(1) + m; c = StartXYtoCrop(2); d = StartXYtoCrop(2) + n;
 
            sFilter = sFilter(a:b, c:d); 
            sFilter = imresize(sFilter, [m n]);
        end

        tFilter = imrotate(tFilter, -stimulus.RotDeg); 
        tmp     = size(tFilter);

        if tmp(1) ~= m,
            CenterPointSurroudFiltter = round(tmp ./ 2);
            StartXYtoCrop = CenterPointSurroudFiltter - (m ./2);
            a = StartXYtoCrop(1); b = StartXYtoCrop(1) + m; c = StartXYtoCrop(2); d = StartXYtoCrop(2) + n;
            
            tFilter = tFilter(a:b, c:d); 
            tFilter = imresize(tFilter, [m n]);
        end
        
    otherwise
        
end 

%% make single cycle stimulus

    targetRadius = round(m * SizeRatio);       

    %   disparity = -.05 * m;
%   stereoFlag = false;
%     shapeList = {'circle', 'square', 'circularAnnulus', 'squareAnnulus'}';
%     shape = shapeList{1};
%     if shape == 'circle'

textureImage = zeros(size(im1frame,1),size(im1frame,2), numImages);

% frameUpdateFrequency = 20;

    for imgNum = 1:frameUpdateFrequency:numImages
        textureImage(:,:,imgNum) =rand(size(im1frame));
        
        for ii = 1:frameUpdateFrequency-1
            textureImage(:,:,imgNum+ii) =textureImage(:,:,imgNum);
        end
        
    end
    
    for imgNum = 1:numImages

        %define the phase of the current frame
        ph = 2*pi*imgNum/numImages + startphase;
        
        tMean = .5;%+ sin(ph) /8;
        tContrast = CDotCont ;
        sMean = .5- sin(ph) /4;
        sContrast = SDotCont;% + sin(ph) /2;
        
        targetRange = tMean + [-tContrast tContrast]/2;
        surroundRange = sMean + [-sContrast sContrast]/2;

        %define the target and surround masks (1 where present, 0 where absent)
        targetMask = sqrt((screenx - CenterX).^2 + (screeny - CenterY).^2) < targetRadius;    
        surroundMask = 1 - targetMask;

%         targetStereoMask = sqrt(((screenx - CenterX) - disparity).^2 + (screeny - CenterY).^2) < targetRadius;
%         surroundStereoMask = 1 - targetStereoMask;

        %define the target and surround intensities
        
        switch lower(stimulus.NoiseType)
            case {'normalize'}
                if stimulus.CViolation == true;
                    RandomImage         = randn(size(im1frame));
                    targetIntensities   = RandomImage * diff(targetRange)   + min(targetRange);
                    surroundIntensities = RandomImage * diff(surroundRange) + min(surroundRange);
                else  
                    targetIntensities   = randn(size(im1frame)) * diff(targetRange)   + min(targetRange);
                    surroundIntensities = randn(size(im1frame)) * diff(surroundRange) + min(surroundRange);
                end
            case {'uniform'}
                if stimulus.CViolation == true;
                    %RandomImage         = rand(size(im1frame));
                    RandomImage         = textureImage(:,:,imgNum);
                    targetIntensities   = RandomImage * diff(targetRange)   + min(targetRange);
                    surroundIntensities = RandomImage * diff(surroundRange) + min(surroundRange);
                else    
                    targetIntensities   = rand(size(im1frame)) * diff(targetRange)   + min(targetRange);
                    surroundIntensities = rand(size(im1frame)) * diff(surroundRange) + min(surroundRange);
                end
        end 

        %filter the images
        if stimulus.Filtering == true
            targetIntensities = ifft2(fft2(targetIntensities).* fft2(tFilter) );
            surroundIntensities = ifft2(fft2(surroundIntensities).* fft2(sFilter) );
        end
        % scale the image intensities
         targetIntensities = (targetIntensities - min(targetIntensities(:))) ./ (max(targetIntensities(:)) - min(targetIntensities(:)))...
        * (max(targetRange) - min(targetRange)) + min(targetRange);
        surroundIntensities = (surroundIntensities - min(surroundIntensities(:))) ./ (max(surroundIntensities(:)) - min(surroundIntensities(:)))...
        * (max(surroundRange) - min(surroundRange)) + min(surroundRange);
        % combine target and surround masks and intensities
        target = targetMask .* targetIntensities;
        surround = surroundMask .* surroundIntensities;
        
        % targetStereo = targetStereoMask .* targetIntensities;
        % surroundStereo = surroundStereoMask .* surroundIntensities;

        im1frame = target+surround;
        im1frame  = round(im1frame  * 254 + 1);
        
        % stereo 
        % im1frameStereo = targetStereo + surroundStereo;
        % im1frameStereo = round(im1frameStereo  * 254 + 1);
        im(:,:,imgNum) = im1frame;
% 
%            %convert the image into a movie frame
%             if stereoFlag,
%                 im(:,:,imgNum) = im2frame([im1frame imStereo],gray); 
%             else
%                 im(:,:,imgNum) = im1frame;
%             end
%             
            if showProgess,  fprintf('.');drawnow; end
            
     end 

% mean luminance

if showProgess,  fprintf('Done.\n');drawnow; end

misc.targetMask = targetMask; misc.m = m; misc.n = n; misc.targetRadius = targetRadius;

return 