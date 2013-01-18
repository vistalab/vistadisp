function stim = facebehav_makescript(varargin);
%
% stim  = facebehav_makescript(varargin);
%
% Creates a series of scripts for behavioral face recognition experiments
% (specifically testing the effects of retinal position and image size on
% recognition behavior). Also saves scaled face images for each run.
%
% These scripts provide a description of each experimental run, down to the 
% precise presentation time of each image.
%
% This is designed to run without input arguments; however, the default
% parameters can be overridden by specifying 'parameter', [value] pairs as
% input arguments.
%
% The scripts and images are named according to the behavioral task
% employed; the number of previous sets of scripts/images employing the
% same task (the "set number" for this set of scripts); and the run number
% within this set. The possible tasks supported are:
%
%   'detect': detect whether an intact or phase-scrambled face is shown.
%
%   'categorize': discriminate whether a face or non-face object is shown.
%   The non-face object category is specified by the parameter
%   'otherCategories'. 
%
%	'inverted': discriminate whether a face is upright or inverted.
%
%   'gender': discriminate between male and female faces.
%
%   'identify': identify whether a given face matches a target face.
%   (The target face is assigned randomly within each run.)
%
% For each of these tasks, there are an equal number of match and nonmatch
% trials. 
%
% The scripts are saved in the same code directory as this M-file, in the
% subdirectory Scripts/, with the following naming convention:
%
% 	[code dir]/Scripts/[task]-[set #]-[run #].txt
%
% e.g.:
%   
% 	[code dir]/Scripts/gender-1-2.txt
%
%   indicates the script for the gender discrimination task, first set of
%   runs, run # 2.
%
% The images are saved also relative to the code directory, in the
% subdirectory FaceBehavImages. They have the following naming conventions:
%
% 	[code dir]/FaceBehavImages/[task]-[set #]/[ismatch]-[size]px-[n].png
%
%   where 'ismatch' is either 'match' or 'nonmatch', depending on the
%   expected response to this image, 'size' is the image diameter in
%   pixels, and [n] is the index of the nth image of this type.
%
% e.g.:
%
%   [code dir]/FaceBehavImages/detect-1/nonmatch-30px-4.png
%
%   indicates the nonmatch image for the detection task (which would be a
%   face-scrambled face, set 1, run 2, 30 pixels size, and the fourth such
%   image.
%
% Returns a structure containing script information for each run.
%
% ras, 05/2009.

%% params %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% recgonition task: 'detect', 'categorize', 'inverted', 'gender', 'identify'
stim.task = 'identify'; 
stim.trialsPerCond = 5; % # trials for each unique position/size condition per run
stim.trialDur = 2;  % trial duration in seconds
stim.imageDur = 2/30; % duration of image on the screen in seconds
stim.doMask = 0;  % mask with a scrambled face (1)? or show blank? (0)
stim.addNoise = 1; % flag indicating whether to add noise to images
stim.noiseType = -1; % degree of noise n (1/f^n); -1 for partial phase-scrambling.
stim.noiseLevel = .43; % if adding noise, proportion of image that is noise
stim.maskDur = .250; % if using mask, how long to show it? (in secs)
stim.nRuns = 10;   % # of scripts to generate in this series
stim.otherCategories = {}; % this only needs to be set for the 'categorize' task
stim.prestimSecs = 4;   % # seconds before 1st bar sweep
stim.poststimSecs = 4;  % # seconds after last bar sweep
stim.screenRes = [600 600];  % size of images to generate ([X Y])

% these parameters determine the eccentricity, polar angles, and sizes of
% stimulus position to test, in visual degrees. We will convert to pixels
% below (facebehav_angle2pix), and use pixels as the size for the remainder of the code.
stim.eccentricities = [0 1 2 4 8 16];
stim.angles = [pi]; % linspace(-1/2*pi,1/2*pi,8); % pi radians = 9-o-clock
stim.sizes  = [1 2 4 8 16]; 

stim = facebehav_angle2pix(stim);

% create a grid of possible condition numbers for the eccentricity, polar
% angle, and size dimensions:
[ecc pol sz] = meshgrid(1:length(stim.eccentricities), ...
						1:length(stim.angles), ...
						1:length(stim.sizes));
stim.eccNum = ecc(:)'; % make each a row vector
stim.angleNum = pol(:)';
stim.sizeNum  = sz(:)';  

% save directories for the scaled images and scripts
codeDir = fileparts(which(mfilename));
stim.scriptDir = fullfile(codeDir, 'Scripts');
stim.imageDir = fullfile(codeDir, 'FaceBehavImages');

% what set number do we assign to this set of runs?
% this depends on the number of image sets we have already generated for
% this task: (look for the 1st run of each set)
pattern = fullfile(stim.imageDir, [stim.task '-*']); 
w = dir(pattern);
stim.set = length(w) + 1;

% parse the input arguments
for ii = 1:2:length(varargin)
	eval( sprintf('stim.%s = %s', varargin{ii}, num2str(varargin{ii+1})) );
end
%% end params %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ensureDirExists(stim.scriptDir);
ensureDirExists(stim.imageDir);

%% make images for this set of scripts
stim = facebehav_saveImages(stim);

%% make several scripts using these images
for run = 1:stim.nRuns
	stim = facebehav_genscript(stim, run);
	
	% script name pattern:
	%  [task]-[set #]-[run #].txt
	scriptName = sprintf('%s-%i-%i.txt', stim.task, stim.set, run);
	scriptPath = fullfile(stim.scriptDir, scriptName);
	writeScript(stim, scriptPath);
end

% report that we're done.
fprintf('Created %i scripts for task %s, set %i.\n', stim.nRuns, ...
		stim.task, stim.set);
fprintf('\n\n\n*** ');
fprintf('[%s]: done. \t(%s) ***\n', mfilename, datestr(now));

return
% /--------------------------------------------------------------/ %



% /--------------------------------------------------------------/ %
function stim = facebehav_angle2pix(stim);
%% convert desired visual angles into pixel sizes, based on the
%% experimental setup.
screenDims = [44 28];  % size [X Y] of experimental display in cm
screenRes = [1680 1050]; % number of [X Y] of resolution to use
eyeDist = 43; % distance from subject eye -> screen in cm

% note: the aspect ratio of the above parameters should be fairly similar,
% or the faces will look anisotropic and a little odd. The defaults for the
% Room 454 display work out to ratios of 1.57 (physical dimensions) versus
% 1.6 (pixels), so a pixel is roughly square and the display should be
% good. My original 800/600 resolution has an aspect ratio of 4/3, which is
% not as good. So, higher resolution is better both for finer control of
% visal angle, and better aspect ratio.

% main trigonometry step: get size of each eccentricity, face size in cm
% (face size is in diameter rather than radius -- hence the 2*)
eccentricitiesCm = eyeDist * tan( deg2rad(stim.eccentricities) );
sizesCm = eyeDist * tan( deg2rad(2 * stim.sizes) );

% convert from cm -> pixels given the screen dimensions
% (I base the conversion on the X axis dimensions, which is what we
% generally manipulate -- eccentricity along the horizontal meridian. But
% if the pixel aspect ratio is around 1, it doesn't matter.)
stim.eccentricities = round( eccentricitiesCm * screenRes(1) / screenDims(1)  );
stim.sizes = round( sizesCm * screenRes(1) / screenDims(1)  );

return
% /--------------------------------------------------------------/ %



% /--------------------------------------------------------------/ %
function stim = facebehav_saveImages(stim);
%% load, modify and save the face images for this set of runs.
% for each task, we're going to have two groups of images, one
% corresponding to correct/match images and one to incorrect/nonmatch
% images for the given task. We create these images in different ways
% depending on the task. Regardless, the output images will be in imlist1
% (match images) and imlist2 (nonmatch images).
verbose = prefsVerboseCheck;

%% compute derived parameters
% how many unique conditions (position x size)?
nConds = length(stim.eccNum);

% how many total trials?
nTrials = stim.trialsPerCond * nConds;

% how many match / nonmatch trials?
% (Each task will be 50/50 odds of match or nonmatch)
%
% A NOTE HERE: I could keep the image set small, equal to just
% stim.trialsPerCond. Then I'd use these 6 or so faces at all sizes and
% positions, to be perfectly counterbalanced. I don't do that here, for two
% reasons: (1) with a small set size, I worry subjects may learn those
% individual faces, even for a more general task; (2) because our total
% face image set is small, ~100 images, a randomized approach to picking
% faces will quickly converge to having equal coverage of each particular
% face across each size and position. Thus, for any given run there may be
% more of a face at one position than another, but over many runs, these
% rough asymmetries will balance out, and the recognition behavior should
% be relatively free of over-training effects. 
%
nMatchTrials = nTrials / 2;

%% set up the save directory
% save pattern:
% [imageDir]/[task]-[set]/[ismatch]-[sz]px-[#].png
subDir = fullfile(stim.imageDir, sprintf('%s-%i', stim.task, stim.set));
if exist(subDir, 'dir')
	error('Image directory %s already exists. (?)', subDir);
end
ensureDirExists(subDir);


%% load unscaled match and nonmatch images
switch lower(stim.task)
    case 'detect',
		% for the detection task, the match images are intact faces and the
        % nonmatch images are Fourier phase-scrambled faces.
        match = loadFaces(zeros(1, nMatchTrials), 'b');
        nonmatch = phaseScramble(match);
        
    case 'categorize', 
		% for the categorization task, the match images are faces and the
        % nonmatch images are object images from the categories specified by
		% 'otherCategories'.
		match = loadFaces(zeros(1, nMatchTrials), 'b');
		nonmatch = loadCategoryImages(nMatchTrials, stim.otherCategories);
    
	case 'inverted',
		% 'inverted' task: match is an upright face, nonmatch is inverted
		match = loadFaces(zeros(1, nMatchTrials), 'b');
		for ii = 1:length(match)
			nonmatch{ii} = flipud(match{ii});
		end
		
    case 'gender',
		% for the gender task, the match images are female faces and the
        % nonmatch images are male faces.
		match = loadFaces(zeros(1, nMatchTrials), 'm');
		nonmatch = loadFaces(zeros(1, nMatchTrials), 'f');
        
    case 'identify',
        % for the identification task, the match images are a particular
        % face, and the nonmatch images are other faces from both genders.
        oris = 0; % range of orientations to use
        nDistractors = 10; % have this many different faces as distractors
        
        % we randomly pick a number of target faces equal to the number of
		% runs -- when we make the scripts, we will index things such that
		% only one target image is used per run, and none of the target
		% images are used in any other run.
        [faceList ids] = faceDBFolders('both');
        ids = shuffle(ids);
        targetID = ids(1:stim.nRuns);
        nontargetIDs = ids(stim.nRuns+1:end);
        
        match = loadFacesByID(targetID, oris);
        nonmatch = loadFacesByID(nontargetIDs, oris);
        nonmatch = nonmatch(:)';
        
        % ensure there are enough nonmatch images for the requested number
        % of trials (for the match, we only have one, and we make sure the
        % indexing works out in the genscript code):
        while length(nonmatch) < nMatchTrials
            nonmatch = [nonmatch shuffle(nonmatch)];
        end
        
        % record the orientations used
        stim.faceOrientations = oris;
        
       % save the noise-free match images to show at the beginning of each run
       for ii = 1:length(match)
           imgPath = fullfile(subDir, sprintf('target-%i.png', ii));
           img = imresize(match{ii}, [400 400]);
           imwrite(img, imgPath);
           fprintf('Saved %s.\n', imgPath);
       end
end
        

%% resize
for jj = 1:length(stim.sizes)
	matchImages{jj} = resizeMany(match, stim.sizes(jj));
	nonmatchImages{jj} = resizeMany(nonmatch, stim.sizes(jj));
end

%% for the identification task, we want to replicate the match images many
%% times, to allow different noise masks each time. 
if isequal( lower(stim.task), 'identify' )
   for jj = 1:length(stim.sizes)
       nRep = ceil( nMatchTrials / length(stim.sizes) );
       
       % we replicate such that the first (nRep) images are target 1, the
       % next (nRep) are target 2, etc.
       matchImages{jj} = repmat(matchImages{jj}(:)', [nRep 1]);
       matchImages{jj} = matchImages{jj}(:);
   end
end

%% add noise to images if specified
if stim.addNoise==1
   w = stim.noiseLevel; 
   
   if stim.noiseType==-1
       % fractional noise type: do partial phase scrambling
       for jj = 1:length(stim.sizes)
           matchImages{jj} = partialPhaseScramble(matchImages{jj}, w);
           
           nonmatchImages{jj} = partialPhaseScramble(nonmatchImages{jj}, w);
       end
   else
       %  do 1/f^N scrambling
       for jj = 1:length(stim.sizes)
           matchImages{jj} = ...
               addNoiseToMany(matchImages{jj}, stim.noiseType, w);
           
           nonmatchImages{jj} = ...
               addNoiseToMany(nonmatchImages{jj}, stim.noiseType, w);
       end
       
   end
end

%% save
for jj = 1:length(stim.sizes)
	for ii = 1:length(matchImages{jj})
		imgName = sprintf('match-%ipx-%i.png', stim.sizes(jj), ii);
		imgPath = fullfile(subDir, imgName);
		imwrite(matchImages{jj}{ii}, imgPath);
		if verbose >= 1,
			fprintf('Saved %s.\n', imgPath);
		end
		
		stim.imlist1{jj}{ii} = imgPath;
	end
		
	for ii = 1:length(nonmatchImages{jj})
		imgName = sprintf('nonmatch-%ipx-%i.png', stim.sizes(jj), ii);
		imgPath = fullfile(subDir, imgName);
		imwrite(nonmatchImages{jj}{ii}, imgPath);
		if verbose >= 1,
			fprintf('Saved %s.\n', imgPath);
		end
		
		stim.imlist2{jj}{ii} = imgPath;
	end
end	

%% lastly, make phase-scrambled mask images if we need them
if stim.doMask==1
	% for the detection task, we may have already made scrambled images as
	% nonmatch images. We won't have to do it again, but we'll save the
	% images separately as masks. For all other tasks, we need to scramble
	% the match and nonmatch images.
	if isequal( lower(stim.task), 'detect' )
		maskImages = nonmatchImages;
	else
		for jj = 1:length(stim.sizes)
			intactImages = [matchImages{jj} nonmatchImages{jj}];
			
			% randomly choose half to scramble
			intactImages = shuffle(intactImages);
			intactImages = intactImages(1:nMatchTrials);
			
			maskImages{jj} = phaseScramble(intactImages);
            
            for ii = 1:length( maskImages{jj} )
                maskImages{jj}{ii} = rescale2(maskImages{jj}{ii}, [], [0 255]);
            end
		end
	end
	
	% save pattern:
	% [imageDir]/[task]-[set]/mask-[sz]px-[#].png
	for jj = 1:length(stim.sizes)
		for ii = 1:length(maskImages{jj})
			imgName = sprintf('mask-%ipx-%i.png', stim.sizes(jj), ii);
			imgPath = fullfile(subDir, imgName);
			imwrite(maskImages{jj}{ii}, gray(256), imgPath);
			if verbose >= 1,
				fprintf('Saved %s.\n', imgPath);
			end

			stim.masks{jj}{ii} = imgPath;
		end
	end
end

return
% /--------------------------------------------------------------/ %



% /--------------------------------------------------------------/ %
function stim = facebehav_genscript(stim, run);
%% set up the scripts
stim.onset = 0;  % onset in seconds since run start: initialize 
stim.cond = 0;
stim.image = {'blank'}; 
stim.trialNum = 0; 
stim.faceEcc = 0;
stim.faceAngle = 0;
stim.faceSize = 0;
stim.isMatch = 0;
stim.task = stim.task;
stim.doMask = stim.doMask;
stim.imageDirs = stim.imageDir;

switch lower(stim.task)
    case 'detect',
        stim.taskStr = 'Is there a face (1) or no face (2)?';
    case 'categorize',
        stim.taskStr = ['Face (1) or ' otherCategories ' (2) ?'];
	case 'inverted',
		stim.taskStr = 'Is the face upright (1) or inverted (2)?';
    case 'gender',
        stim.taskStr = 'Male (1) or Female (2)?';
    case 'identify',
        stim.taskStr = 'Does the face match this target face (1) or not (2)?';
end

%% create the condition order for the trials
% how many unique conditions (position x size)?
nConds = length(stim.eccNum);

% how many total trials?
nTrials = stim.trialsPerCond * nConds;

% how many match / nonmatch trials?
% (Each task will be 50/50 odds of match or nonmatch)
nMatchTrials = nTrials / 2;

% the condition numbers will encode the polar angle position (100s digit),
% eccentricity position (10s digit), and size (1s digit).
conds = 100*(stim.angleNum-1) + 10*(stim.eccNum-1) + stim.sizeNum - 1;

conds = repmat(conds, [1 stim.trialsPerCond]);
pol = repmat(stim.angleNum, [1 stim.trialsPerCond]);
ecc = repmat(stim.eccNum, [1 stim.trialsPerCond]);
sz = repmat(stim.sizeNum, [1 stim.trialsPerCond]);

% shuffle condition order
I = shuffle(1:numel(conds));
conds = conds(I);
pol = pol(I);
ecc = ecc(I);
sz = sz(I);

% these variables are needed for the identification task...
if isequal( lower(stim.task), 'identify' )
	pixSizes = unique(stim.sizes);
	subDir = fullfile(stim.imageDir, sprintf('%s-%i', stim.task, stim.set));
end

if length(conds) ~= nTrials
	error('Oops! Trial counting messed up somehow.')
end

% % for the identification task, there are an unequal number of match and
% % nonmatch image. Repeat the match (target identity) image strings until
% % they have the same number of entries as nonmatch (even though the entries
% % are duplicated). This will make the image indexing below much easier and
% % more general.
% if isequal( lower(stim.task), 'identify' )
%     for jj = 1:length(stim.imlist1)
%         while length(stim.imlist1{jj}) < length(stim.imlist2{jj})
%             stim.imlist1{jj} = [stim.imlist1{jj} stim.imlist1{jj}];
%         end
%     end
% end

% for each trial, randomly assign the image to be match or nonmatch.
isMatch = round( rand(1, nTrials) ) + 1;

%% get a set of images for these trials
% an image is uniquely specified by whether it is match or nonmatch, its
% size, and its count within the set of images of that size. I could keep a
% counter here for each trial, to make sure each image is unique, but
% instead I randomly choose an image for each trial, based on the specified
% size and class (match/nonmatch). This should work out the same for the
% current face image set size (~100 images, as of 2009). If we get many
% more face images, we can properly counterbalance face identity across
% positions. 
for n = 1:nTrials
	imgNum = floor( nMatchTrials * rand(1) ) + 1;
	
	if isMatch(n)==1
		% match
		if isequal( lower(stim.task), 'identify' )
			% identification task: special case: there is only one target
			% image per run, but many copies of that image with different
			% noise samples. So, we do a complex indexing of the img
			% number. The first (nRep) images are all target 1 for run 1,
			% the next (nRep) for run 2, etc. See the saveImage code above.
            nRep = ceil( nMatchTrials / length(stim.sizes) );
 
            
            newImgNum = nRep * (run-1) + floor( nRep * rand(1) ) + 1;
			imfile = sprintf('match-%ipx-%i.png', pixSizes(sz(n)), newImgNum);
			imlist{n} = fullfile(subDir, imfile);
		else
			imlist{n} = stim.imlist1{ sz(n) }{imgNum};
		end
  	else
		% nonmatch
		imlist{n} = stim.imlist2{ sz(n) }{imgNum};
    end
    
    if stim.doMask > 0
        masks{n} = stim.masks{ sz(n) }{imgNum};
    end
end

%% add the trials to the stim struct
for n = 1:nTrials
	%% add the event for the image presentation
	onset = (n-1) * stim.trialDur + stim.prestimSecs;
	
	angle =  stim.angles( pol(n) );
	eccentricity =  stim.eccentricities( ecc(n) );
	faceSize = stim.sizes( sz(n) );
	
	% add to the stimulus struct
	stim.onset = [stim.onset onset];
	stim.image = [stim.image imlist{n}];
	stim.cond = [stim.cond conds(n)];
	stim.faceEcc = [stim.faceEcc eccentricity];
	stim.faceAngle = [stim.faceAngle angle];
	stim.faceSize = [stim.faceSize faceSize];
	stim.isMatch = [stim.isMatch isMatch(n)];
	stim.trialNum = [stim.trialNum n];
	
	if stim.doMask > 0
		offsetImage = masks{n};
	else
		offsetImage = 'blank';
	end
	
	%% add the event for the image offset
	onset = (n-1) * stim.trialDur + stim.imageDur + stim.prestimSecs;

	% add to the stimulus struct
	stim.onset = [stim.onset onset];
	stim.image = [stim.image offsetImage];
	stim.cond = [stim.cond 0];
	stim.faceEcc = [stim.faceEcc 0];
	stim.faceAngle = [stim.faceAngle 0];
	stim.faceSize = [stim.faceSize 0];
	stim.isMatch = [stim.isMatch -1];	
	stim.trialNum = [stim.trialNum n];
	
    
    % for masked trials, also add a mask offset, shortly before the next
    % trial 
    % (I hard-code the blank time as 250 msec here, if it becomes necessary
    % I will parametrize it at top.)
    if stim.doMask > 0
        stim.onset = [stim.onset onset + stim.maskDur];
        stim.image = [stim.image 'blank'];
        stim.cond = [stim.cond 0];
        stim.faceEcc = [stim.faceEcc 0];
        stim.faceAngle = [stim.faceAngle 0];
        stim.faceSize = [stim.faceSize 0];
        stim.isMatch = [stim.isMatch -1];
        stim.trialNum = [stim.trialNum n];
    end
end


% add post-stim events, end of run
stim.onset(end+1) = stim.onset(end) + stim.poststimSecs;
stim.cond = [stim.cond -1];
stim.faceEcc = [stim.faceEcc -1];
stim.faceAngle = [stim.faceAngle -1];
stim.faceSize = [stim.faceSize -1];
stim.isMatch = [stim.isMatch -1];
stim.image{end+1} = 'blank';
stim.trialNum = [stim.trialNum -1];

return
% /--------------------------------------------------------------/ %



% /--------------------------------------------------------------/ %
function resizedImages = resizeMany(images, sz);
% this is a simple code snippet to iteratively resize a bunch of images in
% a cell array. Saves many "for..." loops in the code.
resizedImages = cell( size(images) );
for ii = 1:numel(images)
	resizedImages{ii} = imresize(images{ii}, [sz sz]);
end
return
% /--------------------------------------------------------------/ %



% /--------------------------------------------------------------/ %
function images = addNoiseToMany(images, N, w);
% for a cell array of images, scale back the contrast to 50%, and 
% add (1 / f^N) noise.
% if N==0, it adds white noise;
% if N==1, it adds pink noise;
% if N==2, it adds Brownian noise.
% See http://www.csse.uwa.edu.au/~pk/Research/MatlabFns/Misc/noiseonf.m

% get a mask for the background
sz = min( size(images{1}) );
[X Y] = meshgrid( [1:sz] - sz/2);
R = sqrt(X.^2 + Y.^2);
mask = (R > sz/2);

for ii = 1:length(images)
   signalImage = double( faceScaleContrast(images{ii}, .5) );
   
   noiseImage = double( noiseonf( size(signalImage), N ) );
   rng = minmax(signalImage);
   noiseImage = normalize(noiseImage, rng(1), rng(2));
   
   noiseImage(mask) = signalImage(mask);
   
   images{ii} = (1-w) * signalImage  +  w * noiseImage;
   images{ii} = uint8( rescale2(images{ii}, [], [0 255]) );
end

return
% /--------------------------------------------------------------/ %



% /--------------------------------------------------------------/ %
function images = partialPhaseScramble(images, w);
% perform partial phase-scrambling on a set of images. 
% w specifies the scramble level, ranging from 0 (no scrambling) to 1 (full
% scrambling).

% get a mask for the background
sz = min( size(images{1}) );
[X Y] = meshgrid( [1:sz] - sz/2);
R = sqrt(X.^2 + Y.^2);
mask = (R > sz/2);

% partial phase-scramble each image
for ii = 1:length(images)
   scr = phaseScramble(images{ii}, w);
   scr(mask) = images{ii}(1); % circular mask
   images{ii} = uint8( rescale2(scr, [], [0 255]) );
end

return
% /--------------------------------------------------------------/ %



% /--------------------------------------------------------------/ %
function writeScript(stim, pth);
%% write out a script file
fid = fopen(pth, 'w');

if stim.noiseType==-1
    noiseTypeStr = 'Partial Phase-scramble';
else
    noiseTypeSTr = sprintf('1/%.1f noise', stim.noiseType);
end

% write the header
fprintf(fid, 'Script for face recognition behavior experiments\n');
fprintf(fid, 'Noise level: %.2f (%s)\t', stim.noiseLevel, noiseTypeStr);
fprintf(fid, 'Run length: %3.2f seconds\n', stim.onset(end));
fprintf(fid, 'Task Question: %s', stim.taskStr);
fprintf(fid, '\n'); 

% column headers
fprintf(fid, 'Trial # \tOnset Time, sec \tCondition # \tFace Size \t');
fprintf(fid, 'Eccentricity \tPolar Angle \tTask Match?\tImage File \n');

% write the main body of the script
for i = 1:length(stim.trialNum)
    fprintf(fid, '%i \t%3.2f \t', stim.trialNum(i), stim.onset(i));
    fprintf(fid, '%i \t%i \t',  stim.cond(i), stim.faceSize(i));
    fprintf(fid, '%i \t%i \t',  stim.faceEcc(i), stim.faceAngle(i));
    fprintf(fid, '%i \t%s \n',  stim.isMatch(i), stim.image{i});	
end

% finish up
fprintf(fid, '*** END OF SCRIPT ***\n');
fclose(fid);

fprintf('Wrote %s.\n', pth);

return
