function stim = facebehav_createStaircase(stim);
% Initialize a staircase run.
%
%   stim = facebehav_createStaircase(stim);
%
% This function takes a stim struct which contains staircase parameters
% (spcified in facebehav_staircase), and loads an appropriate set of face
% images, scaled to the proper size, as well as stimulus fields used for
% running the staircase trials. The fields are similar to those created by
% facebehav_run, and include:
%	
%	stim.images: cell array of face images. These images are resized to
%	stim.faceSize, but are not contrast-scaled or degraded by noise. (This
%	is performed as a function of the staircase in
%	facebehav_staircaseTrial). stim.images will usually be smaller than the
%	number of trials, since we may run many trials but the face database is
%	still somewhat limited (~100 faces). The image to use for each trial is
%	given by stim.imgNum.
%
%	stim.imgNum: [1 x nTrials] array indicating which image index to use
%	for each trial.
%
%	stim.isMatch: [1 x nTrials] array indicating whether the image on each
%	trial is a match or nonmatch image.
%
%	stim.taskStr: string indicating the task question to put up to the user
%	before starting the run.
%	
% The function also ensures that the save data directory exists, and sets
% the name for both the data save file, as well as a temp save file which
% will keep track of the performance of the staircase as it goes. The data
% file is the Data/ subdirectory of the code directory.
%
%
% ras, 07/13/2009.
fprintf('[%s]: This may take a while...', mfilename);
startTime = GetSecs;

% get the # of face images to load for match, nonmatch trials
% (this depends on the desired # of trials: if it's pretty small -- <100 --
% then we can try to make each trial have a unique image. Otherwise, we'll
% need to repeat images.)
if stim.nTrials < 100
	nFaces = stim.nTrials / 2;
else
	nFaces = 50;
end
	

%% load/resize match and nonmatch images
switch lower(stim.task)
    case 'detect',
		% for the detection task, the match images are intact faces and the
        % nonmatch images are Fourier phase-scrambled faces.
        match = loadFaces(zeros(1, nFaces), 'b', stim.faceSize);
        nonmatch = phaseScramble(match);
        
    case 'categorize', 
		% for the categorization task, the match images are faces and the
        % nonmatch images are object images from the categories specified by
		% 'otherCategories'.
		match = loadFaces(zeros(1, nFaces), 'b', stim.faceSize);
		nonmatch = loadCategoryImages(nFaces, stim.otherCategories);
    
	case 'inverted',
		% 'inverted' task: match is an upright face, nonmatch is inverted
		match = loadFaces(zeros(1, nFaces), 'b', stim.faceSize);
		for ii = 1:length(match)
			nonmatch{ii} = flipud(match{ii});
		end
		
    case 'gender',
		% for the gender task, the match images are female faces and the
        % nonmatch images are male faces.
		match = loadFaces(zeros(1, nFaces), 'm', stim.faceSize);
		nonmatch = loadFaces(zeros(1, nFaces), 'f', stim.faceSize);
        
    case 'identify',
        % for the identification task, the match images are a particular
        % face, and the nonmatch images are other faces from both genders.
        % For this task, we use a range of angles at which to show the
        % faces.
        oris = 0; % range of orientations to use
        nDistractors = 10; % have this many different faces as distractors
        
        % pick a target face ID at random from the available faces
        % (both genders)
        [faceList ids] = faceDBFolders('both');
        ids = shuffle(ids);
        targetID = ids(1);
        nontargetIDs = ids(2:end);
        
        match = loadFacesByID(targetID, oris, stim.faceSize);
        nonmatch = loadFacesByID(nontargetIDs, oris, stim.faceSize);
        nonmatch = nonmatch(:)';
        
        % record the orientations used
        stim.faceOrientations = oris;
end

%% combine match and nonmatch images into the stim.images field
% we'll put match images first, nonmatch images second
stim.images = [match nonmatch];
matchRange = 1:length(match);
nonmatchRange = [1:length(nonmatch)] + length(match);

% also create a mask image indicating the circular background
% (this background shouldn't have noise added to it)\
sz = stim.faceSize;
[xx yy] = meshgrid([1:sz] - sz/2);
R = sqrt(xx.^2 + yy.^2);
stim.bgMask = (R > sz/2 * 1.05); % +10 empirically derived from face images


%% create a trial order of 50% match and 50% nonmatch images
stim.isMatch = repmat([1; 2], [1 stim.nTrials/2]);
stim.isMatch = Shuffle(stim.isMatch(:)');

% assign each match trial a random image #
matchTrials = find(stim.isMatch==1);
nMatch = length(matchTrials);
stim.imgNum(matchTrials) = ceil( length(match) * rand(1, nMatch) );

nonmatchTrials = find(stim.isMatch==2);
nNonmatch = length(nonmatchTrials);
I = ceil( length(nonmatch) * rand(1, nNonmatch) );
stim.imgNum(nonmatchTrials) = nonmatchRange(I);

% %% set the placeholder position, size variables for each trial
% stim.faceEcc = repmat(stim.faceEcc, [1 stim.nTrials]);
% stim.faceAngle = repmat(stim.faceAngle, [1 stim.nTrials]);
% stim.faceSize = repmat(stim.faceSize, [1 stim.nTrials]);

%% set the task string for the user instructions
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

%% set the data directory, and data file names
stim.codeDir = fileparts( which(mfilename) );
stim.dataDir = fullfile(stim.codeDir, 'Data');
ensureDirExists( stim.dataDir );

% find the # of the data file for this subject and task
pattern = fullfile(stim.dataDir, [stim.subject '-' stim.task '*.mat']);
w = dir(pattern);
N = length(w) + 1;

fileName = [stim.subject '-' stim.task '-' num2str(N) '.mat'];
stim.dataFile = fullfile(stim.dataDir, fileName);
stim.tempDataFile = fullfile(stim.dataDir, ['temp_' fileName]);

fprintf('done. (%.2f seconds)\n', getSecs - startTime);

return
