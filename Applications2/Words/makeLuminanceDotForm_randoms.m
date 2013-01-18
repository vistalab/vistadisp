function [img,cmap] = makeLuminanceDotForm(form,coherence,dotDensity,numFrames,formDir,backDir,inFormRGB,outFormRGB,backRGB, stillBackground)
% Take a form and create different dot luminances within and outside of the form
% This code mirrors makeMoveDotForm except that here luminance, rather than
% motion, varies with coherence.
%
%  makeLuminanceDotForm(form,coherence,dotDensity,numFrames,formDir,backDir)
%
% Input arguments:
%  form:  Entries where form == 1 define the shape.
%  coherence:  Dot luminance coherence
%  dotDensity: Dot density
%  numFrames:  Total frames in the movie (duration = nFrames*frameRate)
%  formLum, backLum:  Luminance of dots
%  inFormRGB,outFormRGB,backRGB:  Dot colors of moving or background
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

%% Check input variables
if(~exist('coherence','var') || isempty(coherence)), coherence = 1; end;
if(~exist('form','var') || isempty(form))
    % Default form is a square
    form  = zeros(100,100);
    [x,y] = meshgrid([25:75],[25:75]);
    form(sub2ind(size(form),x,y)) = 1;
end;
if(~exist('dotDensity','var') || isempty(dotDensity)), dotDensity = 0.1; end;
if(~exist('numFrames','var')  || isempty(numFrames)),  numFrames = 32; end;
if(~exist('formLum','var')    || isempty(formLum)),    formLum = 255; end;
if(~exist('backLum','var')    || isempty(backLum)),  backLum = 0; end;
if ~exist('stillBackground','var') || isempty('stillBackground'), stillBackground = 0; end


%  Set up the colormap
backCol = 128;        % Index to the three color map entries
inFormCol = 255;
outFormCol = 0;

cmap = zeros(3,3);      % Color map for dot motion animation
cmap(1,:) = backRGB;
cmap(2,:) = inFormRGB;
cmap(3,:) = outFormRGB;


%% Dot parameters
% dotSize = 4;
[stimHigh,stimWide] = size(form);
numDots = round(length(form(:)).*dotDensity);

%% Set up noise dot luminances

% Compute the luminance displacements
% There is a single signal luminance.  The noise luminances are one of
% a number of luminances given by numLuminances.  We create a vector of random luminances that
% we will sample later
numLuminances = 16;
Luminances = 255*(1:numLuminances)/numLuminances;
Luminances = Luminances';

% These are the number of signal dots
numSig = floor(coherence*numDots);

% The remainder are noise dots
numNoise = numDots-numSig;

% vector of indices specifying the noise dot luminances
index = ceil(rand(numNoise,1)*numLuminances);
randLuminances = Luminances(index)';

%Rect is [L T R B]
% img is the entire background plus form rectangle
% imgForm is just the rectangle containing the form
img     = zeros(stimHigh,stimWide,numFrames,'uint8');
imgForm = zeros(stimHigh,stimWide,numFrames,'uint8');

% Randomly select (x,y) positions of the dots for the form
xPos = ceil(rand(numDots,1)*stimWide)-1;
yPos = ceil(rand(numDots,1)*stimHigh)-1;

% Make 2 vectors that give the index of signal dots and noise dots.
sigDots   = 1:numSig;
noiseDots = (numSig+1):numDots;

% Make a blank frame.
aFrame = ones(stimHigh,stimWide,'uint8');

% Create dots for the background
dotPos = sub2ind(size(aFrame),floor(yPos)+1,floor(xPos)+1);
aFrame(:) = backCol;
aFrame(dotPos) = outFormCol;
if(numSig<numDots)
    % Set the noise dot colors
    aFrame(dotPos(noiseDots)) = randLuminances;
end

% Repeat the same frame for the whole movie.  This will keep the structure
% of makeMoveDotForm (a movie), but just keep the frame.
for ii=1:numFrames;
    img(:,:,ii) = aFrame;
end



%% Create dots for the form (more or less same as above)

xPos = ceil(rand(numDots,1)*stimWide)-1;
yPos = ceil(rand(numDots,1)*stimHigh)-1;
index = ceil(rand(numNoise,1)*numLuminances);
randLuminances = Luminances(index)';
xPos(index) = ceil(rand(length(index),1)*stimWide)-1;
yPos(index) = ceil(rand(length(index),1)*stimHigh)-1;

Luminances(1:numSig) = inFormCol;

Luminances(numSig+1:numDots) = randLuminances';

% Probably don't need this since dots aren't moving, but keep for now.
% index = find(xPos>=stimWide-1);
% xPos(index) = xPos(index)-stimWide+1;
% index = find(xPos<0);
% xPos(index) = xPos(index)+stimWide-1;
% index = find(yPos>=stimHigh-1);
% yPos(index) = yPos(index)-stimHigh+1;
% index = find(yPos<0);
% yPos(index) = yPos(index)+stimHigh-1;

dotPos = sub2ind(size(aFrame),floor(yPos)+1,floor(xPos)+1);
aFrame(:) = backCol;
aFrame(dotPos) = inFormCol;

if(numSig<numDots)
    aFrame(dotPos(numSig+1:numDots)) = randLuminances;
end

% Repeat the same frame for the whole movie.  This will keep the structure
% of makeMoveDotForm (a movie), but just keep the frame.
for ii=1:numFrames
    imgForm(:,:,ii) = aFrame;
end




%% Build the movie for the background

% % start dots off with random ages
% if(dotLife>0)
%     dotAge = ceil(rand(numDots,1)*dotLife)-1;
% else
%     % Make it infinite
%     dotAge = [];
% end




%% Assmeble the complete movie from the form and background

for ii=1:numFrames
    tmpBak = img(:,:,ii);      % Background frame as matrix
    tmpFrm = imgForm(:,:,ii);  % Form frame as a matrix
    
    % Locations where form == 1 contain the text or form.  We copy the
    % motion from the form movie frame into those locations.
    tmpBak(form==1) = tmpFrm(form==1);
    
    % Store the result and carry on
    img(:,:,ii) = tmpBak;
end

%% If only one returned argument, make img into a full-fledged RGB movie

if(nargout==1)
    sz = size(img);
    rgb = zeros([sz(1) sz(2) 3 sz(3)],'uint8');
    for(ii=1:sz(3))
        tmp = uint8(cmap(img(:,:,ii)+1,:));
        rgb(:,:,:,ii) = reshape(tmp,[sz(1) sz(2) 3]);
    end
    img = rgb;
end

return;
