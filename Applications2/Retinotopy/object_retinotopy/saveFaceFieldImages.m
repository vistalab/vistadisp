function saveFaceFieldImages;
%
% Generates and saves a series of face field images for use in a pRF
% mapping experiment. Also generates the scripts needed to run the
% experiment, since the two steps are conceptually closely related.
%
% Unlike the related saveFaceBarImages, where several sets of images are
% saved named 'Set1' through 'SetN', for this a single set of images is
% saved with a more descriptive name: e.g., 'single_face',
% 'no_scaling_factor', or 'scale_factor_2'. A directory is created with
% this name within code/FaceFieldImages/, and a text file (.txt) script 
% is created with this name within code/Scripts/. The names reflect the 
% fact that different types of manipulations are possible in order to test
% how face visibility relates to pRF responses.
%
% For each stimulus type, in addition to the set of images and text file
% for the intact images, a Fourier phase-scrambled version of each image is
% saved, with the directory name [name '_scr'], and the corresponding
% script [name '_scr.txt']. 
%
% ras, 01/2009.

%% params
directions = 0:45:315; % set of bar directions to generate (° CW from vertical)
nStepsPerDirection = 12; % # image positions per bar direction
nImagesPerStep = 4;   % # images for each position
baseSize = 300;		  % radius of foveal face in pixels
scaleFactor = 1;	  % scaling of face size with eccentricity
secsPerBlock = 24;	  % seconds for one sweep (=one position)
prestimSecs = 12;     % seconds before stimuli are presented in each run
poststimSecs = 0;     % seconds after stimuli are presented in each run
faceType = 'b';  % 'm', 'f', or 'b': face gender
screenRes = [600 600];  % size of images to generate ([X Y])
saveName = 'full_faces';  % name of image set, script: should be descriptive
format = '.png';   % file format for images
addBlanks = 1;     % flag to add blank periods in the script
nBlankCycles = 4;    % if using blanks, # of on/off cycles per run
nBlankSecs = 12;     % length of off period for adding blanks

% derived params
nPositions = length(directions);
secsPerPosition = (secsPerBlock / nStepsPerDirection);

% the directions from which each bar moves: start coming from the left
% (270 deg), then precess counterclockwise by 135 degree steps (same as 
% 225 deg clockwise). This matches the directions in the ret code.
directions = mod(270:225:1845, 360);


%% get path of directory in which to save images
codeDir = fileparts(which(mfilename));
imageDir = fullfile(codeDir, 'FaceFieldImages');
ensureDirExists(imageDir);


%% make and save the images (intact images)
% ensure the directory exists for this set
% we choose a number for this set, based on the number of existing
% directories already exist with the same save prefix:
N = 1;
saveDir = fullfile(imageDir, [saveName '_' num2str(N)]);
while exist(saveDir, 'dir')
	N = N + 1;
	saveDir = fullfile(imageDir, [saveName '_' num2str(N)]);
end
mkdir(saveDir);

% make the un-masked face field images
imgs = faceField(scaleFactor, nImagesPerStep, 'baseSize', baseSize);

% mask through bars
bars = barApertureMask(imgs, directions, nStepsPerDirection);

% save each image
for ii = 1:size(bars, 3)
	d = ceil(ii / (nStepsPerDirection * nImagesPerStep)); % direction index
	tmp = mod( ii-1, nStepsPerDirection * nImagesPerStep ) + 1;
	p = ceil( tmp / nImagesPerStep );
	j = mod( tmp-1, nImagesPerStep) + 1;   % image index
	imgName = sprintf('%03.0fdeg-%02.0f-%i.png', directions(d), p, j);
	imgPath = fullfile(saveDir, imgName);
	imwrite(bars(:,:,ii), imgPath);
	fprintf('Saved %s.\n', imgPath);
end

%% create the script (intact images)
% get a vector of the position for each image
for ii = 1:size(bars, 3)
	tmp = mod( ii-1, nStepsPerDirection * nImagesPerStep ) + 1;
	position(ii) = ceil( tmp / nImagesPerStep );
	
	d = ceil(ii / (nStepsPerDirection * nImagesPerStep));
	barDirection(ii) = directions(d);
end

%% set up the scripts
% first we set up the no-blanks script, then the blanks one
stim.onset = 0;  % onset in seconds since run start: initialize 
stim.image = {'blank'}; 
stim.blockNum = 0; 
stim.direction = 0;
stim.position = 0;

startTime = prestimSecs;

for n = 1:length(directions)	
	for p = 1:nStepsPerDirection
		% get the set of images for this position and direction
		I = find(barDirection==directions(n) & position==p);
		imlist = {};
		for j = 1:nImagesPerStep
			imgName = sprintf('%03.0fdeg-%02.0f-%i.png', directions(n), p, j);
			imlist{j} = fullfile(saveDir, imgName);
		end
			
		% set the timing for each frame in imlist
		onset = linspace(0, secsPerPosition, nImagesPerStep+1) + startTime;
		onset = onset(1:end-1);  % last onset is start of next position	
		startTime = startTime + secsPerPosition;		
		
		% add to the stimulus struct
		stim.onset = [stim.onset onset];
		stim.image = [stim.image imlist];
		stim.direction = [stim.direction repmat(directions(n), [1 length(onset)])];		
		stim.position = [stim.position repmat(p, [1 length(onset)])];		
		stim.blockNum = [stim.blockNum repmat((n-1)*nPositions + p, [1 length(onset)])];
	end
end

