function dispStringInCenter(display,dispString,vLoc,textSize,colorRgb)
% dispStringInCenter(display,dispString,[vLoc],[textSize],[colorRgb]);
%
 
% 06/2005 SOD ported to OSX

if ~exist('vLoc', 'var') || isempty(vLoc), vLoc = 0.5; end
if ~exist('textSize', 'var') || isempty(textSize),	textSize = 20; end
if ~exist('colorRgb', 'var') || isempty(colorRgb), colorRgb = display.textColorRgb; end

fprintf('[%s]:%s\n',mfilename,dispString);
 
if isfield(display, 'windowPtr')
    oldTextSize = Screen('TextSize', display.windowPtr, textSize);
	charWidth = textSize/4.5;
    if display.stereoFlag==0
        loc(1) = display.rect(3)/2-charWidth*length(dispString);
        loc(2) = display.rect(4)*vLoc;
        Screen('DrawText', display.windowPtr, dispString, loc(1), loc(2), display.textColorRgb);
    else
        loc(1) = display.rect(3)/4-charWidth*length(dispString);
        loc(2) = display.rect(4)*vLoc;
        loc(3) = 3*display.rect(3)/4-charWidth*length(dispString);
        Screen('DrawText', display.windowPtr, dispString, loc(1), loc(2), display.textColorRgb);
        Screen('DrawText', display.windowPtr, dispString, loc(3), loc(2), display.textColorRgb);
    end
    drawFixation(display);
    Screen('Flip',display.windowPtr);
    Screen('TextSize', display.windowPtr, oldTextSize);
end
return

