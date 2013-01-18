function stim = boundext_face_croptest(subject, varargin);
% stim = boundext_face_croptest([subject, options]);
%
% Test for face boundary extension by showing subjects faces behind an
% aperture, masking them, then showing the full faces and asking subjects
% to crop the full face to mask the aperture.
%
% ras, 06/04/2009. 
if notDefined('subject'),	subject = '';		end

tic

%% parameters
stim.screenSize = 600; % min screen dimension in pixels
stim.zoomLevels = 1; % [1 .5 .8 2 (1/.8)]; % zooming (>1) / widening (>1) conditions
stim.nFaces = 2; % # indivdual faces to test 
stim.nPositions = 12;  % # bar aperture positions
stim.positionsToTest = [2:2:10]; % which bar positions to actually test...
stim.nRepeatsPerStim = 1; % # trials per each face/mask position
stim.imageDuration = 1; % duration (secs) to display face part
stim.maskDuration = 2;  % duration (secs) of phase-scrambled mask
stim.orientation = 90; % bar orientation: 0 (=vertical) or 90 (=horizontal)
stim.circMask = 1;  % add a circular mask to the images
stim.keepImages = 1; % flag to keep the image matrices in the save files
stim.cmap = gray(256); 
stim.bgColor = 165;
stim.runPriority = 7;

%% parse optional params
for ii = 1:2:length(varargin)
	if isnumeric(varargin{ii+1})
		eval( sprintf('stim.%s = %s', varargin{ii}, num2str(varargin{ii+1})) );
	else
		eval( sprintf('stim.%s = %s', varargin{ii}, varargin{ii+1}) );
	end
end

% task string
if stim.orientation==0
    % vertical crop
    stim.taskStr = {'Crop the full face to match the masked face.' ...
                    'LEFT/RIGHT ARROW: increase/decrease crop width.' ...
                    'UP/DOWN ARROW: move crop center.'};
elseif stim.orientation==90
    stim.taskStr = {'Crop the full face to match the masked face.' ...
                    'LEFT/RIGHT ARROW: move crop center.' ...
                    'UP/DOWN ARROW: increase/decrease crop width.'};
end

%% load the parameters for this display
stim.display = loadDisplayParams(prefsDisplayName);
stim.display.backColorIndex = stim.bgColor;
stim.display.backColorRgb = [stim.bgColor stim.bgColor stim.bgColor 255];

% update the display params to match the actual display settings
res = Screen('Resolution', stim.display.screenNumber);
stim.display.numPixels = [res.width res.height];
stim.display.frameRate = res.hz;
stim.display.bitsPerPixel = res.pixelSize;
stim.display.fixX = round(res.width/2);
stim.display.fixY = round(res.height/2);

%% set up the stimulus
stim = boundext_makeStim(stim);

fprintf('[%s]: load time: %i min %2.1f sec.\n', mfilename, floor(toc/60), ...
		mod(toc, 60));

%% run the stimulus
stim = runStimulus(stim);

%% close up
stim = closeDisplay(stim, subject);

return
% /------------------------------------------------------------/ %



% /------------------------------------------------------------/ %
function stim = boundext_makeStim(stim);
%% create the stimuli for the boundary extension experiment:
% load full faces, mask them, and create phase-scrambled masks
% this is the main subroutine to set up the trial structure for this
% experiment

fprintf('\n\n\n\t***** Making Stimuli. This may take a few minutes. *****\n\n\n');

%% initialize stim struct
stim.fullfaces = {};  % full face images for each size
stim.masks = {}; % phase-scrambled face images
stim.trials = struct('faceBar', [], 'faceID', [], 'position', [], ...
                     'faceBarID', [], 'maskID', [], ...
                     'cropWidth', [], 'cropCenter', [], 'cropRT', []);
stim.trials = stim.trials([]); % make empty

%% load unmasked face images 
fullfaces = loadFaces(zeros(1, stim.nFaces), 'b');

% contrast scale 'em -- leave the last few entries reserved
for jj = 1:length(fullfaces)
    fullfaces{jj} = scaleContrast(fullfaces{jj}, 252/255);
end