% add post-stim events, end of run
stim.onset(end+1) = stim.onset(end) + poststimSecs;
stim.position(end+1) = 0;
stim.direction(end+1) = 0;
stim.image{end+1} = 'blank';

% add blank periods if requested
if addBlanks==1
	secsPerBlankCycle = length(directions) * secsPerBlock / nBlankCycles;
	cutoff = secsPerBlankCycle - nBlankSecs; % after this point in each cycle, stim is off
	Ioff = find( mod(stim.onset-prestimSecs, secsPerBlankCycle) >= cutoff );
	stim.position(Ioff) = 0;
	stim.image(Ioff) = {'blank'};
end

% write the scripts
% make sure the script directory exists
scriptDir = fullfile(codeDir, 'Scripts');
ensureDirExists(scriptDir);

scriptPath = fullfile(scriptDir, sprintf('%s_%i.txt', saveName, N));
writeScript(stim, scriptPath);


%%%%% save images, script for phase-scrambled stimuli
%% make and save the images (scrambled images)
saveDir = fullfile(imageDir, [saveName '_' num2str(N) '_scrambled']);
mkdir(saveDir);

% scramble the images before masking
imgs = phaseScramble(imgs);

% mask through bars
bars = barApertureMask(imgs, directions, nStepsPerDirection);

% save each image
for ii = 1:size(bars, 3)
	d = ceil(ii / (nStepsPerDirection * nImagesPerStep)); % direction index
	tmp = mod( ii-1, nStepsPerDirection * nImagesPerStep ) + 1;
	p = ceil( tmp / nImagesPerStep );
	j = mod( tmp-1, nImagesPerStep) + 1;   % image index
	imgName = sprintf('%03.0fdeg-%02.0f-%i.png', directions(d), p, j);
	imgPath = fullfile(saveDir, imgName);
	imwrite(bars(:,:,ii), imgPath);
	fprintf('Saved %s.\n', imgPath);
end

%% create the script (intact images)
% get a vector of the position for each image
for ii = 1:size(bars, 3)
	tmp = mod( ii-1, nStepsPerDirection * nImagesPerStep ) + 1;
	position(ii) = ceil( tmp / nImagesPerStep );
	
	d = ceil(ii / (nStepsPerDirection * nImagesPerStep));
	barDirection(ii) = directions(d);
end

%% set up the scripts
% first we set up the no-blanks script, then the blanks one
stim.onset = 0;  % onset in seconds since run start: initialize 
stim.image = {'blank'}; 
stim.blockNum = 0; 
stim.direction = 0;
stim.position = 0;

startTime = prestimSecs;

for n = 1:length(directions)	
	for p = 1:nStepsPerDirection
		% get the set of images for this position and direction
		I = find(barDirection==directions(n) & position==p);
		imlist = {};
		for j = 1:nImagesPerStep
			imgName = sprintf('%03.0fdeg-%02.0f-%i.png', directions(n), p, j);
			imlist{j} = fullfile(saveDir, imgName);
		end
			
		% set the timing for each frame in imlist
		onset = linspace(0, secsPerPosition, nImagesPerStep+1) + startTime;
		onset = onset(1:end-1);  % last onset is start of next position	
		startTime = startTime + secsPerPosition;		
		
		% add to the stimulus struct
		stim.onset = [stim.onset onset];
		stim.image = [stim.image imlist];
		stim.direction = [stim.direction repmat(directions(n), [1 length(onset)])];		
		stim.position = [stim.position repmat(p, [1 length(onset)])];		
		stim.blockNum = [stim.blockNum repmat((n-1)*nPositions + p, [1 length(onset)])];
	end
end

% add post-stim events, end of run
stim.onset(end+1) = stim.onset(end) + poststimSecs;
stim.position(end+1) = 0;
stim.direction(end+1) = 0;
stim.image{end+1} = 'blank';

% add blank periods if requested
if addBlanks==1
	secsPerBlankCycle = length(directions) * secsPerBlock / nBlankCycles;
	cutoff = secsPerBlankCycle - nBlankSecs; % after this point in each cycle, stim is off
	Ioff = find( mod(stim.onset-prestimSecs, secsPerBlankCycle) >= cutoff );
	stim.position(Ioff) = 0;
	stim.image(Ioff) = {'blank'};
end

% write the script
scriptPath = fullfile(scriptDir, sprintf('%s_%i_scrambled.txt', saveName, N));
writeScript(stim, scriptPath);


return
% /--------------------------------------------------------------/ %


% /--------------------------------------------------------------/ %
function writeScript(stim, pth);
%% write out a script file
fid = fopen(pth, 'w');

% write the header
fprintf(fid, 'Script for face bar pRF mapping experiments\n');
fprintf(fid, 'Run length: %3.2f seconds, %3.2f frames (if TR=2)\n', ...
            stim.onset(end), stim.onset(end)/2);
fprintf(fid, '\n'); 

% column headers
fprintf(fid, 'Block # \tOnset Time, sec \tBar Direction \tBar Position \tImage\n');

% write the main body of the script
for i = 1:length(stim.blockNum)
    fprintf(fid, '%i \t%3.2f \t', stim.blockNum(i), stim.onset(i));
    fprintf(fid, '%i \t%i \t',  stim.direction(i), stim.position(i));
    fprintf(fid, '%s \n', stim.image{i});
end

% finish up
fprintf(fid, '*** END OF SCRIPT ***\n');
fclose(fid);

fprintf('Wrote %s.\n', pth);

return