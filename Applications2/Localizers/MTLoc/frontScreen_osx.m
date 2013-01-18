function frontScreen_osx(w,message,rect,countDownTime,triggerTime,fixSize);
% frontScreen: present a front screen for an experiment
%
% Usage: frontScreen_osx(w,message,rect,countDownTime,triggerTime,fixSize);
%
%
% written 1/14/03 by ras
% modified for osx 10/06 sungjin
% get responses from either 3T buttonbox or keyboard, 9/18/07 sungjin

if ~iscell(message)
	message= {message};
end

%%%%% parameters %%%%%%%%%%%%%%%%%%
X = rect(3); Y = rect(4);
textColor = 225;	% color in lookup table for textColor
backgnd = 127;		% color in lookup table for background
lineHeight = Y/15;		% size in pixels for each line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%scratch = screen('OpenOffScreenWindow',w);
%screen('TextSize', w, round(Y/30));
screen('FillRect', w, backgnd);
screen('Flip', w);

numLines = length(message);
yStart = round(Y/2 - lineHeight*(numLines-1)/2); 
yEnd = round(Y/2 + lineHeight*(numLines-1)/2);
yVals = yStart:lineHeight:yEnd;

screen('TextSize', w, round(Y/20));
for lineNum = 1:numLines
	%newX = screen('DrawText',w,message{lineNum},0,0,textColor);
	xPos = round(X/2-length(message{lineNum})/2*Y/40);
	yPos = yVals(lineNum);
	screen('DrawText', w, message{lineNum}, xPos, yPos, textColor);
end
screen('Flip', w);

ScreenNum = screen('WindowScreenNumber', w);
if ScreenNum > 0	% if presenting on a screen other than first screen
	disp('Press any key to begin experiment...');
end

% Wait for any key press to begin run
keycode = zeros(1,500); keydown = 0; 

[deviceNumLaptop deviceNumButtonbox] = getDeviceNumbers_osx;

while keydown==0
    [keydown,temp,keycode] = KbCheck(deviceNumLaptop);
end


return