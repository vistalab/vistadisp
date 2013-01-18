function slidingFace_makescript(N, varargin);
% Generates and saves a series of scripts for use in the single-bar experiment.
%
%  slidingFace_makescript([N=1], [options]);
%
% This experiment is designed to test predictions from our scaled-faces pRF
% mapping experiment. The objective is to place a single bar aperture at a
% fixed location of the visual field, and have a face slide back and forth
% behind it. [...]
%
% N refers to the image set to use. [default 1]  Script names will be saved
% as 'single_bar_test_[N]_[run#].txt' in the code/Scripts folder.
%
% This code makes one set of images, and one corresponding script, at a
% time.
%
% ras, 04/2009.
if notDefined('N'),		N = 1;						end

%% script params
faceSize = 600;       % size of face in pixels
barWidth = 83;		  % bar size in pixels
framesPerSec = 6;
nPosCycles = 6;		  % # of position cycles per run
positionPeriod = 30;  % seconds for one back-and-forth cycle of the face position
idPeriod = 18;		  % seconds between changes in face identity
prestimSecs = 12;     % seconds before stimuli are presented in each run
poststimSecs = 12;    % seconds after stimuli are presented in each run
maxCenter = 208;        % maximum distance of face center from aperture (pixels)
saveName = 'sliding_face';   % prefix for scripts

for ii = 1:2:length(varargin)
    param = varargin{ii};
	val = varargin{ii+1};
    if ischar(val)
        eval( sprintf('%s = ''%s''', param, val) )
    else
        eval( sprintf('%s = %s', param, num2str(val)) )
    end
end

% derived params
secsPerRun = nPosCycles * positionPeriod + prestimSecs + poststimSecs;
mainCycleFrames = nPosCycles * positionPeriod * framesPerSec;

framesPerIDCycle = framesPerSec * idPeriod;
framesPerPosCycle = framesPerSec * positionPeriod;

nFaces = ceil( nPosCycles * positionPeriod / idPeriod ); % # individual faces needed

% 'xPos' indicates the face X-axis center for each frame in the position
% cycle. This will be used to mark the impliced face position in the
% scripts (and may be useful if we want to have a position judement task).
% Since the face moves back and forth, I create two half-cycles and paste
% them together.
% maxCenter = 170; % conservative; the bar is always filled (the ears are
%                  % just visible)
% maxCenter = 300; % the face slides well past the aperture -- useful if we're
%                  % making scripts where the motion is unidirectional
xPos = linspace(-maxCenter, maxCenter, framesPerPosCycle);
xPos = linspace(-maxCenter, maxCenter, framesPerPosCycle/2);
xPos = [xPos fliplr(xPos)]; % first left -> right, then right -> left

%% get path of directory in which to save scripts
codeDir = fileparts(which(mfilename));
imageDir = fullfile(codeDir, 'SlidingFaceImages');
ensureDirExists(imageDir);
imageDir = fullfile(codeDir, 'SlidingFaceImages');
if notDefined('N')
	% add a new image set to the pre-existing image sets
	N = 1;
	while exist( fullfile(imageDir, [saveName '_' num2str(N)]), 'dir' )
		N = N + 1;
	end
end
saveDir = fullfile(imageDir, [saveName '_' num2str(N)]);
ensureDirExists(saveDir);

% get a list of all available faces
mf = 'mf';  % gender codes
mFaces = faceDBFolders('m'); % count male faces
fFaces = faceDBFolders('f'); % count female faces
nUnique = min(length(mFaces), length(fFaces));


%% set up the script
stim.onset = 0;  % onset in seconds since run start: initialize 
stim.image = {'blank'}; 
stim.posCycle = 0; % count the cycle for the  
stim.idCycle = 0; 
stim.cond = 0;  % face ID; 0 for blank, >0 for a face (id in database)
stim.gender = 'b'; % 'b' for blank, 'm' for male, 'f' for female
stim.pos = 0; % face center: 0=fovea, +=right, -=left (pixels)

%% figure out which faces to show when
% pick a subset of nFaces from the total list of faces for this run,
% w/o replacement. Also give even chances of male or female faces
rand('state', sum(100 * clock));
faceList = {};
while length(faceList) < nFaces
    subMFaces = Shuffle(mFaces);
    subFFaces = Shuffle(fFaces);
    faceList = [faceList subMFaces(1:nUnique) subFFaces(1:nUnique)];
end
faceList = Shuffle(faceList);
faceList = faceList(1:nFaces);


% get a numeric ID for each face
for ii = 1:length(faceList)
    [p dirname] = fileparts(faceList{ii});
    underscore = strfind(dirname, '_');
    faceIDs(ii) = str2num( dirname(1:underscore(1)-1) );
    faceGender(ii) = dirname(underscore(1)+1);
end

% we make a vector with one element per image frame, indicating which
% face ID will shown for which frame. We also make an onsets vector to
% go with each frame.
stim.onset = [0 linspace(0, nPosCycles * positionPeriod, mainCycleFrames) + prestimSecs];
stim.cond = repmat(faceIDs, [framesPerIDCycle 1]);
stim.cond = [0 stim.cond(1:mainCycleFrames)];

if length(stim.cond) ~= length(stim.onset)
    % let's debug it
    warning('Whoops...')
    keyboard
end


