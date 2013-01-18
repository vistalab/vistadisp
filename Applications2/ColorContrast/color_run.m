function stim = color_run(A, B, subj, cA, cB, varargin);
%
%   stim = color_run(typeA, typeB, [subj], [contrastA], [contrastB], [options]);
%
% Run an AB block-alternating color contrast stimulus, returning a structure 
% with stimulus and user behavioral data.
%
% typeA and typeB can each be one of the following:
%
%   'S', 's', [0 0 1]: S-cone isolating contrast stimulus.
%
%   'L-M', 'l-m', [1 -1 0]: L-M-cone isolating contrast stimulus.
%
%   'L+M', 'l+m', [1 1 0]: L+M-cone isolating (luminance) contrast stimulus.
%
%   'L+M+S', 'l+m+s', [1 1 1]: L+M+S-cone stimulating luminance stimulus.
%
%   'blank', [0 0 0]: blank fixation block.
%   
% contrastA and contrastB specify the specific contrast levels for each
% contrast in A and B. If omitted, they default to reasonable
% empirically-determined levels based on the contrast type. The defaults
% are: 
%   'S': 10^(-0.3) -- ~50% contrast;
%   'L-M': 10^(-1.5) -- ~3% contrast; 
%   'L+M': 10^(-0.6) -- 25% contrast; 
%   'L+M+S': 10^(-1.05) -- ~8% contrast; 
%   'blank': 0 (thought it doesn't really matter for blank); 
%
% subj: if a nonempty string is provided, will save behavioral data in a
% file marked:
%		[subject]_tf_run_[date].mat
%
% This file will be saved in the Data/ subfolder relative to where this
% m-file is located (e.g., VISTADISP/Applications2/ColorContrast/Data). 
% * PLEASE DO NOT CHECK IN DATA FILES TO CVS *. 
%
% ras, 07/08/2008.
% ras, 08/13/2008: added ability to center stimulus at different corners of
% the screen (to get greater eccentricity); set eccDegrees='max' to figure
% out largest stim size for the display.
if nargin<2, error('Need to specify stimulus contrast types.');     end
if notDefined('subj'),  subj = '';                                  end
if notDefined('cA'),    cA = [];                                    end
if notDefined('cB'),    cB = [];                                    end

%% parse inputs
[A cA] = inputCheck(A, cA);
[B cB] = inputCheck(B, cB);

%% default parameters
stim.displayName = prefsDisplayName;  % external function -- checks/sets pref variable
stim.fixationPos = 1;		% 0=screen center; 1-4 = 4 corners of the screen
stim.eccDegrees = 'max';	% maximal eccentricity (radius from fovea) subtended by stimulus
stim.nSpatialCycles = 3; 	% spatial frequency in Hz
stim.fixationRad = 1;		% inner radius of disk in pixels
stim.nCycles = 7;			% # of temporal cycles
stim.secsPerBlock = 12;		% 2 blocks / cycle: A and B
stim.nContrastImgs = 20;	% # stimulus images per contrast reversal
stim.nCmap = 63;			% # colors in color map for each block (must be <127)
stim.runPriority = 7; 
stim.startScan = 3;			% seconds coundown at which to trigger the scanner
stim.nRunRepeats = 1;           % # times to repeat the run

% temporal frequency of contrast reversals in Hz ([A B])
stim.temporalFrequencyHz = 1.5; 

% seconds per 'trial', including blank periods b/w reversals (try to match
% TR when scanning)
stim.secsPerTrial = 2.4;
stim.secsBlank = 0.4;  % seconds of each trial to leave blank

% fixation task-related parameters
stim.fixationType = 'color task';
stim.fixationTaskDifficulty = 3; % relevant for 'simon task' or 'color task'
stim.speak = 0;

% record what conditions we're running
stim.conditionA = {A cA};	
stim.conditionB = {B cB};

%% parse options
for ii = 1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case 'displayName', stim.displayName = varargin{ii+1};
            case 'stimsizedegrees', stim.stimSizeDegrees = varargin{ii+1};
            case 'ncycles', stim.nCycles = varargin{ii+1};
			case {'ncmap' 'ncolors'}, stim.nColors = varargin{ii+1};
            case {'secsperblock' 'blockdur'}, stim.secsPerBlock = varargin{ii+1};
            case 'nspatialcycles', stim.nSpatialCycles =  varargin{ii+1};
            case 'nrunrepeates', stim.nRunRepeats = varargin{ii+1};
			case {'ncontrastimgs' 'nimages'}, stim.nContrastImgs = varargin{ii+1};
            case {'tf' 'temporalfrequency' 'temporalfrequencyhz'}, 
                stim.temporalFrequencyHz = varargin{ii+1};
			case {'fixationtype' 'fixationtask'}, 
				stim.fixationType = varargin{ii+1};
			case {'fixpos' 'fixationpos'}
				stim.fixationPos = varargin{ii+1};
		end
    end
end


%% load the display parameters
stim.display = loadDisplayParams(stim.displayName);
stim.display.backColorIndex = round(stim.nCmap/2);
stmi.display.backColorRGB = [.5 .5 .5];

% update the display params to match the actual display settings
rect = Screen('Rect', stim.display.screenNumber);
stim.display.numPixels = [rect(3) rect(4)];
stim.display.frameRate = Screen('FrameRate', stim.display.screenNumber);
stim.display.bitsPerPixel = Screen('PixelSize', stim.display.screenNumber);


%% make the images and color maps for each block
% convert image size from desired visual degrees -> pixels (and radius ->
% diameter)
if isequal( lower(stim.eccDegrees), 'max' )
	if stim.fixationPos==0
		stim.imSizePixels = repmat( min(stim.display.numPixels), [1 2] );
	else
		% for corner fixation, fill the screen
		stim.imSizePixels = fliplr(stim.display.numPixels);
	end
	
	% compute the visual angle this represents, and report it
	imSizeDegrees = pix2angle(stim.display, stim.imSizePixels);
	fprintf(['[%s]: Estimated stimulus size %2.1f by %2.1f degrees ' ...
			 '(%i by %i pixels).\n'], mfilename, imSizeDegrees(1), ...
			 imSizeDegrees(2), stim.imSizePixels(1), stim.imSizePixels(2));
else
	stim.imSizePixels = repmat(2 * angle2pix(stim.display, stim.eccDegrees), [1 2]);
end

fprintf('[%s]: Creating images....', mfilename);

% create cosine- and sine-phase images for block A
[imagesA cmapA] = colorContrastImages(A, stim.display, 'contrast', cA, ...
									'fixationPos', stim.fixationPos, ...
                                    'nCmap', stim.nCmap, ...
                                    'nCycles', stim.nSpatialCycles, ...
                                    'nImages', stim.nContrastImgs, ...
									'fixationRad', stim.fixationRad, ...
                                    'sz', stim.imSizePixels);
imagesA2 = colorContrastImages(A, stim.display, 'contrast', cA, ...
									'fixationPos', stim.fixationPos, ...
									'PhaseOffset', pi/2, ...
                                    'nCmap', stim.nCmap, ...
                                    'nCycles', stim.nSpatialCycles, ...
                                    'nImages', stim.nContrastImgs, ...
									'fixationRad', stim.fixationRad, ...
                                    'sz', stim.imSizePixels);

% create cosine- and sine-phase images for block B								
[imagesB cmapB] = colorContrastImages(B, stim.display, 'contrast', cB, ...
									'fixationPos', stim.fixationPos, ...
									'nCmap', stim.nCmap, ...
                                    'nCycles', stim.nSpatialCycles, ...
                                    'nImages', stim.nContrastImgs, ...
									'fixationRad', stim.fixationRad, ...
									'sz', stim.imSizePixels);
imagesB2 = colorContrastImages(B, stim.display, 'contrast', cB, ...
									'fixationPos', stim.fixationPos, ...
									'PhaseOffset', pi/2, ...
                                    'nCmap', stim.nCmap, ...
                                    'nCycles', stim.nSpatialCycles, ...
                                    'nImages', stim.nContrastImgs, ...
									'fixationRad', stim.fixationRad, ...
									'sz', stim.imSizePixels);
fprintf('done.\n');

%% combine the blocks, create a stimulus sequence
% (1) making the cmap -- we reserve several colors:
% color 0 (1st row) is gray  (we use the LMS-calibrated gray given in the last cmap
%							  row provided by colorContrastImages);
% colors 246-255 (last 10 rows) are for the fixation task;
% we plug in the cmap for block A in rows 2-(nCmap+1);
% we plug in the cmap for block B in rows (nCmap+2)-(2*nCmap+1).
N = stim.nCmap + 1; % extra row is the background color (calibrated gray)
stim.cmap = repmat( cmapA(ceil(stim.nCmap/2),:), [256 1] );
stim.cmap(2:N+1,:) = cmapA;
stim.cmap(N+2:2*N+1,:) = cmapB;
stim.cmap(255,:) = [1 0 0];   % red fixation color
stim.cmap(256,:) = [1 1 1];	  % white fixation color

% (2) combine the images -- because of the way we combined color maps
% above, the cmap index values in each image need to be offset by the
% appropriate amount (there are +1 and -1 offsets hich cancel out):
stim.images = cat(3, imagesA, imagesB+N, imagesA2, imagesB2+N);

% make the images fill the screen: I can't seem to do this using standard
% methods, like setting stim.display.backColorIndex or backColorRGB.
if stim.fixationPos==0
	stim.images = makeScreenSizeImages(stim.images, stim.display.numPixels);
end

% (3) making the sequence 
% NOTE: where the older version of the code cycled through
% cmaps to achieve the desired effect, here we actually cycle through
% images, always using the one combined cmap. This is a little easier to
% interpret; for instance, you can run 'displayVol(images, 1, cmap);' to see
% the stimuli outside PsychToolbox.
seqA = buildBlockSequence(stim, 1:stim.nContrastImgs);
seqB = buildBlockSequence(stim, stim.nContrastImgs+1:2*stim.nContrastImgs);
singleCycle = [seqA seqB];

stim.seq = repmat(singleCycle, [1 stim.nCycles]);
stim.seq(1) = -1;  % set the color map

imagePeriod = 1 / (stim.temporalFrequencyHz * stim.nContrastImgs);
stim.seqtiming = [0:length(stim.seq)-1] .* imagePeriod;

stim.fixSeq = ones(size(stim.seq));  % dummy placeholder

								
% (4) add fixation point, task sequence to images
stim = setFixation(stim);


%% run the stimulus
 stim = runStimulus(stim);


%% close up
stim = closeDisplay(stim, subj);

return
% /----------------------------------------------------------------/ %




% /----------------------------------------------------------------/ %
function [type contrast] = inputCheck(type, contrast);
%% checks that a valid contrast type is specified, and assigns a default
%% contrast level baed on the type if it's not specified. Always returns
%% the type as a string.
if isnumeric(type)
    switch type
        case [0 0 1], type = 'S';
        case [1 -1 0], type = 'L-M';
        case [1 1 0], type = 'L+M';
        case [1 1 1], type = 'L+M+S';
        case [0 0 0], type = 'blank';
        otherwise, error('Invalid contrast type.');
    end
end

if isempty(contrast)
    switch lower(type)
        case 's', contrast = 10^(-0.3);         
        case 'l+m', contrast = 10^(-0.6);       
        case 'l-m', contrast = 10^(-1.5);      
        case 'l+m+s', contrast = 10^(-1.05);    
        case 'blank', contrast = 0;             
        otherwise, error('Invalid contrast type.');
    end
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

sz = size(srcImages);
if sz(1) > screenY | sz(2) > screenX
	warning('images are already larger than the screen!');
	return
end

images = repmat(bg, [screenY screenX sz(3)]);
rows = ceil( [1:sz(1)] + screenY/2 - sz(1)/2 );
cols = ceil( [1:sz(2)] + screenX/2 - sz(1)/2 );
for n = 1:sz(3)
	images(rows,cols,n) = srcImages(:,:,n);
end

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function seq = buildBlockSequence(stim, rng);
% Build a sequence of image indices corresponding to one block.
% This sequence will depend on the parameters set for the stimulus,
% including the temporal frequency of the contrast reversals, and the number of
% image frames used to represent one cycle.
reversalsPerBlock = stim.temporalFrequencyHz * stim.secsPerBlock;
seq = repmat(rng, [1 reversalsPerBlock]);

%% break block into 'trials' with blank periods
nTrials = stim.secsPerBlock / stim.secsPerTrial;
secsBlank = .4; % seconds of blank duration
framesPerSec = length(seq) / stim.secsPerBlock;  % image frames / block -- NOT screen refresh
framesPerBlank = framesPerSec * secsBlank;

% get first index of each of the blank periods: first break the block
% sequence into (nBlocks+1) bins, then count backwards from the end of each
% bin:
startIndex = round( linspace(1, length(seq), nTrials+1) );
startIndex = startIndex(2:end) - framesPerBlank + 1;

offset = meshgrid(1:framesPerBlank, 1:length(startIndex));
blankIndices = repmat(startIndex(:), [1 framesPerBlank]) + offset;
blankIndices = blankIndices(:);

seq(blankIndices) = stim.nContrastImgs + 1;  % index to blank screen 

%% randomly jitter trials between sine and cosine spatial grating phase
% by default, the indices in seq point to the cosine phase images. Choose a
% random subset of trials, and change their indices to point to the
% sine-phase gratings.
sineOffset = 2 * stim.nContrastImgs; % index offset to point to sine images
trialFrames = framesPerSec * stim.secsPerTrial;

whichTrials = find( round( rand(1, nTrials) ) );

for t = whichTrials
	rng = ((t-1) * trialFrames + 1):(t*trialFrames - framesPerBlank);
	seq(rng) = seq(rng) + sineOffset;
end

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function stim = setFixation(stim);
%% add a fixation mark, and set the sequence of color map indices for the fixation task
width = stim.display.numPixels(1);
height = stim.display.numPixels(2);

% deal with possible L/R and U/D flips in the display: the mirrors used in
% getting the display to the subject in the scanner can change the intended
% corner:
whichCorner = stim.fixationPos;
if isfield(stim.display, 'flipLR') & stim.display.flipLR==1 & whichCorner > 0
	switch whichCorner
		case 1, whichCorner = 2;
		case 2, whichCorner = 1;
		case 3, whichCorner = 4;
		case 4, whichCorner = 3;
	end
end
if isfield(stim.display, 'flipUD') & stim.display.flipUD==1 & whichCorner > 0
	switch whichCorner
		case 1, whichCorner = 3;
		case 2, whichCorner = 4;
		case 3, whichCorner = 1;
		case 4, whichCorner = 2;
	end
end
	

switch whichCorner
	case 0,  % center
		stim.display.fixX = round(width/2);
		stim.display.fixY = round(height/2);
		stim.display.fixSizePixels = 5;		
	case 1,  % upper right-hand corner
		stim.display.fixX = 0;
		stim.display.fixY = 0;
		stim.display.fixSizePixels = 10;
	case 2,  % upper left-hand corner
		stim.display.fixX = width;
		stim.display.fixY = 0;
		stim.display.fixSizePixels = 10;
	case 3,  % lower right-hand corner
		stim.display.fixX = 0;
		stim.display.fixY = height;
		stim.display.fixSizePixels = 10;
	case 4,  % lower right-hand corner
		stim.display.fixX = width;
		stim.display.fixY = height;
		stim.display.fixSizePixels = 10;
	otherwise,
		error('Invalid fixation position value.')
end

switch lower(stim.fixationType)
    case 'simon task'
        %% Simon-like task: 4 dots are shown, and N (2-4) of the dots are
        %% highlighted. The subject needs to remember the sequence of N
        %% dots, and use the keypad to play it back.
        nBlock = stim.nCycles;
        nTR = stim.framesPerCycle / 2; % TRs per block
        nTask = (2*nBlock + 1) * nTR; % include an extra half-cycle at the beginning

        %% fixation sequence (order of locations in Simon task)
        % By difficulty level, each task has 2 or 3 or 4 vectors.
        if stim.fixationTaskDifficulty==2
            % only 2 steps: here are all the possibilities
            nVec = [1 2; 1 3; 1 4; 2 1; 2 3; 2 4; 3 1; 3 2; 3 4; 4 1; 4 2; 4 3];
        else
            % 3 or 4
            nVec = [1 2 1; 1 2 3; 1 2 4; 1 3 1; 1 3 2; 1 3 4; 1 4 1; 1 4 2; 1 4 3; ...
                    2 1 2; 2 1 3; 2 1 3; 2 3 1; 2 3 2; 2 3 4; 2 4 1; 2 4 2; 2 4 3; ...
                    3 1 2; 3 1 3; 3 1 4; 3 2 1; 3 2 3; 3 2 4; 3 4 1; 3 4 2; 3 4 3; ...
                    4 1 2; 4 1 3; 4 1 4; 4 2 1; 4 2 3; 4 2 4; 4 3 1; 4 3 2; 4 3 4;];
            if stim.fixationTaskDifficulty==4
                % one extra step: we add the possibilities for the 4th step
                nVec = [ones(9,1)*2, nVec(1:9,:); ...
                        ones(9,1)*3, nVec(1:9,:); ...
                        ones(9,1)*4, nVec(1:9,:);...
                        ones(9,1), nVec(10:18,:); ...
                        ones(9,1)*3, nVec(10:18,:); ...
                        ones(9,1)*4, nVec(10:18,:);...
                        ones(9,1), nVec(19:27,:); ...
                        ones(9,1)*2, nVec(19:27,:); ...
                        ones(9,1)*4, nVec(19:27,:);...
                        ones(9,1), nVec(28:36,:); ...
                        ones(9,1)*2, nVec(28:36,:); ...
                        ones(9,1)*3, nVec(28:36,:)];
            end
        end

        % of the possible sequences to use (in nVec), select a subset at random for
        % each task occurrence
        stim.fixSeq = ceil( rand(nTask, 1) * size(nVec, 1) );
        nVec = nVec(stim.fixSeq,:);
        
        % set the task sequence
%         taskseq = [];
%         nTaskReps = length(stim.seedA) / size(nVec,2);
%         for ii = 1:size(nVec,2)
%             taskseq = [taskseq, repmat(nVec(:,ii), [1 nTaskReps])];
%         end

        stim.display.fixColorRgb = [1 0 0; 1 1 1];
        stim.display.fixSizePixels = 5;        

        
        %% (2) add fixation mark to template; reserve colors for fixation task
        % change from #1-246 to #4-249, #0-3 reserved
        stim.images = stim.images + 4 - 1;

        % Fixation - custom input. Set #250-255 for fixation.
        nC = stim.display.numColors - 1; % there is a -1 difference


        stim.images(cpt(1)+(-10:10),cpt(2)+(-10:10)) = nC; %block (brick sign)
        stim.images(cpt(1)+(-3:3),cpt(2)+(-3:3)) = nC - 1; %center
        stim.images(cpt(1)+(-3:3),cpt(2)-(4:10)) = nC - 2; %left
        stim.images(cpt(1)+(-3:3),cpt(2)+(4:10)) = nC - 3; %right
        stim.images(cpt(1)-(4:10),cpt(2)+(-3:3)) = nC - 4; %up
        stim.images(cpt(1)+(4:10),cpt(2)+(-3:3)) = nC - 5; %down
        


    case {'dot' 'cross' 'disc' 'disk'}
        %% simple fixation dot: detect a color change (1 or 2)
        % space the color changes at least 2 sec apart
		nn = 30;
		stim.fixSeq = zeros( size(stim.seq) );
        stim.fixSeq = ones(nn,1) * round( rand(1,ceil(length(stim.seq)/nn)));
		stim.fixSeq = stim.fixSeq(:) + 1;
		stim.fixSeq = stim.fixSeq(1:length(stim.seq));

		% force binary
		stim.fixSeq(stim.fixSeq>2)=2; 
		stim.fixSeq(stim.fixSeq<1)=1;

		
        stim.display.fixColorRgb = [255 255 255; 254 254 254];
        
		if isequal( lower(stim.fixationType), 'dot' )
			stim.display.fixSizePixels = 3;       
		else
			stim.display.fixSizePixels = 8;
		end
		
	case {'color task'}
		%% set fixation sequence: color detection task
		stim.responseKeys = {'5' '4' '3' '2'}; % keys for each color in fixation task
		
		% set the colors to use for the fixation
		nFixColors = stim.fixationTaskDifficulty;
		defColors = [1 1 1; 0 0 1; 0 .8 0; 1 0 0; 1 1 0];
		stim.cmap(end-nFixColors:end,:) = defColors(1:nFixColors+1,:);

		% (NOTE: the main function, called when running the stimulus, is
		% drawFixation: this function sets the fixation in such a way that
		% display.fixColorRgb serves as an index into the cmap, even though it may
		% seem like a list of [R G B] truecolor triplets.)
		stim.display.fixColorRgb = [];
		for n = 1:nFixColors+1
			stim.display.fixColorRgb(n,:) = repmat(254 - nFixColors + n, [1 3]);
		end

		% (re-) initialize the fixation sequence with ones: 
		% this will point to the default, non-prompt color
		stim.fixSeq = ones(size(stim.seq));
				
		% prompt every trial
		ISI = stim.secsPerTrial;
		promptTime = ISI:ISI:max(stim.seqtiming);
		promptTime = promptTime(1:end-1); % last prompt comes around end of run 

		% round these prompt times to the nearest onset specified in seqtiming
		for n = 1:length(promptTime)
			I = find( stim.seqtiming < promptTime(n) );
			promptTime(n) = stim.seqtiming(I(end));
			promptFrame(n) = I(end);
		end

		% for each prompt frame (and the 2 following: give it a duration),
		% randomly assign one of nFixColors as the fixation color
		for ii = unique(promptFrame)
			% +1 offset: first entry is the baseline fixation color
			stim.fixSeq(ii:ii+2) = ceil( nFixColors * rand ) + 1;
		end

		% keep track of when the prompts occur
		stim.promptTime = promptTime;
		stim.promptFrame = promptFrame;

		% set the prompt for the fixation task (TODO: parametrize this)
		stim.taskStr = 'Fixation color: (1) blue (2) green (3) red';        

	otherwise,
        error('Invalid fixation type.')
end

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function stim = runStimulus(stim);
%% run the ABAB Color Stimulus, collecting user responses.
% This code is based off code in doRetinotopyScan.
% ras, 07/2008.

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

    % getting to the source rather than doScan->doTrial->showStimulus 
    for n = 1:stim.nRunRepeats,
        % set priority
        Priority(stim.runPriority);
        
        % wait for go signal
        pressKey2Begin(stim.display);      

        % countdown + get start time (time0)
        [time0] = countDown(stim.display, stim.startScan+2, stim.startScan);
        time0   = time0 + stim.startScan; % we know we should be behind by that amount

        % go
        [response, timing, quitProg] = showColorStimulus(stim.display, stim, time0);
        
		% record responses
		stim.responses(n) = response;
		
        % reset priority
        Priority(0);
		
		% report timing
        fprintf('Done. Total stimulus duration: %i min %2.1f sec. \n', ...
				floor((getSecs-time0)/60), mod((getSecs-time0), 60)); 		
        
		% how well did the subject do?
		if isequal( lower(stim.fixationType), 'color task' )
			stim = computeTaskPerformance(stim);
		end
			
        % keep going?
        if quitProg, % don't keep going if quit signal is given
            break;
        end;
    end;
    
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
% 	ensureDirExists(dataDir);
	
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
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function stim = computeTaskPerformance(stim);
%% calculate the user's performance on the fixation color-detection task,
%% reporting it in the command line, saying it (if stim.speak==1), and
%% storing it in stim.responses.RT and stim.responses.percentCorrect.
% First, initialize a set of correct/incorrect flags and RTs for each
% prompt:
stim.responses.correct = repmat(NaN, [1 length(stim.promptFrame)]);
stim.responses.RT = repmat(NaN, [1 length(stim.promptFrame)]);

% Next, let's find the times when keypresses
% were made, and see if they correspond to the correct color:
keypressFrames = find(stim.responses.keyCode);
for f = keypressFrames(:)'
	lastPrompt = max( stim.promptFrame(stim.promptFrame < f) );
	promptIndex = find( stim.promptFrame==lastPrompt );
	
	correctResp = stim.fixSeq(lastPrompt) - 1; %-1 b/c of non-prompt fix color
	
	
	% find out whether the key which was pressed maps to one of the
	% designated response keys; and if so, which one:
	k = KbName(stim.responses.keyCode(f));
	responseIndex = strmatch( lower(k(1)), lower(stim.responseKeys) );
	
	if isempty(responseIndex)
		% invalid key pressed: incorrect by default
		stim.responses.correct(promptIndex) = 0;
	else
		% may be correct: was it the right key?
		stim.responses.correct(promptIndex) = (responseIndex==correctResp);
	end
	
	% get the response time (in msec)
	rt = stim.responses.secs(f) - stim.promptTime(promptIndex);
	stim.responses.RT(promptIndex) = 1000 * rt;
end

% the remaining prompts, for which no keypress is recorded, are incorrect
% by default:
% we'll leave the RTs at NaN to indicate no keypress as well
stim.responses.correct( isnan(stim.responses.correct) ) = 0;

% compute the overall percent correct
stim.responses.percentCorrect = 100 * ...
	sum(stim.responses.correct) / length(stim.responses.correct);

%% report the results
msg = sprintf('%i Percent Correct', round(stim.responses.percentCorrect));
fprintf('[%s]: %s\n', mfilename, msg);
if stim.speak==1
    eval('system(sprintf(''say %s'',msg));',''); 
end

return


