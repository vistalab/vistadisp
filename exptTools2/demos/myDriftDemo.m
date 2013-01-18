function myDriftDemo
%
% Display an animated grating using the new Screen('DrawTexture') command. 
%

d = loadDisplayParams('builtin');

oldGamma = repmat(linspace(0,1,256)',1,3);
try
	AssertOpenGL;
	
	% Find the color values which correspond to white and black.  Though on OS
	% X we currently only support true color and thus, for scalar color
	% arguments,
	% black is always 0 and white 255, this rule is not true on other platforms will
	% not remain true on OS X after we add other color depth modes.  
	white=WhiteIndex(d.screenNumber);
	black=BlackIndex(d.screenNumber);
	gray=(white+black)/2;
	if round(gray)==white
		gray=black;
	end
	inc=white-gray;
	
	% compute each frame of the movie and convert those frames, stored in
	% MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
	numFrames = 60; % temporal period, in frames, of the drifting grating
    [x,y] = meshgrid(-200:200,-200:200);
    sf = 0.02; % cycles/pixel
    angle = 90; % orientation, in degrees
    contrast = 0.3;
    sf = sf*2*pi;
    angle = angle*pi/180;
    a = cos(angle)*sf;
	b = sin(angle)*sf;
	for ii=1:numFrames
		phase = (ii/numFrames)*2*pi;
		m = exp(-((x/90).^2)-((y/90).^2)).*sin(a*x+b*y+phase);
		tex(ii) = Screen('MakeTexture', d.screenNumber, gray+inc*m*contrast);
    end
    clear x y m a b angle sf phase;
	
    gammaTable = d.gamma(385:640,:);
    gammaTable(1,:) = [0 0 0];
    gammaTable(end,:) = [1 1 1];
    
	% Open a double buffered fullscreen window and draw a gray background 
	% and front and back buffers. 
	d = openScreen(d);
    HideCursor;
	Screen('FillRect', d.windowPtr, gray);
    drawFixation(d);
	Screen('Flip', d.windowPtr);
    % we take a one-time 5-frame hit the first time we run 'DrawTexture'
    Screen('DrawTexture', d.windowPtr, tex(1));
	Screen('FillRect',d.windowPtr, gray);
    drawFixation(d);
	Screen('LoadNormalizedGammaTable', d.screenNumber, gammaTable);
    
	% Run the movie animation for a fixed period.  
	movieDurationSecs = 5;
	movieDurationFrames = round(movieDurationSecs * d.frameRate);
	movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
	priorityLevel=MaxPriority(d.windowPtr);
	Priority(priorityLevel);
    tic;
	for i=1:movieDurationFrames
        %Screen('LoadNormalizedGammaTable', screenNumber, gammaTable);
        Screen('DrawTexture', d.windowPtr, tex(movieFrameIndices(i)));
        drawFixation(d);
        Screen('Flip', d.windowPtr);
	end;
    actDur = toc;
	Screen('FillRect',d.windowPtr, gray);
    drawFixation(d);
	Screen('Flip', d.windowPtr);
	Priority(0);
    expDur = movieDurationFrames/d.frameRate;
	fprintf('Duration: %0.2fs expected, %0.2fs actual; %0.3fs error (%0.1f frames)\n',...
        expDur, actDur, actDur-expDur, (actDur-expDur)*d.frameRate);
	% Close onscreen and offscreen windows and clear textures.
	Screen('CloseAll');
    Screen('LoadNormalizedGammaTable', d.screenNumber, oldGamma);
    ShowCursor;
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..



    