% from these large full-face images, create zoomed / panned images based
% on the zoomLevels conditions, and resample to match the display screen
% size:
sz = [stim.screenSize stim.screenSize];
for ii = 1:length(stim.zoomLevels)
   z = stim.zoomLevels(ii);
   if z==1
       % no zooming/panning: just resample to screen size
       for jj = 1:length(fullfaces)
           resizedFaces{jj} = imresize(fullfaces{jj}, sz);
       end
   elseif z > 1
       % zoom in: crop tighter
       fullsize = length(fullfaces{1}); % should be 1301
       cen = round(fullsize / 2);  % center of range
       tmp = floor( (1/2) * (1/z) * fullsize - 1 );
       crop = [-tmp:tmp] + cen;
       
       for jj = 1:length(fullfaces)
           resizedFaces{jj} = fullfaces{jj}(crop,crop);
           resizedFaces{jj} = imresize(resizedFaces{jj}, sz);
       end
       
   elseif z < 1
       % zoom out: make smaller than screen, then center in screen-size
       % image
       for jj = 1:length(fullfaces)
           resizedFaces{jj} = imresize(fullfaces{jj}, z .* sz);
           resizedFaces{jj} = makeScreenSizeImages(resizedFaces{jj}, sz);
       end
   end
   
   stim.fullfaces = [stim.fullfaces resizedFaces];
end

%% phase-scramble face images
stim.masks = phaseScramble(stim.fullfaces);

%% create trials structure (and bar aperture masks)
% first, mark the bar centers for the 'position' field
centers = linspace(0, stim.screenSize, stim.nPositions+2);
centers = round( centers(2:end-1) ); 

% now make the bar apertures:
for ii = 1:length(stim.fullfaces)
    % make the bar images
    % (I use a minus sign, because for left->right horizontal motion, we
    % want the direction to be -90 degrees, rather than +90)
    barImages = barApertureMask(stim.fullfaces{ii}, -stim.orientation, ...
                                stim.nPositions);
                            
    % sub-select only those positions we want to test. 
    % (It would be inefficient, for instance, to test the very edges where
    % there is often no stimulus):
    barImages = barImages(:,:,stim.positionsToTest);
                                
    % create a trial for each bar-aperture image
    for jj = 1:size(barImages, 3)
       stim.trials(end+1).faceBar = barImages(:,:,jj); 
       
       % which face image is this? 
       % (I'll have it point to the original, unscaled face: this way the
       % optimal cropping for different test images is not a constant
       % width.)
       stim.trials(end).faceID = mod(ii-1, stim.nFaces) + 1;
       stim.trials(end).fullFaceID = ii;
       
       % this is an approximate starting point for the center of the bar
       stim.trials(end).position = centers(jj);
    end
end

%% combine the different image fields (fullfaces, masks, and facebars)
%% into a single stim.images field
stim = createImagesField(stim, stim.keepImages);

%% repeat each trial the specified # of times
stim.trials = repmat(stim.trials, [1 stim.nRepeatsPerStim]);

%% shuffle order of trials
stim.trials = shuffle(stim.trials);
stim.nTrials = length(stim.trials);

return
% /------------------------------------------------------------/ %



% /------------------------------------------------------------/
function stim = createImagesField(stim, keepOldFields);
%% specific to the boundary-extension experiment:
%% given different types of images (the full-face images at various levels
%% of zoom, the phase-scrambled face masks, and the faces behind different
%% bar apertures), we want to create a single stim.images field. This field
%% will be used to work with the rest of the code (like 'createTextures')
%% in a consistent way as other stimulus code. To make it easy for creaing
%% the stimuli, I initially kept them in separate places. Here, I put them
%% together, and index where each type of image is kept in the single
%% stim.images field.
%%
%% If keepOldFields is 1, I keep the previous images in their old locations
%% as well. That way, even though the images field is cleared by the
%% 'createTextures' command, we still have the original images. This will
%% make the saved results files much larger. If keepOldFields is 0, we
%% strip the old fields once we create stim.images, and the image
%% information will no longer be retained.
stim.images = [];

N = length(stim.fullfaces);

% we start with the full (no bar aperture) face images
for ii = 1:N
    stim.images(:,:,ii) = stim.fullfaces{ii};
end

% next we concatenate the phase-scrambled mask images.
% in the trials field, we mark the index of the mask corresponding to each
% face.
faceIDs = [stim.trials.faceID];
for ii = 1:N
    stim.images(:,:,ii+N) = stim.masks{ii};
    for jj = find(faceIDs==ii)
        stim.trials(jj).maskID = ii + N;
    end
end

