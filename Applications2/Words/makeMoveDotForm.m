function imgForm = makeMoveDotForm(form, sp, numFrames)
% Create a movie clip of dots inside the form
%
%  makeMoveDotForm2(form, stimParams)
%
% Inputs:
%  form:  Entries where form == 1 define the shape where we place the
%  moving dots
%  stimParams:  a struct containing (at least) the following fields
%       coherence:  Dot luminance coherence
%       dotDensity: Dot density
%       inFormRGB,outFormRGB: Dot colors within and outside the form
%       backRGB: Background color
%       noiseRGB: Noise dots' color
%       inFormDir, outFormDir:  Motion direction of inForm and outForm dots in deg.  (0 = hor 90 = vert)
%       numFrames:  Total frames in the movie (duration = nFrames*frameRate)
%
% Returned arguments:
%  img:  A movie sequence of the form and background dots
%  cmap: Color map for the movie
%
% Examples:
%    
%
% Author: Dougherty, Rauschecker
%
% 
% val = movieGet(stimParams,'varName');
% 
% inFormRGB  = movieGet(stimparams,'inFormRGB');
% stimParams = movieSet(stimParams,'inFormRGB',[1 0 0]);
% stimParams = movieCreate;

% TODO
%  1. Get rid of cmap and RGB values.  We're only making a movie of 0s and
%  1s
%  2. Only do one loop.  We only want to see moving dots inside the word
%  form.  
%  3. 

% [stimParams, stairParams] = initWordParams('psychophysics');
% mClip = makeMoveDotForm2(form, stimParams);

%% Test vars to calculate motion and luminance coherence
if strcmp(sp.conditionType,'polar')
    [sp.motCoherence, sp.lumCoherence] = cCompute(sp.polarDistance,sp.polarAngle);
end

%% Reassign variable names from stimParams
dp.backCol = 1;
dp.inFormCol = [2 3];
dp.noiseCol = 4;

% Standard dot colors
indRGB{1} = sp.backRGB;
indRGB{2} = sp.outFormRGB;
indRGB{3} = sp.inFormRGB;

%dp.nIndex = dp.noiseCol*10; % start noise indices in a higher number range

% Noise dot colors
n = size(sp.noiseRGB,1);
for i=0:(n-1)
    indRGB{dp.noiseCol+i}=sp.noiseRGB(i+1,:); % indices are now 4, 5, 6, 7, etc
end

formInd = unique(form(:))'; % 8 ms

%% 
% dotSize = 4;
[dp.stimHigh,dp.stimWide] = size(form);
dp.numDots = round(length(form(:)).*sp.dotDensity);
allDots = 1:dp.numDots;

% Compute number of signal dots based on coherence values
dp.motNumSig = floor(sp.motCoherence*dp.numDots);
dp.lumNumSig = floor(sp.lumCoherence*dp.numDots);

% Compute number of noise dots given the number of signal dots
dp.motNumNoise = dp.numDots-dp.motNumSig;
dp.lumNumNoise = dp.numDots-dp.lumNumSig;

% Make 2 vectors that give the index of signal dots and noise dots.
dp.motSigDots = 1:dp.motNumSig; % 
dp.motNoiseDots = (dp.motNumSig+1):dp.numDots; % 

lumNoiseDotsTMP = randsample(allDots, dp.lumNumNoise); % A random sample of all dots will be luminance noise dots
tmp1 = lumNoiseDotsTMP~=0;
curColor = round(rand(1,sum(tmp1(:)))*(n-1)+1);
tmp2 = zeros(1,dp.numDots);
tmp2(tmp1) = curColor;
for i = 1:n % For each color available in the noiseRGB var
    dp.lumNoiseDots{i} = allDots(tmp2==i);
end

% Allocate the space for a frame of the movie to be generated
% 
% aFrame = ones(dp.stimHigh, dp.stimWide, numFrames, 'uint8'); % 10 ms
% testThis = repmat(form,[1 1 numFrames]); % 30ms
% 
% for i = formInd
%     Ind = find(testThis==i); % 200 ms (form==0), 50 ms (form==1)
%     dp = prepareDots(sp,dp,i); % 8 ms
%     dotLabels = labelDots(dp,numFrames,form,i); % 1150 ms
%     aFrame(Ind)=dotLabels(Ind); % 350 ms (form==0), 5 ms (form==1)
% end

testThis = repmat(form,[1 1 numFrames]);
for i = formInd
    dp = prepareDots(sp,dp,i);
    dotLabels = labelDots(dp,numFrames,form,i);
    if i==0
        aFrame = dotLabels;
    elseif i==1
        Ind = find(testThis==i);
        aFrame(Ind)=dotLabels(Ind);
    end
end

% for i = formInd
%     dp = prepareDots(sp, dp, i);
%     dotLabels = labelDots(dp, numFrames, form, i);
% 
%     for ii = 1:numFrames % 200-300 ms
%         tmpBak = aFrame(:,:,ii);
%         tmpFrm = dotLabels(:,:,ii);
%         tmpBak(form==i) = tmpFrm(form==i);
%         aFrame(:,:,ii) = tmpBak;
%     end
% end

imgForm = paintDots(aFrame, indRGB);

return;