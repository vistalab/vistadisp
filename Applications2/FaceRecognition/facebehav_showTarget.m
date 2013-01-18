function stim = facebehav_showTarget(stim);
% Display the target face in a face identification task.
%
%    stim = facebehav_showTarget(stim);
%
% stim: stimulus struct. See facebehav_staircase.
%
%
% ras, 07/2009.


%% make a grayscale image with different views of the face centered on it
%% oris = stim.faceOrientations;
orisToShow = 1; % [1 find(oris==0) length(oris)];
targetImg = [];

% the image to show is different depending on whether we are running a
% staircase or a position-effect experiment. For the staircase, the images
% are the first set of images in stim.images. For the main experiment, the
% noise-free target images are saved in the same directory as the other
% images, with the name 'target-#.png'. Load the images accordingly.
if isequal(stim.runCode, 'facebehav_staircase')
    % staircase code
    for ii = orisToShow
       targetImg = [targetImg, stim.images{ii}];
    end
else
    % position-experiment code
    % first, get the run # -- this will tell us which target image to show
    vals = explode('-', stim.scriptName);
    runNum = str2num(vals{end});
    
    % now, load the appropriate target image
    imgDir = fileparts( stim.image{3} );
    imgPath = fullfile(imgDir, sprintf('target-%i.png', runNum));
    targetImg = imread(imgPath);
end

img = makeScreenSizeImages(targetImg, stim.display.numPixels, 127);

%% show the image and message on the screen
win = stim.display.windowPtr;
txt = Screen('MakeTexture', win, img);
Screen('DrawTexture', win, txt);

% add text
if iscell(stim.taskStr)
    % multi-line input: present each line separately
    nLines = length(stim.taskStr);
    vRange = min(.4, .04 * nLines/2);  % vertical axis range of message
    vLoc = 0.5 + linspace(-vRange, vRange, nLines); % vertical location of each line
    textSize = 20;
    oldTextSize = Screen('TextSize', win, textSize);
    charWidth = textSize/4.5; % character width
    for n = 1:nLines
        loc(1) = stim.display.rect(3)/2 - charWidth*length(stim.taskStr{n});
		loc(2) = siim.display.rect(4) * vLoc(n);
		Screen('DrawText', win, stim.taskStr{n}, loc(1), loc(2), ...
                stim.display.textColorRgb);
    end
    Screen('Flip',win);
    Screen('TextSize', win, oldTextSize);
else
    % single line: present in the middle of the screen
    dispStringInCenter(stim.display, stim.taskStr, 0.25);
end

drawFixation(stim.display);


%% wait for the user to press a key to continue
while ~KbCheck
    WaitSecs(0.01); 
end

return
% /----------------------------------------------------------------/ %




% /----------------------------------------------------------------/ %
function images = makeScreenSizeImages(srcImages, screenSize, bg);
%% given a set of images which may be larger than a given screen size, 
%% return a set of images the same size as the screen, with the images
%% centered within it. The rest of the image will be padded with the
%% background value bg (takes corner pixel of 1st image as default). 
if notDefined('bg'), bg = srcImages(1); end

screenX = screenSize(1);
screenY = screenSize(2);

sz = size(srcImages);  sz(3) = size(srcImages, 3);  % force 3rd dim
if sz(1) > screenY | sz(2) > screenX
	warning('images are already larger than the screen!');
	return
end

images = repmat(bg, [screenY screenX sz(3)]);
rows = ceil( [1:sz(1)] + screenY/2 - sz(1)/2 );
cols = ceil( [1:sz(2)] + screenX/2 - sz(1)/2 );
for n = 1:sz(3)
	images(rows,cols,n) = uint8(srcImages(:,:,n));
end

return
