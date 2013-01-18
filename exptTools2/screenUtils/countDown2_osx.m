function countDown2_osx(w,startSecs,rect,fixSize)
% function countDown2_osx(w,startSecs,rect,fixSize)
%
% startSecs is the (integer) number of seconds for the entire countdown sequence
% startScan is the (real) number of seconds remaining in the countdown when scanner
%   is to be started
%
% Purpose:  Counts down from secs to 1,
%           displaying the numbers on the
%           screen above the fixation point.
%
% Original author unknown
% 6/2/99 David Ress & Ben Backus: replaced timing loop with a time-based
%   loop instead of integer countdown, to allow use of real-valued scanner
%   starting times.
% 6/13/02 Rory Sayres: modified to work on its own, as countdown2.m.
% modified for osx, 10/06 sungjin
%
%if ~exist('startScan', 'var')
%	startScan = -1;
%end
%if nargin < 8
%	gray = 127;
%	if nargin < 7
%		black = 10;
%		if nargin < 6
%			white = 254;
%		end
%	end
%end

%loc = display.rect([3,4])/2;

X = rect(3); Y = rect(4);
white = 254; black = 10; gray = 127;
screen('FillRect', w, gray);
screen('Flip', w); % clear screen

% Loop to display countdown and start scanner
startSecs = round(startSecs);    % Force to integer
endTime = startSecs + GetSecs;   % Time at which to end the countdown
scanStarted = 0;
currentDisplayNumber = startSecs - 1e-6;
timeRemaining = startSecs + GetSecs;

while timeRemaining > 0
	% Check whether to start scanner	
%	if ~scanStarted
%		if timeRemaining <= startScan
%			osxptb_trigscan;
%			tic
%			%screen(w,'DrawText','Start Scan',0.45*X,0.6*Y,black);
%			scanStarted = 1;
%		end
%	end

	% Update countdown number, if it's time to do so
	if floor(timeRemaining) <= currentDisplayNumber
		% draw fixation point
		screen('FillRect', w, [255 255 255], CenterRect([0 0 fixSize-2 fixSize], [0 0 X Y]));
		screen('FillRect', w, [255 255 255], CenterRect([0 0 fixSize fixSize-2], [0 0 X Y]));		
		% display number
		screen('TextSize', w, round(Y/20));
		screen('DrawText', w, num2str(currentDisplayNumber), round(X/2-Y/80), round(Y/2+Y/30), 255);
		screen('Flip', w, [], 0, 1);
		currentDisplayNumber = currentDisplayNumber-1;
	end
	timeRemaining =  endTime - GetSecs;
	
	% ESC check
	[keyisdown, secs, keycode] = KbCheck;
    if keyisdown==1 & keycode(41)==1, break; end

end

return