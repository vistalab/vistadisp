function countDownArduino(cdStartSecs,cdStartScan)
% function [time0]=countDown(display,cdStartSecs,cdStartScan)
%
% time0 is the time (GetSecs) at which the scanner started.
% cdStartSecs is the (integer) number of seconds for the entire countdown sequence
% cdStartScan is the (real) number of seconds remaining in the countdown when scanner
%   is to be started
%
% Purpose:  Counts down from secs to 1,
%           displaying the numbers on the
%           screen above the fixation point.
%
%
% Original author unknown
% 6/2/99 David Ress & Ben Backus: replaced timing loop with a time-based
%   loop instead of integer countdown, to allow use of real-valued scanner
%   starting times.
% 11/01/02 JLiu added try-catch for StartScan.
% 06/2005 SOD ported to OSX, added time0

if ~exist('cdStartScan', 'var')
	cdStartScan = -1;
end

% Loop to display countdown and start scanner
cdStartSecs = round(cdStartSecs);    % Force to integer
endTime = cdStartSecs + GetSecs;   % Time at which to end the countdown
scanStarted = 0;
currentDusplayNumber = cdStartSecs;
timeRemaining = cdStartSecs;

while timeRemaining > 0
	
	% Check whether to start scanner	
	if ~scanStarted
        if timeRemaining <= cdStartScan
            disp('Start Scan');
            [s,time0]   = StartScan;
            scanStarted = 1;
        end;    
    end;

	% Update countdown number, if it's time to do so
	if ceil(timeRemaining) <= currentDusplayNumber,
		disp(currentDusplayNumber); pause(0.01);
		currentDusplayNumber = currentDusplayNumber-1;
    end;
	timeRemaining =  endTime - GetSecs;
end;

% allow for cdStartScan == 0 (start at end of countdown)
if ~scanStarted & cdStartScan==0,
    [s,time0] = StartScan;
end;

return
