function [movieFrames,nFrames] = makeMovingWordTrial2(curWordImage,movieParams,fontParams,trialInfo,stimDir)
% This function makes a single trial for the motion words
% experiment based on the condition.  These trials do NOT include the ITI, which will be controlled separately by
% the seqtiming variable when you run the scan.  A given trial is made up
% of the images created by makeMoveDotForm.  It can also just return an
% image of a particular stimulus that is read in from a file (e.g. case
% NormalWords).
%
%   movieFrames = makeMovingWordTrial2(curWordImage,movieParams,fontParams,trialInfo,[stimDir])
%
% curWordImage: image created e.g. by rendering text; same as "form"
% movieParams: made from initWordParams; controls movie properties
% trialInfo: structure that contains current condition name (trialInfo.conditionName), and stimulus
%   name (trialInfo.stimName) in the case of reading in from a file
% stimDir: directory containing files with stimulus pictures
%
% Note: Format the parFiles as follows:
%       Ex.     MW_mot-100.lum-100_Words
%               MW_pmot-90.pmot-50_NW
%               CE_in-255.out-128_Words
%               S_MW_mot-100.lum-100_Words - s prefix indicates scrambling
%               MW_mot-100.lum-100.static_Words, static @ mot coh 1, lum coh 1
%               PS_level-80_Words, phase scrambled at .8
%               ROT-60_CE_in-255.out-128_Words - rot prefix indicates rotation by xx degrees counterclockwise (in this case 60deg)
%
%       Separate each parameter command by a semicolon, and the parameter
%       and the value by a comma.  The last just indicates whether it was
%       a word, scrambled image, or nonword (doesn't affect rendering, but
%       good for record keeping).
%
% written by amr Dec 16, 2008
% RFB 2009 [renobowen@gmail.com]
%

%% Make movies out of the rendered images
numRefreshesPerFrame = round(movieParams.frameDuration * movieParams.display.frameRate);
framesPerStim = round((movieParams.display.frameRate * movieParams.duration)/numRefreshesPerFrame);  % how many frames in a trial given frameRate and stim duration

mainTokens = parseString(trialInfo.conditionName,'_'); % decompose string into tokens

% Scramble flag set?
if (lower(mainTokens{1}) == 's')
    curWordImage = wordScrambleImage(curWordImage, 10, 10);
    tmp = cell(1, size(mainTokens, 2) - 1);
    for i = 2:(size(mainTokens, 2))
        tmp{i - 1} = mainTokens{i};
    end
    mainTokens = tmp; % Cut scramble flag from the cell array
    clear tmp;
end

% Rotation of image flag set?
if (strfind(lower(mainTokens{1}), 'rot'))
    param = parseString(mainTokens{1},'-');
    deg = str2double(param{2});
    curWordImage = imrotate(curWordImage, deg);  % rotate the image by deg degrees (pos is counter-clockwise, neg is clockwise)
    
    tmp = cell(1, size(mainTokens, 2) - 1);
    for i = 2:(size(mainTokens, 2))
        tmp{i - 1} = mainTokens{i};
    end
    mainTokens = tmp; % Cut scramble flag from the cell array
    clear tmp;
end

switch lower(mainTokens{1})
    case 'mw' % motion word case
        subTokens = parseString(mainTokens{2},'.');
        for ii = 1:length(subTokens)
            param = parseString(subTokens{ii},'-');
            switch lower(param{1})
                case 'mot'
                    movieParams.motCoherence = str2double(param{2})/100;
                case 'lum'
                    movieParams.lumCoherence = str2double(param{2})/100;
                case 'pmot'
                    movieParams.motCoherence = perfMatch(str2double(param{2})/100,'mot',stimDir);
                case 'plum'
                    movieParams.lumCoherence = perfMatch(str2double(param{2})/100,'lum',stimDir);
                case 'static'
                    framesPerStim = 1;
                case {'informrgb' 'inform' 'in'}
                    movieParams.inFormRGB = ones(1,3)*str2double(param{2});
                case {'outformrgb' 'outform' 'out'}
                    movieParams.outFormRGB = ones(1,3)*str2double(param{2});
                case {'noisergb' 'noise'}
                    movieParams.noiseRGB = ones(1,3)*str2double(param{2});
                case {'informdir'}
                    movieParams.dotDir(1) = str2double(param{2});
                case {'outformdir'}
                    movieParams.dotDir(2) = str2double(param{2});
                case 'rect'  % change curWordImage to a rectangle (randomly placed), rather than a word
                    [formIndsX formIndsY] = find(curWordImage==1);
                    curWordImage = zeros(size(curWordImage));
                    curWordImage(min(formIndsX):max(formIndsX) , min(formIndsY):max(formIndsY)) = 1;
                    
