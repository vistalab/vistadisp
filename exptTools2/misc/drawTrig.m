function colIndex = drawTrig(d, colIndex)
%
% drawTrig(display, [colIndex=1])
%
% Draws a square trigger to sync eCog recording with stimulus 
%

if nargin < 2, colIndex = 1; end;

x = d.numPixels(1);
y = d.numPixels(2);

trigRect = round([.93*x .91*y x y]);
Screen('FillRect', d.windowPtr, 120 * colIndex, trigRect);
    

return