function colIndex = drawTrig(d, colIndex)
%
% drawTrig(display, [colIndex=1])
%
% Draws a square trigger to sync eCog recording with stimulus 
%

if nargin < 2, colIndex = 1; end;

x = d.numPixels(1);
y = d.numPixels(2);

% lower right
%trigRect = round([.93*x .91*y x y]);

% upper right
%trigRect = round([.93*x 0*y x .09*y]);

% upper left
trigRect = round([0*x 0*y .07*x .09*y]); 

black = round(d.maxGammaValue * .1);  
white = round(d.maxGammaValue * .9); 

if colIndex == 0, trigger_color = black; else trigger_color = white; end
    
Screen('FillRect', d.windowPtr, trigger_color, trigRect);
    

return