function colIndex = drawTrig(d, colIndex)
%
% drawTrig(display, [colIndex=1])
%
% Draws a square trigger to sync ECoG recording with stimulus 

if nargin < 2, colIndex = 1; end;
 
% 
% black = round(d.maxGammaValue * .1);  
% white = round(d.maxGammaValue * .9); 

black = round(d.maxGammaValue * 0);  
white = round(d.maxGammaValue * 1); 

if colIndex == 0, trigger_color = black; else trigger_color = white; end
    
Screen('FillRect', d.windowPtr, trigger_color, d.trigRect);
    
return