%% add the main cycles
% in the main loop, we iterate across "face ID" cycles -- stretches
% where the same individual face is shown. This may appear a little
% complicated, but it helps the memory footprint, since we're only
% dealing with loading / saving images of one face at a time.
posOffset = 0; % index of images in the pos cycle -- see below
for f = 1:nFaces
    %%%%% generate and save the masked-face images
    % load the face
    face = loadFacesByID(faceIDs(f), 0, faceSize);

    % make it move behind a horizontal aperture (right to left)
    frames = moveImageBehindBar(face{1}, 90, framesPerPosCycle/2, barWidth, xPos);

    % for the full cycle, it rocks back and forth: right to left, and
    % save each frame as a separate image
    for jj = 1:size(frames, 3)
        g = faceGender(f);
        id = faceIDs(f);
        pos = xPos(jj);
        fname = sprintf('face%03.0f-%s-%i-%03.0f.png', f, g, id, pos);
        imlist{jj} = fullfile(saveDir, fname);
        imwrite( frames(:,:,jj), imlist{jj}, 'png' );
        fprintf('Saved %s.\n', imlist{jj});
    end

    %%%%% create entries for each frame in the script
    % The images we just saved show the face moving from left to right
    % one time. For this face ID cycle, we want part (but not all) of a
    % position cycle, where it rocks back and forth. We will re-use the
    % same image if that position comes up twice.  

    %% first, generate a set of vectors representing a complete position cycle
    % For the position cycle, it rocks back and forth: right to left, and
    % left to right. Also, let's phase-shift it to start in the fovea,
    % moving right (so it's in the R.V.F. for the first half-cycle, and
    % the L.V.F. for the second half-cycle).
    frameOrder = [1:framesPerPosCycle/2 framesPerPosCycle/2:-1:1];
    frameOrder = circshift(frameOrder(:), framesPerPosCycle/4)';

    % index the image list we generated above so that it reflects the
    % position cycle
    imlist = imlist(frameOrder);

    %% Next, sub-select those entries which correspond to this ID
    %% cycle.
    % because the position cycle is longer than the ID cycle, we don't
    % need all the frames we generated here. We figure out what frames
    % to take based on where we left off for the last ID cycle -- so
    % that although the face changes identity, the position of the face
    % continues to change smoothly.
    frameIndex = posOffset + [1:framesPerIDCycle]; % frames in whole run
    whichFrames = mod(frameIndex-1, framesPerPosCycle) + 1; % frames from the current images

    % update the position index offset for the next ID cycle
    posOffset = posOffset + framesPerIDCycle;

    % the last face ID cycle may be cut off, since each run doesn't
    % require an integer number of these (only integer position cycles). 
    % Trim the extra frames. 
    if f==nFaces & mod(mainCycleFrames, framesPerIDCycle) > 0
        partialCycle = 1:mod(mainCycleFrames, framesPerIDCycle);
        whichFrames = whichFrames(partialCycle);
    end

    % sub-select the image files for this cycle
    imlist = imlist(whichFrames);

    % mark the image file, and its related properties, in the stim
    % struct. 
    for ii = 1:length(imlist)
        % we convert the index ii (list of current face images) into
        % the event index jj (what event in the script is it?) -- the
        % +1 accounts for the prestim onset event.
        jj = frameIndex(ii) + 1; 
        stim.image{jj} = imlist{ii};	
        stim.posCycle(jj) = ceil(jj / framesPerPosCycle); 
        stim.idCycle(jj) = f; 
        stim.gender(jj) = faceGender(f); 
        stim.pos(jj) = xPos(whichFrames(ii)); 			
    end

end

% add post-stim events, end of run
stim.onset(end+1) = stim.onset(end); % + 1/framesPerSec;
stim.cond = [stim.cond 0];
stim.pos = [stim.pos 0];	
stim.gender = [stim.gender 'b'];
stim.posCycle = [stim.posCycle nPosCycles+1];		
stim.idCycle = [stim.idCycle nFaces+1];
stim.image = [stim.image {'blank'}];		

if poststimSecs > 1
    stim.onset(end+1) = stim.onset(end) + poststimSecs;
    stim.cond = [stim.cond 0];
    stim.pos = [stim.pos 0];	
    stim.gender = [stim.gender 'b'];
    stim.posCycle = [stim.posCycle nPosCycles+1];		
    stim.idCycle = [stim.idCycle nFaces+1];
    stim.image = [stim.image {'blank'}];		
end

% write the scripts
% make sure the script directory exists
scriptDir = fullfile(codeDir, 'Scripts');
ensureDirExists(scriptDir);

[p f ext] = fileparts(saveDir);
scriptPath = fullfile(scriptDir, sprintf('%s.txt', f));
writeScript(stim, scriptPath);


return
% /--------------------------------------------------------------/ %


% /--------------------------------------------------------------/ %
function writeScript(stim, pth);
% write out a script file
fid = fopen(pth, 'w');

% write the header
fprintf(fid, 'Script for sliding faces experiment\n');
fprintf(fid, 'Run length: %3.2f seconds, %3.2f frames (if TR=1.5)\n', ...
            stim.onset(end), stim.onset(end)/1.5);
fprintf(fid, '\n'); 

% column headers
fprintf(fid, ['Position Cycle \tOnset Time, sec \tFace ID Cycle \t' ...
			  'Face ID # \tImplied Face Center (X) \tFace Gender \tImage File \n']);

% write the main body of the script
for i = 1:length(stim.onset)
    fprintf(fid, '%i \t%3.2f \t', stim.posCycle(i), stim.onset(i));
    fprintf(fid, '%i \t%i \t', stim.idCycle(i), stim.cond(i));	
    fprintf(fid, '%i \t%s \t',  round(stim.pos(i)), stim.gender(i));
    fprintf(fid, '%s \n', stim.image{i});
end

% finish up
fprintf(fid, '*** END OF SCRIPT ***\n');
fclose(fid);

fprintf('Wrote %s.\n', pth);

return