% add the bar-aperture masked face images
for ii = 1:length(stim.trials)
    stim.images(:,:,ii+2*N) = stim.trials(ii).faceBar;
    stim.trials(ii).faceBarID = ii + 2*N;
end

% finally, add a blank screen image at the end
stim.images(:,:,end+1) = repmat(stim.bgColor, stim.screenSize);

% remove the old fields if requested
if keepOldFields==0
    stim.fullfaces = {};
    stim.masks = {};
    stim.trials = rmfield(stim.trials, 'faceBar');
end
    
return
% /----------------------------------------------------------------/ %




% /----------------------------------------------------------------/ %
function images = makeScreenSizeImages(srcImages, screenSize, bg);
%% given a set of images which may be larger than a given screen size, 
%% return a set of images the same size as the screen, with the images
%% centered within it. The rest of the image will be padded with the
%% background value bg (takes corner pixel of 1st image as default). 
if notDefined('bg'), bg = srcImages(1); end

screenX = screenSize(1);
screenY = screenSize(2);

sz = size(srcImages);  sz(3) = size(srcImages, 3);  % force 3rd dim
if sz(1) > screenY | sz(2) > screenX
	warning('images are already larger than the screen!');
	return
end

images = repmat(bg, [screenY screenX sz(3)]);
rows = ceil( [1:sz(1)] + screenY/2 - sz(1)/2 );
cols = ceil( [1:sz(2)] + screenX/2 - sz(1)/2 );
for n = 1:sz(3)
	images(rows,cols,n) = uint8(srcImages(:,:,n));
end

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function stim = runStimulus(stim);
%% run the boundary extension stimulus, collecting user responses.
% This code is based off code in doRetinotopyScan.
% ras, 07/2008.

edit % get MATLAB out of the command window...

% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that 
% the ones we are using are loaded.
KbCheck; GetSecs; WaitSecs(0.001);

