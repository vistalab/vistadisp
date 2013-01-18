function img = makeLuminanceDotForm(form, stimParams, numFrames, stillBackground)
% Take a form and create different dot luminances within and outside of the form
% This code mirrors makeMoveDotForm except that here luminance, rather than
% motion, varies with coherence.
%
%  img = makeLuminanceDotForm(form,stimParams,numFrames [, stillBackground])
%
% Input arguments:
%  form:  Entries where form == 1 define the shape.
%  stimParams:  a struct containing (at least) the following fields
%       coherence:  Dot luminance coherence
%       dotDensity: Dot density
%       inFormRGB,outFormRGB: Dot colors within and outside the form
%       backRGB: Background color
%       noiseRGB: Noise dots' color
%  numFrames:  Total frames in the movie (duration = nFrames*frameRate)

%
% Returned arguments:
%  img:  A movie sequence of the form and background dots
%
% Examples:
%
%
% Author: Dougherty, Rauschecker
%

%% Reassign variable names from stimParams %%
coherence = stimParams.lumCoherence;
dotDensity = stimParams.dotDensity;
inFormRGB = stimParams.inFormRGB;
outFormRGB = stimParams.outFormRGB;
backRGB = stimParams.backRGB;
noiseRGB = stimParams.noiseRGB;


%% Check input variables %%
if(~exist('coherence','var') || isempty(coherence)), coherence = 1; end;
if(~exist('form','var') || isempty(form))
    % Default form is a square
    form  = zeros(100,100);
    [x,y] = meshgrid([25:75],[25:75]);
    form(sub2ind(size(form),x,y)) = 1;
end;
if(~exist('dotDensity','var') || isempty(dotDensity)), dotDensity = 0.1; end;
if(~exist('numFrames','var')  || isempty(numFrames)),  numFrames = 2; end;
if(~exist('formLum','var')    || isempty(formLum)),    formLum = 255; end;
if(~exist('backLum','var')    || isempty(backLum)),  backLum = 0; end;
if ~exist('stillBackground','var') || isempty('stillBackground'), stillBackground = 0; end


%% Index to the three color map entries %%
backCol = 0;
inFormCol = 1;
outFormCol = 2;


%% Dot parameters %%
% dotSize = 4;
[stimHigh,stimWide] = size(form);
numDots = round(length(form(:)).*dotDensity);

% These are the number of signal dots
numSig = floor(coherence*numDots);

% The remainder are noise dots
numNoise = numDots-numSig;

% Make 2 vectors that give the index of signal dots and noise dots.
sigDots   = 1:numSig;
noiseDots = (numSig+1):numDots;


%% Initialize images and dots within them %%
%Rect is [L T R B]
% img is the entire background plus form rectangle
% imgForm is just the rectangle containing the form
img     = zeros(stimHigh,stimWide,'int16');
imgForm = zeros(stimHigh,stimWide,'int16');


%% Create dots for the background %%

dotColor = outFormCol;
[aFrame] = makeDotFrame(numDots, numSig, noiseDots, stimHigh, stimWide, dotColor, backCol);

% Repeat the same frame for the whole movie.  This will keep the structure
% of makeMoveDotForm (a movie), but just repeat the same frame.
for ii=1:numFrames;
    img(:,:,ii) = aFrame;
end


%% Create dots for the form (more or less same as above) %%

dotColor = inFormCol;
[aFrame] = makeDotFrame(numDots, numSig, noiseDots, stimHigh, stimWide, dotColor, backCol);

for ii=1:numFrames
    imgForm(:,:,ii) = aFrame;
end


%% Assemble the complete movie from the form and background %%

for ii=1:numFrames
    
    tmpBak = img(:,:,ii);      % Background frame as matrix
    tmpFrm = imgForm(:,:,ii);  % Form frame as a matrix

    % Locations where form == 1 contain the text or form.  We copy the
    % motion from the form movie frame into those locations.
    tmpBak(form==1) = tmpFrm(form==1);

    % Store the result and carry on
    img(:,:,ii) = tmpBak;
    
end


%% Make img into a full-fledged RGB movie %%

aFrame = img(:,:,1);
sz = size(img);
rgbFrameSz = size(aFrame);

% Initialize rgb (contains whole movie) and rgbFrame (first frame of movie)
% In the luminance condition, rgb will be nFrames number of rgbFrames
for(jj=1:3)
    rgb{jj} = zeros(sz,'uint8');
    rgbFrame{jj} = zeros(rgbFrameSz,'uint8');
end

% background pixels
tmp = abs(aFrame)==backCol;
for(jj=1:3)
    rgbFrame{jj}(tmp) = backRGB(jj);
end

% in-form pixels
tmp = abs(aFrame)==inFormCol;  %1 wherever there are inForm dots
n = size(inFormRGB,1);
curColor = round(rand(1,sum(tmp(:)))*(n-1)+1);
for(jj=1:3)
    rgbFrame{jj}(tmp) = inFormRGB(curColor,jj);  % set rgb to inFormRGB (specified as input to function)
end

% out-form pixels
tmp = abs(aFrame)==outFormCol;  %1 wherever there are outForm dots
n = size(outFormRGB,1);
curColor = round(rand(1,sum(tmp(:)))*(n-1)+1);
for(jj=1:3)
    rgbFrame{jj}(tmp) = outFormRGB(curColor,jj);  % set rgb to outFormRGB (specified as input to function)
end

% noise dots
if(numSig<numDots && ~isempty(noiseRGB))  % if there are noise dots and noiseRGB prespecified
    n = size(noiseRGB,1);
    tmp = sign(aFrame)==-1;  % negative values specify places where there are noise dots

    %create a list as long as the # of noise dots by summing across tmp

    curColor = round(rand(1,sum(tmp(:)))*(n-1)+1);
    for(jj=1:3)
        rgbFrame{jj}(tmp) = noiseRGB(curColor,jj);
    end
end

% put it all together using the same frame (rgbFrame) for the whole movie (rgb)
for ii=1:numFrames
    for jj=1:3
        rgb{jj}(:,:,ii)=rgbFrame{jj};
    end
end

%% Permute rgb into the correct ordering and send back movie as img %%

img = permute(cat(4,rgb{1},rgb{2},rgb{3}),[1 2 4 3]);

return;



function [aFrame] = makeDotFrame(numDots, numSig, noiseDots, stimHigh, stimWide, dotColor, backCol)
% This function will make a frame of size stimHigh x stimWide using
% specified dotColor and background color, and given how many signal and
% noise dots.

% written by amr 5/30/08

% Make a blank frame.
aFrame = ones(stimHigh,stimWide,'int16');

% Randomly select (x,y) positions of the dots for the outForm
xPos = ceil(rand(numDots,1)*stimWide)-1;
yPos = ceil(rand(numDots,1)*stimHigh)-1;

dotPos = sub2ind(size(aFrame),floor(yPos)+1,floor(xPos)+1);
aFrame(:) = backCol; % set background color of the frame

aFrame(dotPos) = dotColor;  % set outForm dots to outFormCol

if(numSig<numDots)
    aFrame(dotPos(noiseDots)) = -dotColor; % Negative value indicates noise dots
end



return;