%                     rectSize = round(size(curWordImage)*0.40);  % size of rectangle is 40% of total stimulus size in each direction
%                     topEdge = ceil(rand*( (size(curWordImage,1)-rectSize(1)) )); % random top edge
%                     leftEdge = ceil(rand*( (size(curWordImage,2)-rectSize(2)) ));  % random left edge
%                     curWordImage = zeros(size(curWordImage));
%                     curWordImage(topEdge:(topEdge+rectSize(1)) , leftEdge:(leftEdge+rectSize(2))) = 1;
                    
                otherwise
                    fprintf('Unrecognized Parameter - Main Token: %s - %s, %s',mainTokens{1},param{1},param{2});
            end
        end
        mov = makeMoveDotForm(curWordImage, movieParams,framesPerStim);
    case 'ps' % phase scrambled case
        subTokens = parseString(mainTokens{2},'.');
        for ii = 1:length(subTokens)
            param = parseString(subTokens{ii},'-');
            switch lower(param{1})
                case 'level'
                    scrambleLevel = str2double(param{2})/100;
                otherwise
                    error('Unrecognized Parameter - Main Token: %s - %s, %s',mainTokens{1},param{1},param{2});
            end
        end
        % Convert into 255s using appropriate grayscales instead of mask
        curWordImage(curWordImage==0) = movieParams.backRGB(1);  % background-- should it be backRGB or outFormRGB?
        curWordImage(curWordImage==1) = movieParams.inFormRGB(1);  % change inForm shade of gray
        mov = scrambleImage(curWordImage,scrambleLevel);
        mov = 255-mov;  % invert to make black text instead of white (let's use this as the default)-- don't need this if you get correct colors first
    case 'ce' % contrast edge case
        subTokens = parseString(mainTokens{2},'.');
        for ii = 1:length(subTokens)
            param = parseString(subTokens{ii},'-');
            switch lower(param{1})
                case {'informrgb' 'inform' 'in'}
                    movieParams.inFormRGB = ones(1,3)*str2double(param{2});
                case {'outformrgb' 'outform' 'out'}
                    movieParams.outFormRGB = ones(1,3)*str2double(param{2});
                otherwise
                    error('\n\n\nUnrecognized Parameter - Main Token: %s - %s, %s\n\n\n',mainTokens{1},param{1},param{2});
            end
        end
        mov = zeros(size(curWordImage,1),size(curWordImage,2), 3);
        red = double(curWordImage);
        red(red == 0) = 1000;
        red(red == 1) = movieParams.inFormRGB(1);
        red(red == 1000) = movieParams.outFormRGB(1);
        
        green = double(curWordImage);
        green(green == 0) = 1000;
        green(green == 1) =  movieParams.inFormRGB(2);
        green(green == 1000) = movieParams.outFormRGB(2);
        
        blue = double(curWordImage);
        blue(blue == 0) = 1000;
        blue(blue == 1) =  movieParams.inFormRGB(3);
        blue(blue == 1000) = movieParams.outFormRGB(3);
        
        mov(:,:,1) = uint8(red);
        mov(:,:,2) = uint8(green);
        mov(:,:,3) = uint8(blue);
%         for ii = 1:3
%             [x,y] = (mov(:,:,ii) == 0);
%             mov(,ii) = 1000;  % need an intermediate so we don't overwrite other values
%             mov(mov(:,:,ii) == 1,ii) = movieParams.inFormRGB(ii);
%             mov(mov(:,:,ii) == 1000,ii) = movieParams.outFormRGB(ii);
%         end
%              curWordImage(curWordImage == 0) = 1000;  % need an intermediate so we don't overwrite other values
%         curWordImage(curWordImage == 1) = movieParams.inFormRGB(1);
%         curWordImage(curWordImage == 1000) = movieParams.outFormRGB(1);        
        
    otherwise
        error('Unrecognized Main Token: %s',mainTokens{1});
        return;
end

nFrames = size(mov,4);  % differs according to whether it's a still frame stimulus or movie stimulus
movieFrames = cell(nFrames);
for frameIndex=1:nFrames, movieFrames{frameIndex} = mov(:,:,:,frameIndex); end

return

function thresh = perfMatch(perf,var,stimDir)
% If var = 'mot', will load a motPerf.mat that contains the analysis
% structure to assist in performance matching.
load(fullfile(stimDir,[var 'Perf.mat']));

arg     = -log((analysis.flake-perf)/(analysis.flake-analysis.guess));
threshy = 1-(1-analysis.guess)*exp(-1);	% 0.8161 for 0.5 guess rate
k       = (-log( (1-threshy)/(1-analysis.guess) ))^(1/analysis.slope);
thresh  = (analysis.thresh/k)*nthroot(arg,analysis.slope);

return