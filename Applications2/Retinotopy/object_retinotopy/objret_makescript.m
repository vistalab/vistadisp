function stim = objret_makescript(varargin);
%
% stim  = objret_makescript(varargin);
%
% Create a series of scripts for object bar retinotopy experiments. These scripts
% provide a description of each object bar experiment, down to the precise
% presentation time of each image.
%
% This is designed to run without input arguments; however, the default
% parameters can be overridden by specifying 'parameter', [value] pairs as
% input arguments.
%
% Before running this, you must run saveobjectBarImages, which generates sets
% of images containing object bars. 
%
% Two runs are generated, one containing intervening blanks and one without 
% them. These are saved in the Scripts/ subfolder where the code resides
% (made if it doesn't exist). They are named with the format:
%	objectbar_noblanks_[set].txt
%	objectbar_blanks_[set].txt
% 
% Returns a structure containing script information for each run.
%
% ras, 07/2008.

%% params
category = 'house'; % category name
set = 1;    % image set from saveobjectBarImages
displayHz = 60; % screen refreshes/s for the display: determines timing
secsPerBlock = 24; % seconds per 'block': each block is 1 bar sweep
nPositions = 12;   % # positions per bar sweep: should match image files
prestimSecs = 12;   % # seconds before 1st bar sweep
poststimSecs = 0;  % # seconds after last bar sweep
nBlankCycles = 4;  % # on/off blank cycles for the w/blanks script
nBlankSecs = 12;   % duration of blanks in each blank cycle
backAndForth = 0;  % flag for back-and-forth object motion at each position

% the directions from which each bar moves: start coming from the left
% (270 deg), then precess counterclockwise by 135 degree steps (same as 
% 225 deg clockwise). This matches the directions in the ret code.
directions = mod(270:225:1845, 360 );


%% parse the input arguments
for ii = 1:2:length(varargin)
	eval( sprintf('%s = %s', varargin{ii}, num2str(varargin{ii+1})) );
end

%% check that the images directory is there, get params from images
% make sure the category name is capitalized
category = lower(category);  category(1) = upper(category(1));

codeDir = fileparts(which(mfilename));
imageDir = fullfile(codeDir, 'ObjectBarImages', category, sprintf('Set%i', set));

if ~exist(imageDir, 'dir')
	error( sprintf('Couldn''t find image directory: %s.', imageDir) );
end

% count the saved images
w = dir(fullfile(imageDir, '*deg*'));
nFiles = length(w);

% parse each image name to get a set of unique directions and separate
% image frames within each direction
for n = 1:nFiles
	barDirection(n) = str2num(w(n).name(1:3));
	imgFrame(n) = str2num(w(n).name(8:10));
end

% check that the directions in the save files matches those specified in
% directions:
if ~isequal( unique(barDirection), unique(directions) )
	error('The bar directions in the image files and code don''t match.')
end

% how many images per position?
imgsPerPosition = max(imgFrame) / nPositions;
secsPerPosition = (secsPerBlock / nPositions);

% in our stimuli, we'll do 2 cycles at each position, one in either
% direction (so we get both directions of motion, back and forth), so there
% are twice as many frames as images per position
if backAndForth==1
	framesPerPosition = 2 * imgsPerPosition;
else
	framesPerPosition = imgsPerPosition; % alternate: no back-and-forth motion
end

% get a vector of the position for each image
for n = 1:nFiles
	position(n) = ceil( imgFrame(n) / imgsPerPosition );
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
	for p = 1:nPositions
		% get the set of images for this position and direction
		I = find(barDirection==directions(n) & position==p);
		imlist = {};
		for j = 1:imgsPerPosition
			imlist{j} = fullfile(imageDir, w(I(j)).name);
		end
		
		if backAndForth==1
			% create a back-and forth cycle across images:
			% if we play all the images in order, the objects will always precess
			% in a particular direction. To make this more balanced, I have it
			% alternate back and forth (the order of the directions in itself
			% alternates between odd and even positions: first
			% backward/forward, then forward/backward... it's complicated, but
			% there's a reason.)
			if mod(p, 2)==1
				imlist = [fliplr(imlist) imlist];
			else
				imlist = [imlist fliplr(imlist)];
			end
		end
		
		% set the timing for each frame in imlist
		onset = linspace(0, secsPerPosition, framesPerPosition) + ...
				startTime;
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

% set up the blanks script: first, copy the no-blanks version:
stim(2) = stim(1);

% now, add the blanks
secsPerBlankCycle = length(directions) * secsPerBlock / nBlankCycles;
cutoff = secsPerBlankCycle - nBlankSecs; % after this point in each cycle, stim is off
Ioff = find( mod(stim(2).onset-prestimSecs, secsPerBlankCycle) >= cutoff );
stim(2).position(Ioff) = 0;
stim(2).image(Ioff) = {'blank'};

%% write the scripts
% make sure the script directory exists
scriptDir = fullfile(codeDir, 'Scripts');
ensureDirExists(scriptDir);

scriptPath = fullfile(scriptDir, sprintf('%sbar_noblanks_%i.txt', lower(category), set));
writeScript(stim(1), scriptPath);

scriptPath = fullfile(scriptDir, sprintf('%sbar_blanks_%i.txt', lower(category), set));
writeScript(stim(2), scriptPath);

return
% /--------------------------------------------------------------/ %


% /--------------------------------------------------------------/ %
function writeScript(stim, pth);
%% write out a script file
fid = fopen(pth, 'w');

% write the header
fprintf(fid, 'Script for object bar pRF mapping experiments\n');
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