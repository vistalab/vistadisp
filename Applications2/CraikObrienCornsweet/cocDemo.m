function thisFrame = cocDemo(edgeType, numSeconds, cyclesPerSecond, fixationSide,...
    edgeAmplitdue, ImageWidthInDegrees, fixationEcc, curvatureAmp, screenNumber)
% function cocDemo(edgeType, numSeconds, cyclesPerSecond, fixationSide,...
%   edgeAmplitdue, ImageWidthInDegrees, fixationEcc, curvatureAmp, screenNumber)
%
%   Purpose: 
%       Generate a dynamic bi-partite display with either a real edge or a COC
%       edge. 
%
% Arguments
%   edgeType: 'COC'(Craik-O'Brien-Cornsweet) or 'real'. Default is 'COC'.
%   numSeconds: duration of stimulus; default is 1
%   cyclesPerSecond: default is 1
%   fixationSide: -1 (left) or 1 (right); default is random
%   edgeAmplitdue: contrast across edge. default is .1 (10%)
%   ImageWidthInDegrees: Width of screen in degrees. This is important
%       because the COC edge is made with a filter in units of cpd
%   fixationEcc: distance from edge in degrees (default = 3)
%   curvatureAmp: Amount of edge curvature in degrees (default = 10)
%   screenNumber: default is 1
%
%   Written by JW, 5/1/08
%

%% TO SAVE IMAGES
% im    = cocDemo;
% mask  = makecircle(900);
% 
% pth = '~/Desktop/images';
% if ~exist(pth, 'dir'), mkdir(pth); end
% for ii = 1:numel(im)    
%    tmp = uint8(255*im{ii}(:,(271:1170)+0));  
%    tmp(~mask) = 0;
%    fname = sprintf('frame%03d.png', ii);
%    imwrite(tmp, fullfile(pth, fname));
% end

 
%% set up variables

if ~exist('edgeType', 'var')            || isempty(edgeType),            edgeType           = 'coc'; end
if ~exist('numSeconds', 'var')          || isempty(numSeconds),          numSeconds         = 2; end
if ~exist('cyclesPerSecond', 'var')     || isempty(cyclesPerSecond),     cyclesPerSecond    = 1; end
if ~exist('fixationSide', 'var')        || isempty(fixationSide),        fixationSide       = 1; end
if ~exist('edgeAmplitdue', 'var')       || isempty(edgeAmplitdue),       edgeAmplitdue      = 0.3; end
if ~exist('ImageWidthInDegrees', 'var') || isempty(ImageWidthInDegrees), ImageWidthInDegrees= 48; end
if ~exist('fixationEcc', 'var')         || isempty(fixationEcc),         fixationEcc        = 3; end
if ~exist('curvatureAmp', 'var')        || isempty(curvatureAmp),        curvatureAmp       = -5; end
if ~exist('screenNumber', 'var')        || isempty(screenNumber),        screenNumber       = 0; end


screenColor = 127;
[Window, screenRect] = Screen('OpenWindow', screenNumber, screenColor);

screenWidth = screenRect(3);
screenHeight = screenRect(4);
sourceRect = [0 0 screenWidth screenHeight];
destRect = sourceRect ;

%framesPerSecond = Screen('FrameRate', Window);
framesPerSecond  = FrameRate;
framesPerCycle = round(framesPerSecond / cyclesPerSecond);

pixels2degrees  = ImageWidthInDegrees/screenWidth;
degrees2pixels = 1/pixels2degrees;

x = linspace(-ImageWidthInDegrees/2, ImageWidthInDegrees/2, screenWidth);


curvatureAmp = round(curvatureAmp * degrees2pixels);
fixationLoc = fixationSide * round(fixationEcc * degrees2pixels); 


%% make the bandpass filter for COC edge
sigmaH = 4.3;
sigmaL = 0.17;
freq = (0:(screenWidth-1)) /ImageWidthInDegrees;
freq(screenWidth:-1:screenWidth/2+1) = -freq(2:screenWidth/2+1);
theFilter = exp(-freq.^2/(2*sigmaH^2))-exp(-freq.^2/(2*sigmaL^2));

%% Make one edge and one fixation image
edgeProfile = (x < 0) * 2 - 1;
edgeProfile = edgeProfile*edgeAmplitdue/2;

% filter the image
if strcmpi(edgeType, 'coc')
    Y = fft(edgeProfile);
    edgeProfile = ifft(Y .* theFilter);
end

im = ones(screenHeight,1) * edgeProfile ;

edgeShift = curvatureAmp - round(abs(sin((1:screenHeight) *pi/screenHeight))*curvatureAmp);
edgeShift = edgeShift * fixationSide;

for shiftRow = 1:screenHeight;
    im(shiftRow,:) = shift(im(shiftRow,:), edgeShift(shiftRow));
end

fixation = ones(size(im));
fixationY = screenWidth/2 + fixationLoc + (-3:3);
fixationX = screenHeight/2  + (-3:3);
fixation(fixationX, fixationY) = 0;

thisFrame = cell(1, framesPerCycle);
imScreen = cell(1, framesPerCycle);

%% Make each frame
for ii = 1:framesPerCycle;
    t = 2*pi*ii/framesPerCycle;
    thisFrame{ii} = (im * cos(t) + 1)/2 .* fixation;
    imScreen{ii} = Screen('MakeTexture', Window, round(thisFrame{ii}*255));
end

%% Show the images
t = zeros((framesPerCycle * cyclesPerSecond * numSeconds),1);
for ii = 1:framesPerCycle * cyclesPerSecond * numSeconds;
    Screen('DrawTexture', Window, imScreen{1+mod(ii, framesPerCycle)}, sourceRect, destRect);
    WaitSecs(1/framesPerSecond);
    Screen('Flip', Window);
    t(ii) = GetSecs;
end

Screen('CloseAll');
%disp(diff(t))
%figure; hist(diff(t))
