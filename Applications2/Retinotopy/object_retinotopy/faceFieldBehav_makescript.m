function stim = faceFieldBehav_makescript(varargin);
% Save face-field images and scripts for behavioral tests of the face field
% stimuli.
%
%       stim = faceFieldBehav_makescript('param', [val], ...);
%
% This stimulus was motivated by a need to test how well subjects could see
% the faces while presenting the face field stimuli in the scanner. I
% evaluate the subjects' ability to see the faces by having them perform a
% gender-discrimination task on the same sorts of stimuli, presented at the
% same visual size, outside the scanner. 
%
% The task is set up like this: for each trial, a single bar at a single
% position flashes on and off in the screen while the subject fixates. The
% bar will contain face field images like the facefield_run stimuli. Unlike
% those stimuli, these faces will be either all male or all female for a
% given trial. The subject has to judge the gender of the faces. I analyze
% the subjects' ability to do this gender discrimination task as a function
% of bar position. 
%
% My hope is, the subjects were all pretty good at judging the gender of
% the faces even for more peripheral positions.
%
% ras, 11/30/2009.

%% params
stim.orientations = [90]; % set of bar directions to generate (° CW from vertical)
stim.nSteps = 12; % # image positions per bar direction
stim.trialsPerStep = 10;   % # images for each position
stim.trialDur = 2;        % trial duration in secs
stim.baseSize = 30;		  % radius of foveal face in pixels
stim.scaleFactor = 2;	  % scaling of face size with eccentricity
stim.prestimSecs = 2;      % seconds before stimuli are presented in each run
stim.poststimSecs = 0;     % seconds after stimuli are presented in each run
stim.screenRes = [1200 1200];  % size of images to generate ([X Y])
stim.saveName = 'scale_factor_2_behav';  % name of image set, script: should be descriptive
stim.nRuns = 4;           % number of runs to generate


% parse any optional parameters
for ii = 2:2:length(varargin)
    param = varargin{ii-1};
    val = varargin{ii};
    stim.(param) = val;
end

%% get path of directory in which to save images
codeDir = fileparts(which(mfilename));
imageDir = fullfile(codeDir, 'FaceFieldBehavImages');
ensureDirExists(imageDir);


