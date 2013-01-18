function im = fovMakeStims(display, stimParams, stimType)
% im = fovMakeStims(display, stimParams, stimType)
%
% make a stimulus for foveal copy-paste experiment
%

% Do we have targets? Or just ISI?
[targetFlag, nframes] = fovIsTargetPresent(stimParams, stimType);

% Initialize image - make a blank image and an x-y grid in units of pixels
[im x y] = fovInitializeImage(display, nframes);

% Add distractor
im = fovAddDistractor(display, stimParams, im, x, y, nframes);

% If we are in the isi period, we're done. otherwise add the targets.
if ~targetFlag, return; end

% Where do we put the targets?
[targetX targetY] = fovTargetPosition(display, stimParams, stimType); 

% Add targets
im = fovAddTarget(display, stimParams, stimType, im, x, y, targetX, targetY, nframes);

% Done!
return

end


% -------------------------------------------------------------
% /////////////////////////////////////////////////////////////
% -------------------------------------------------------------
function [targetFlag nframes] = fovIsTargetPresent(stimParams, stimType)

switch lower(stimType)
    case {'different' 'same' 'target' 't' 'match' 'm' 'lure' 'l'}
        targetFlag = true;
        nframes = stimParams.targetFrames;
    case {'blank' 'b' 'fix' 'isi'}
        targetFlag = false;
        nframes = stimParams.isiFrames;
end

end



% -------------------------------------------------------------
% /////////////////////////////////////////////////////////////
% -------------------------------------------------------------
function [im x y] = fovInitializeImage(display, nframes)

% size of image
npixels = min(display.numPixels);

% initialize image
im      = zeros(npixels, npixels, nframes, 'uint16') + display.backColorIndex;

% grid values (in pixels - should we do it in deg?)
[x, y]  = meshgrid(-npixels/2:npixels/2-1, -npixels/2:npixels/2-1);

end


% -------------------------------------------------------------
% /////////////////////////////////////////////////////////////
% -------------------------------------------------------------
function im = fovAddDistractor(display, stimParams, im, x, y, nframes)

switch stimParams.distractorPosition
    case 0 % none
        distractor = [];
    case 1 % foveal
        distractorSize = stimParams.distractorSize;
        distractorSize = angle2pix(display, distractorSize);
        distractor = x.^2 + y.^2 < distractorSize^2;
    case 2 % parafoveal
        distractorSize = stimParams.distractorSize;
        outerRadius = angle2pix(display, distractorSize);
        innerRadius = .75 * outerRadius;
        distractor = x.^2 + y.^2 < outerRadius^2 & x.^2 + y.^2 > innerRadius^2;
end

ClockRandSeed;
for ii = 1:nframes
    frame = im(:,:,ii);
    frame(distractor) = Randi(display.maxGammaValue, [1, sum(distractor(:))]);
    im(:,:,ii) = frame;
end

end

% -------------------------------------------------------------
% /////////////////////////////////////////////////////////////
% -------------------------------------------------------------
function [targetX targetY] = fovTargetPosition(display, stimParams, stimType)

switch lower(stimType)
    case {'target', 'match', 't', 'm' 'same'}
        stimulusPosition = stimParams.stimulusPosition1;
    case {'lure', 'l' 'different'}
        stimulusPosition = stimParams.stimulusPosition2;
end

% distance of stimulus center from fovea, in pixels
radius  = angle2pix(display, stimParams.radius);

% angle of stimulus center around fixation
ang     = deg2rad(stimulusPosition);

% make two target positions, 180 deg apart
targetX(1) = round(radius * cos(ang));
targetY(1) = round(radius * sin(ang));

targetX(2) = round(radius * cos(ang+pi));
targetY(2) = round(radius * sin(ang+pi));

end


% -------------------------------------------------------------
% /////////////////////////////////////////////////////////////
% -------------------------------------------------------------
function im = fovAddTarget(display, stimParams, stimType, im, x, y, targetX, targetY, nframes)

% what class of stimuli?
%class = stimParams.shapeClasses{stimParams.shapeClass};
class = stimParams.shapeClass;

% what value? (stimuli are assumed to come from a class that is
% parameterized with a single dimension)
stimVal(1) = stimParams.stimulusValue;

% we show two stimuli at once. what values are both of them? sometimes the
% two values are the same, and sometimes they are different.
switch lower(stimType)
    case {'target', 'match', 't', 'm' 'same'}
        stimVal(2) = stimVal(1);
        if stimParams.matchReferenceOrOffset == 2,
            stimVal = stimVal + stimParams.stimulusOffset * stimParams.offsetDir;
        end
    case {'lure', 'l' 'different'}
        stimVal(2) = stimVal(1) + stimParams.stimulusOffset * stimParams.offsetDir;
end

% build the stimuli using nick's function to make parameterized shapes
stimsize = round(angle2pix(display, stimParams.stimsize));

[~, stim1] = makeShape(stimVal(1), class, stimsize, x, y, targetX(1), targetY(1));
[~, stim2] = makeShape(stimVal(2), class, stimsize, x, y, targetX(2), targetY(2));

% add same stimuli to every frame
for ii = 1:nframes
    frame = im(:,:,ii);
    frame(stim1 | stim2) = display.maxGammaValue;
    im(:,:,ii) = frame;
end


end


% % -------------------------------------------------------------
% % /////////////////////////////////////////////////////////////
% % -------------------------------------------------------------
% function stim = fovAddCircles(x, y, targetX, targetY, stimVal)
% 
%     stim = (x - targetX).^2 + (y - targetY).^2 < stimVal^2;
% 
% end
% 
% % -------------------------------------------------------------
% % /////////////////////////////////////////////////////////////
% % -------------------------------------------------------------
% function stim = fovAddSquares(x, y, targetX, targetY, stimVal)
% 
%     stim = abs(x - targetX) + abs(y - targetY) < stimVal;
% 
% end
