function [movieFrames,nFrames] = makeMovingWordTrial(curWordImage,movieParams,trialInfo,stimDir)
% This function makes a single trial for the motion words
% experiment based on the condition.  These trials do NOT include the ITI, which will be controlled separately by
% the seqtiming variable when you run the scan.  A given trial is made up
% of the images created by makeMoveDotForm.  It can also just return an
% image of a particular stimulus that is read in from a file (e.g. case
% NormalWords).
%
%   movieFrames = makeMovingWordTrial(curWordImage,movieParams,trialInfo,[stimDir])
%
% curWordImage: image created e.g. by rendering text; same as "form"
% movieParams: made from initWordParams; controls movie properties
% trialInfo: structure that contains current condition name (trialInfo.conditionName), and stimulus
%   name (trialInfo.stimName) in the case of reading in from a file
% stimDir: directory containing files with stimulus pictures
%
% written by amr Dec 16, 2008
%

%% Make movies out of the rendered images
numRefreshesPerFrame = round(movieParams.frameDuration * movieParams.display.frameRate);
framesPerStim = round((movieParams.display.frameRate * movieParams.duration)/numRefreshesPerFrame);  % how many frames in a trial given frameRate and stim duration

% These conditions will need to be updated when we figure out the final
% conditions.  For example, we may still want a still luminance dot
% defined condition.  (This is different from a 100Lum0Mot condition,
% in which the dots move but the motion coherence is 0.)
switch trialInfo.conditionName
    case {'Word0Lum100Mot','NW0Lum100Mot'}  % with a cell array, it will go on if any of those cases match
        movieParams.lumCoherence = 0;  % do we want "salt&pepper" here or all black dots?
%         movieParams.inFormRGB = [0 0 0];  % this would be for all black dots
%         movieParams.outFormRGB = [0 0 0];
        movieParams.motCoherence = 0.9;  % ** change this value to match performance between motion and luminance; (originally 1)
        mov = makeMoveDotForm(curWordImage, movieParams,framesPerStim);
    case {'Word50Lum50Mot','NW50Lum50Mot'}
        movieParams.lumCoherence = 0.50;
%         movieParams.inFormRGB = [0 0 0];
%         movieParams.outFormRGB = [0 0 0];
        movieParams.motCoherence = 0.50;
        mov = makeMoveDotForm(curWordImage, movieParams,framesPerStim);
    case {'Word100Lum0Mot','NW100Lum0Mot'}
        movieParams.lumCoherence = 0.6; % ** change this value to match performance between motion and luminance; (originally 1)
        movieParams.inFormRGB = [0 0 0];
        movieParams.outFormRGB = [255 255 255];
        movieParams.motCoherence = 0;
        mov = makeMoveDotForm(curWordImage, movieParams,framesPerStim);
    case {'ContrastEdgeWords','ContrastEdgeNW'}  % no dots, just a picture of a word
        fname = fullfile(stimDir, trialInfo.conditionName, [trialInfo.stimName '.bmp']);  % filename of bmp image
        img2D = imread(fname);  % fname is the full path to a stimulus image to read in
        mov = repmat(img2D,[1 1 3]);  % put the grayscale image into the same format as our other frames; mov here is just a frame
        clear img2D;
    case {'PhaseScrambleWord'}  % take scramble level into account
        fname = fullfile(stimDir, 'PhaseScrambledStims',[trialInfo.conditionName '_' num2str(trialInfo.ScrambleLevelW)], [trialInfo.stimName '.bmp']);  % filename of bmp image
        img2D = imread(fname);  % fname is the full path to a stimulus image to read in
        mov = repmat(img2D,[1 1 3]);  % put the grayscale image into the same format as our other frames; mov here is just a frame
        clear img2D;
    case {'PhaseScrambleNW','PhaseScrambleConsonantString','PhaseScrambleLetterString'}  % different scramble level for nonword
        if trialInfo.ScrambleLevelNW==-1  % -1 means user wants fully phase scrambled words as nonword condition
            fname = fullfile(stimDir, 'PhaseScrambledStims','PhaseScrambleWord_1', [trialInfo.stimName '.bmp']);  % filename of bmp image
        else
            fname = fullfile(stimDir, 'PhaseScrambledStims',[trialInfo.conditionName '_' num2str(trialInfo.ScrambleLevelNW)], [trialInfo.stimName '.bmp']);  % filename of bmp image
        end
        img2D = imread(fname);  % fname is the full path to a stimulus image to read in
        mov = repmat(img2D,[1 1 3]);  % put the grayscale image into the same format as our other frames; mov here is just a frame
        clear img2D;
    case 'luminance'   % no movement, still frame of dots using luminance
        movieParams.lumCoherence = 1;  % 100% luminance coherence
        movieParams.inFormRGB = [0 0 0];
        movieParams.outFormRGB = [255 255 255];
        mov = makeMoveDotForm(curWordImage, movieParams,1); % movie is only 1 frame long, so no motion (still frame)
    case 'MotionControl'
        movieParams.lumCoherence = 1;
        movieParams.inFormRGB = [0 0 0];
        movieParams.outFormRGB = [0 0 0];  % make uniform moving plane of black dots
        movieParams.motCoherence = 1;
        movieParams.dotDir(2) = -movieParams.dotDir(2); % reverse directions
        movieParams.dotDir(1) = movieParams.dotDir(2);  % make inform direction same as outform direction
        mov = makeMoveDotForm(curWordImage, movieParams,framesPerStim); % movie is only 1 frame long, so no motion (still frame)
    case 'LuminanceControl'  % uniform field of static black dots
        movieParams.lumCoherence = 1;  % 100% luminance coherence
        movieParams.inFormRGB = [0 0 0];
        movieParams.outFormRGB = [0 0 0];
        mov = makeMoveDotForm(curWordImage, movieParams,1); % movie is only 1 frame long, so no motion (still frame)
    case {'StaticDotWords','StaticDotNW'}  % static words made of dots
        movieParams.lumCoherence = 0.4;  % % ** change this value to match performance between motion and luminance; (originally 1)
        % we'll keep inFormRGB and outFormRGB to what they're set in initWordParams
        mov = makeMoveDotForm(curWordImage, movieParams,1); % movie is only 1 frame long, so no motion (still frame)
    otherwise
        sprintf('Bad stimOrder file. Condition in stimOrder file not recognized: %s', trialInfo.conditionName)
        return
end

nFrames = size(mov,4);  % differs according to whether it's a still frame stimulus or movie stimulus
for frameIndex=1:nFrames, movieFrames{frameIndex} = mov(:,:,:,frameIndex); end

