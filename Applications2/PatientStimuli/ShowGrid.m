function stim = ShowGrid(subject, stopForKbOnly);
% Display a simple gray screen with a line grid.
% 
%   stim = ShowGrid([subject, stopForKbOnly=1];
%
% This function was originally written to display a simple stimulus for an
% epileptic patient during an ictal episode. To help the patient keep track
% of visual percepts, the grid labels up/down/left/right of the fixation
% mark, and the exact timing of when the grid is first displayed and taken
% down is stored.
%
% To stop showing the grid, press any key. If the stopForKbOnly flag is set
% to 1 [default value], the display will only stop when a key is pressed on
% the main keyboard (but not button boxes, for instance). If 0, any key on
% any device will stop it. 
%
% The subject argument is an optional text label. It is only used in
% determining the name of the save file. 
%	If no subject name is passed, stimulus information is saved as:
%		data/ShowGrid-[date]-#.mat
%	otherwise, the save file is:
%		data/ShowGrid-[subject]-[date]-#.mat
%	where # is the number of the save file (counts existing save files, and
%	increments by 1 each time).
%
%
% ras, 10/29/2008: wrote it.
if notDefined('subject'),		subject = '';				end
if notDefined('stopForKbOnly'),	stopForKbOnly = 1;			end

%% mark the time this function was invoked
stim.startTime = clock;
stim.startTimeSecs = GetSecs;

%% params
stim.displayName = prefsDisplayName;  % external function -- checks/sets pref variable
stim.polarGrid = 1;			% if 1, will put up a polar grid; otherwise, Cartesian
stim.fixationPos = 0;		% 0=screen center; 1-4 = 4 corners of the screen
stim.gridSpacing = 100;     % put a line every [100] pixels
stim.penWidth = 1;			% pen width in pixels for grid lines
stim.waitKb = stopForKbOnly; 

%% open a display
% load display parameters
stim.display = loadDisplayParams(stim.displayName);

%% main part: show the grid
try
	stim = DisplayGrid(stim);
catch
	stim.lasterror = lasterror;
    Screen('CloseAll');
    setGamma(0);
    Priority(0);
    ShowCursor;
    rethrow(lasterror);
end


%% close up, save results
stim.display = closeScreen(stim.display);

mfileDir = fileparts( which(mfilename) );
dataDir = fullfile(mfileDir, 'data');
ensureDirExists(dataDir);

if isempty(subject)
	prefix = sprintf('%s-%s', mfilename, datestr(now, 1));
else
	prefix = sprintf('%s-%s-%s', mfilename, subject, datestr(now, 1));
end

% find any existing files with this prefix
w = dir( fullfile(dataDir, [prefix '*.mat']) );

% assign the file # as the next file in this series
fileNum = length(w) + 1;

% save the file
saveName = sprintf('%s-%i.mat', prefix, fileNum);
saveFile = fullfile(dataDir, saveName);
save(saveFile, '-struct', 'stim');
fprintf('Saved stim info in %s.\n', saveFile);

return
% /--------------------------------------------------------------/ %




% /--------------------------------------------------------------/ %
function stim = DisplayGrid(stim);
%% main sub-function to actually display the grid

% to skip annoying warning message on display (but not terminal)
Screen('Preference','SkipSyncTests', 1);

% Open the screen
stim.display = openScreen(stim.display);

% to allow blending
Screen('BlendFunction', stim.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% put up the grid
maxX = stim.display.numPixels(1);
maxY = stim.display.numPixels(2);

cenX = maxX ./ 2;
cenY = maxY ./ 2;

if stim.polarGrid==0
	%% cartesian grid
	% create X, Y grid points, centered at (cenX, cenY), and moving in the +
	% and - directions in steps of 100 pixels:
	rangeX = [cenX-[cenX:-100:100], cenX, cenX + [100:100:cenX]];
	rangeY = [cenY-[cenY:-100:100], cenY, cenY + [100:100:cenY]];

	for x = rangeX
		col = round(100 .* abs( (x-cenX) / cenX));
		Screen('DrawLine', stim.display.windowPtr, col, x, 0, x, maxY, stim.penWidth);
	end

	for y = rangeY
		col = round(100 .* abs( (y-cenY) / cenY));
		Screen('DrawLine', stim.display.windowPtr, col, 0, y, maxX, y, stim.penWidth);
	end
else
	%% polar grid
	maxR = max([cenX, cenY]);
	rangeR = 0:100:maxR;
	rangeTheta = 0:30:330;
	
	for r = rangeR
		col = round( 100 .* abs( (r-maxR) / maxR ) );
		Screen('FrameOval', stim.display.windowPtr, col, [cenX-r cenY-r cenX+r cenY+r]);
	end
		
	for th = rangeTheta
		col = round( 100 .* abs(th / 360) );
		[x y] = pol2cart(deg2rad(th), maxR);
		x = x + cenX;
		y = y + cenY;
		Screen('DrawLine', stim.display.windowPtr, col, cenX, cenY, x, y);
	end
end

drawFixation(stim.display);

% this actually puts up the grid
Screen('Flip', stim.display.windowPtr);

%% wait for the exit keypress
% KbWait and KbCheck are device dependent
if isfield(stim.display,'devices'),
	if stim.waitKb
		% wait for input of experimentor only
		while ~KbCheck(stim.display.devices.keyInputInternal),
			WaitSecs(0.01); % give time back to OS - important
		end;
	else
		while ~KbCheck,
			WaitSecs(0.01); % give time back to OS - important
		end;
	end
else,
    % just wait for any press
    % KbWait is unreliable probably would need a device input as well
    % but this is not an option (Psychtoolbox 1.0.5)
    pause;
end;
stim.endTime = clock;
stim.endTimeSecs = getSecs;
stim.elapsedTime = stim.endTimeSecs - stim.startTimeSecs;

% report the times
fprintf('ShowGrid started at %s.\n ', datestr(stim.startTime));
fprintf('Finished at %s\n', datestr(stim.endTime));
fprintf('Elapsed time %2.0f min, %2.2f sec.\n', floor(stim.elapsedTime/60), mod(stim.elapsedTime, 60));

return