%%%%%% make and save the images 
for r = 1:stim.nRuns
    
    %% make and save the face field images
    % ensure the directory exists for this set
    % we choose a number for this set, based on the number of existing
    % directories already exist with the same save prefix:
    N = 1;
    saveDir = fullfile(imageDir, [stim.saveName '_' num2str(N)]);
    while exist(saveDir, 'dir')
        N = N + 1;
        saveDir = fullfile(imageDir, [stim.saveName '_' num2str(N)]);
    end
    mkdir(saveDir);

    % we make both male and female face fields for each set of trials;
    % this way, for a given trial (one bar position within this loop),
    % we can flip a coin and use either the m or f face field,
    % independent of the other bar positions.

    % make the un-masked face field images
    M = faceField(stim.scaleFactor, stim.trialsPerStep, ...
                 'baseSize', stim.baseSize, 'gender', 'm');
    F = faceField(stim.scaleFactor, stim.trialsPerStep, ...
                 'baseSize', stim.baseSize, 'gender', 'f');

    % mask through bars
    barsM = barApertureMask(M, stim.orientations, stim.nSteps);
    barsF = barApertureMask(F, stim.orientations, stim.nSteps);

    % save each image
    for ii = 1:size(barsM, 3)
        d = ceil(ii / (stim.nSteps * stim.trialsPerStep)); % direction index
        tmp = mod( ii-1, stim.nSteps * stim.trialsPerStep ) + 1;
        p = ceil( tmp / stim.trialsPerStep );
        j = mod( tmp-1, stim.trialsPerStep) + 1;   % image index
        
        % save the male-faces image
        imgName = sprintf('m-%03.0fdeg-%02.0f-%i.png', stim.orientations(d), p, j);
        imgPath = fullfile(saveDir, imgName);
        imwrite(barsM(:,:,ii), imgPath);
        fprintf('Saved %s.\n', imgPath);
        
        % save the female-faces image
        imgName = sprintf('f-%03.0fdeg-%02.0f-%i.png', stim.orientations(d), p, j);
        imgPath = fullfile(saveDir, imgName);
        imwrite(barsF(:,:,ii), imgPath);
        fprintf('Saved %s.\n', imgPath);
    end

    %% create the script for this run
    % set up the scripts
    stim.trialNum = 0; 
    stim.onset = 0;  % onset in seconds since run start: initialize 
    stim.orientation = 0;
    stim.position = 0;
    stim.gender = '-'; % null trial: no gender assigned
    stim.image = {'blank'}; 

    % the 'onset' variable will be a counter for the onset of each event,
    % starting after the pre-stim blank period.
    onset = stim.prestimSecs;
    
    % set up a sequence of trials, each defined by the bar orientation,
    % position, and which subset of images (1:stim.trialsPerStep) to use.
    [ori pos img] = meshgrid(stim.orientations, 1:stim.nSteps, 1:stim.trialsPerStep);
    ori = ori(:)';  pos = pos(:)';  img = img(:)';   % make row vectors
    
    % shuffle the order of conditions -- this will determine the trial
    % order:
    nTrials = length(ori);
    shuffledOrder = shuffle(1:nTrials);
    ori = ori(shuffledOrder);
    pos = pos(shuffledOrder);
    img = img(shuffledOrder);
    
    % for ecah trial, randomly choose a male or female face stimulus, and
    % add the trial to the stimulus structure.
    for trial = 1:nTrials
        if round(rand), gender = 'm';
        else,           gender = 'f';
        end
        
        stim.trialNum(end+1) = trial;               
        stim.onset(end+1) = onset;
        stim.orientation(end+1) = ori(trial);
        stim.position(end+1) = pos(trial);		
        stim.gender(end+1) = gender;
        
        imgName = sprintf('%s-%03.0fdeg-%02.0f-%i.png', gender, ...
                          ori(trial), pos(trial), img(trial));
        imgPath = fullfile(saveDir, imgName);
        if ~exist(imgPath, 'file')
            error('Oops! Invalid image path: %s', imgPath)
        end
        stim.image = [stim.image imgPath];
        
        onset = onset + stim.trialDur;
    end
    

    % add post-stim events, end of run
    stim.trialNum(end+1) = -1;
    stim.onset(end+1) = stim.onset(end) + stim.poststimSecs;
    stim.position(end+1) = 0;
    stim.orientation(end+1) = 0;
    stim.gender(end+1) = '-';
    stim.image{end+1} = 'blank';

    % write the scripts
    % make sure the script directory exists
    scriptDir = fullfile(codeDir, 'Scripts');
    ensureDirExists(scriptDir);

    scriptPath = fullfile(scriptDir, sprintf('%s_%i.txt', stim.saveName, N));
    writeScript(stim, scriptPath);
end



return
% /--------------------------------------------------------------/ %




% /--------------------------------------------------------------/ %
function writeScript(stim, pth);
%% write out a script file
fid = fopen(pth, 'w');

% write the header
fprintf(fid, 'Script for face field behavioral experiments\n');
fprintf(fid, 'Run length: %3.2f seconds\n', stim.onset(end));
fprintf(fid, '\n'); 

% column headers
fprintf(fid, 'Trial # \tOnset Time, sec \tBar Orientation \tBar Position \tFace Gender \tImage\n');

% write the main body of the script
for i = 1:length(stim.trialNum)
    fprintf(fid, '%i \t%3.2f \t', stim.trialNum(i), stim.onset(i));
    fprintf(fid, '%i \t%i \t',  stim.orientation(i), stim.position(i));
    fprintf(fid, '%s \t%s \n', stim.gender(i), stim.image{i});
end

% finish up
fprintf(fid, '*** END OF SCRIPT ***\n');
fclose(fid);

fprintf('Wrote %s.\n', pth);

return

