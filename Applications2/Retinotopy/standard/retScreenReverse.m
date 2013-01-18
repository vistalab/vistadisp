function retScreenReverse(params, stimulus, xy)
% If necessary, flip the screen LR or UD to account for mirrors.
%  
%   retScreenReverse(params, stimulus, [xy])
%
% We now reverse the screen itself ONCE before the experiment starts
% (instead of reversing each image). This ensures that everything,
% including the fixation, stimulus, countdown text, instructions, etc, all
% get flipped
%
% April, 2010, JW
%
% note: this function doesn't have to be specific to retinotopy. could now
% be renamed and moved to, say, vistadisp/exptTools2/screenUtils


d = params.display;

if (isfield(d, 'flipLR') || isfield(d, 'flipUD'))
    
    if isfield(d, 'flipLR') && d.flipLR, flipx = -1; else flipx = 1; end
    if isfield(d, 'flipUD') && d.flipUD, flipy = -1; else flipy = 1; end
    
    % Find the center of the display
    if exist('xy', 'var'), xc = xy(1); yc = xy(2); 
    else                         [xc, yc] = RectCenter(stimulus.destRect); end
    
    % Translate origin into the geometric center
    Screen('glTranslate', params.display.windowPtr, xc, yc, 0);
    
    % Flip
    Screen('glScale', params.display.windowPtr, flipx, flipy, 1);
    
    % Translate origin back
    Screen('glTranslate', params.display.windowPtr, -xc, -yc, 0);

    
else
    % do nothing (nothing to flip)
    
end

return