% first, try to get devices (we can proceed if this doesn't work)
try
    stim.display.devices        = getDevices;
catch
    disp('Couldn''t find devices: won''t be able to get keyboard input.')
    stim.display.devices = [];
end

try,
    % check for OpenGL
    AssertOpenGL;
    
    % to skip annoying warning message on display (but not terminal)
    Screen('Preference','SkipSyncTests', 1);
    
    % Open the screen
    stim.display = openScreen(stim.display);

    % to allow blending
    Screen('BlendFunction', stim.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Store the images in textures
    stim = createTextures(stim.display, stim, 1);

    % set priority
    Priority(stim.runPriority);
    
    % wait for go signal
    pressKey2Begin(stim.display, [], [], stim.taskStr);
    
    % put up a blank screen
    Screen('DrawTexture', stim.display.windowPtr, stim.textures(end), stim.srcRect, stim.destRect);
    Screen('Flip', stim.display.windowPtr);
    
    %% go
    time0 = GetSecs;
    for trial = 1:stim.nTrials
        [stim quitFlag] = runCropTrial(stim, trial);
        
        if quitFlag==1
            break;
        end
    end
    
    % reset priority
    Priority(0);
    
    % report timing
    fprintf('Done. Total stimulus duration: %i min %2.1f sec. \n', ...
        floor((getSecs-time0)/60), mod((getSecs-time0), 60));
        
    % Close the one on-screen and many off-screen windows
    closeScreen(stim.display);
    
catch,
    % clean up if error occurred
    Screen('CloseAll');
    setGamma(0);
    Priority(0);
    ShowCursor;
    rethrow(lasterror);	
    
end;

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function [stim quitFlag] = runCropTrial(stim, trial);
% run a single trial: show the masked image, show a phase-scrambled mask,
% then prompt the user to crop the image.

%% params for this scan
faceTexture = stim.textures( stim.trials(trial).faceBarID );
maskTexture = stim.textures( stim.trials(trial).maskID );
fullFaceTexture = stim.textures( stim.trials(trial).faceID );
win = stim.display.windowPtr;
done = [KbName('Return') KbName('Escape')];
X = stim.display.numPixels(1);
Y = stim.display.numPixels(2);

if stim.orientation==0
   % vertical: up/down keys move the crop center;
   % left/right decreases/increases crop size.
   lessCrop = KbName('leftArrow');
   moreCrop = KbName('rightArrow');
   decreaseCen = KbName('downArrow');
   increaseCen = KbName('upArrow');
   
elseif stim.orientation==90
   % horizonal: left/right keys move the crop center;
   % up/down keys increase/decrease the crop size.
   decreaseCen = KbName('leftArrow');
   increaseCen = KbName('rightArrow');
   lessCrop = KbName('upArrow');
   moreCrop = KbName('downArrow');
    
else
    error('Invalid orientation flag.')
end

%% give the subject a second of blank time to prepare
Screen('DrawTexture', stim.display.windowPtr, stim.textures(end), stim.srcRect, stim.destRect);
Screen('Flip', win);

waitTime = 0; t0 = GetSecs;
while waitTime < 1
    waitTime = (GetSecs-t0);
end


%% put up the bar-aperture face image
Screen('DrawTexture', win, faceTexture, stim.srcRect, stim.destRect);
Screen('Flip', win);

waitTime = 0; t0 = GetSecs;
while waitTime < stim.imageDuration
    waitTime = (GetSecs-t0);
end

%% put up the mask
Screen('DrawTexture', win, maskTexture, stim.srcRect, stim.destRect);
Screen('Flip', win);

waitTime = 0; t0 = getSecs;
while waitTime < stim.maskDuration
    waitTime = (GetSecs-t0);
end

%% put up the full face image
Screen('DrawTexture', win, fullFaceTexture, stim.srcRect, stim.destRect);
Screen('Flip', win);


%% get the user crop input
% initialize the crop center and width
w = 100; cen = stim.trials(trial).position;
if stim.orientation==90
    % X axis: adjust for the aspect ratio of the display
    % (the X direction will be lager than the stim size)
    cen = cen + (stim.display.numPixels(1) - stim.screenSize)/2;
    cen = round(cen);
end
% cen = cen + round(20*rand - 10); % jitter the start position

drawCrop(win, fullFaceTexture, cen, w, stim.orientation, X, Y);
t0 = GetSecs;

% user input loop: keep checking the keyboard for keypresses.
% if it's an arrow key, adjust the crop accordingly and redraw the crop. If
% it's a 'finished' key (RETURN or ESC), stop the loop.
[keyIsDown secs keycode] = KbCheck;
while all( keycode(done)==0 )
    [keyIsDown secs keycode] = KbCheck;
    
    
    if keyIsDown
        if keycode(moreCrop)==1,  w = w + 1; end
        if keycode(lessCrop)==1,  w = w - 1; end
        if keycode(increaseCen)==1,  cen = cen + 1; end
        if keycode(decreaseCen)==1,  cen = cen - 1; end
        
        drawCrop(win, fullFaceTexture, cen, w, stim.orientation, X, Y);
    end
end

% did the user give the escape command?
if keycode(done(end))==1
    quitFlag = 1;
else
    quitFlag = 0;
end
    
% mark the final response
stim.trials(trial).cropWidth = w;
stim.trials(trial).cropCenter = cen;
stim.trials(trial).cropRT = 1000 * (GetSecs - t0);
return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function drawCrop(win, texture, cen, w, ori, X, Y);
% draw crop lines given the current state of the crop.
Screen('DrawTexture', win, texture);

if ori==0
    % vertical crop: draw horizontal crop lines
    Screen('DrawLine', win, 255, 0, cen-w, Y, cen-w, 2);
    Screen('DrawLine', win, 255, 0, cen+w, Y, cen+w, 2);
elseif ori==90
    % horizontal crop: draw vertical crop lines
    Screen('DrawLine', win, 255, cen-w, 0, cen-w, X, 2);
    Screen('DrawLine', win, 255, cen+w, 0, cen+w, X, 2);
end

Screen('Flip', win);

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function stim = closeDisplay(stim, subj);
%% close the PsychToolbox display and finish up
closeScreen(stim.display);
Screen('CloseAll');
setGamma(0);
Priority(0);
ShowCursor;

if ~isempty(subj)
	%% save the performance data
	condition = [mfilename '_' getToday];

	colorDir = fileparts( which(mfilename) );  % same directory as this code
	dataDir = fullfile(colorDir, 'Data');
	ensureDirExists(dataDir);
	
	fullFileName = fullfile(dataDir, [subj '_' condition '.mat']);
	if exist(fullFileName,'file')
		load(fullFileName);
		fullRecord(end+1) = stim;
	else
		fullRecord = stim;
	end
	
	save(fullFileName, 'fullRecord');
	fprintf('Saved scan parameters / subject performance in %s.\n', fullFileName);
end

return

