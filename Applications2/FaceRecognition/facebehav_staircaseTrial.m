function stim = facebehav_staircaseTrial(stim, stair, trial, win, X, Y);
% Create a single trial for the face behavior staircase.
%
%   S = facebehav_staircaseTrial(stim, stair, trial);
%
% This function does the following:
%	
%	* embeds the image for the current trial in a noise level corresponding
%	to the staircase parameters contained in stair;
%
%	* places the image at the specified location
%
%   * RMS contrast-scales the images;
%
%   * it places each image centered at the specified distance from the
%   fixation, based on stim.faceEcc, stim.faceAngle, and stim.fixPos;
%
%   * it creates a texture for the image;
%
% Returns a set of textures for use with the Screen command, and a set of
% corresponding onset times indicating when to present each texture.
%
% ras, 07/13/09. Based off facebehav_createTextures.
bgColor = 127;  % face image background color

% compute row, column of fixation point: this will serve as the (0, 0)
% point for all stimulus locations specified in stim.faceEcc and
% stim.faceAngle.
cenX = round( X/2 + stim.fixPos(1) );
cenY = round( Y/2 + stim.fixPos(2) );

r = stim.faceEcc;
th = stim.faceAngle;
imgNum = stim.imgNum(trial);
[ysz xsz] = size(stim.images{imgNum}); % should == stim.faceSize(trial)
    
%% initialize image: create a screen-size blank image
% first, make a blank (mean-luminance) image and texture
blank = repmat(bgColor, [Y X]);
blankTexture = Screen('MakeTexture', win, double(blank));
    
%% scale image contrast and add noise
stimImage = faceScaleContrast(stim.images{imgNum}, stim.contrast);

if stim.noiseType==-1
   % do partial phase scrambling
   stimImage = phaseScramble(stimImage, stair.noise);
else
   %  do 1/f^N scrambling
   noiseImage = double( noiseonf(size(stimImage), stim.noiseType) );
   rng = minmax(stimImage);
   noiseImage = normalize(noiseImage, rng(1), rng(2));
      
   stimImage = (1-stair.noise) * stimImage   +   stair.noise * noiseImage;
end

% mask out the background as mean-luminance
stimImage(stim.bgMask) = stim.bgColor;

%% place stimulus in screen-size image
img = blank;

% % if requested, randomly left/right flip half the stimuli
% % (this prevents all the trials being in a single visual hemifield)
% if stim.balanceLR==1
% 	doFlip = round(rand);
% 	if doFlip==1
% 		th = mod(th + pi, 2*pi);
% 	end
% end

% convert (r, th) values into image row and column
[xx yy] = pol2cart(th, r);
col = cenX + xx;
row = cenY + yy;

% intended x/y range subtended by whole face
rows = round([1:ysz] - ysz/2 + row);
cols = round([1:xsz] - xsz/2 + col);

% allow for the stimulus to extend past the screen:
% find only those 'ok' rows/cols within the screen bounds
ok_rows = find(rows >= 1 & rows <= Y);
ok_cols = find(cols >= 1 & cols <= X);

if isempty(ok_rows) | isempty(ok_cols)
	warning('[%s]: Entire stimulus is offscreen.', mfilename);
	[r th col row X Y]
    return
end

% place the stimulus
rows = rows(ok_rows);
cols = cols(ok_cols);

img(rows,cols) = stimImage(ok_rows,ok_cols);

% reorient if specified by the display parameters
if (isfield(stim.display, 'flipLR') && stim.display.flipLR),
	img = fliplr(img);
end
if (isfield(stim.display, 'flipUD') && stim.display.flipUD),
	img = flipud(img);
end

%% copy into an offscreen texture
imgTexture = Screen('MakeTexture', win, double(img));


%% create the final trial structure
stim.textures = [imgTexture blankTexture blankTexture blankTexture];
stim.seqtiming = [0 stim.imageDur stim.trialDur stim.trialDur+20];
stim.seq = [1 2 2];
stim.fixSeq = [1 1 1];

% call/load 'DrawTexture' prior to actual use (clears overhead)
Screen('DrawTexture', stim.display.windowPtr, stim.textures(1));

return




