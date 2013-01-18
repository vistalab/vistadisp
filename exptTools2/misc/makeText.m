function makeText(display,stimulus)
% makeText(display,stimulus)
%
% Purpose
% Generate text which can subsequently be flipped onto the screen.
%
% Input
%   display - Generated with loadDisplayParams and openScreen.
%   stimulus - Structure containing text parameters.
%       .text - String to be rendered.
%       .xPos - Proportion of distance across x axis to render text.
%       .yPos - Proportion of distance across y axis to render text.
%       .center - Logical input, center text at the x,y position?
%       .color - RGB values to render text in.
%       .font - Font face with which to render text.
%       .size - Size to render text at.  Defaults to size which renders the
%               letter x 1.5 degrees in width.
%
% Output
% N/A
% 
% RFB 2009 [renobowen@gmail.com]

% Turn on text anti-aliasing
Screen('Preference', 'TextAntiAliasing', 1);

% Generate a variety of default settings for all of the fields
if ~isfield(stimulus,'text')
    stimulus.text = 'I decided not to render any text!'; end
if ~isfield(stimulus,'xPos')
    stimulus.xPos = .5; end
if ~isfield(stimulus,'yPos')
    stimulus.yPos = .5; end
if ~isfield(stimulus,'center')
    stimulus.center = 1; end
if ~isfield(stimulus,'color')
    stimulus.color = [0 0 0]; end
if ~isfield(stimulus,'font')
    stimulus.font = 'Courier New'; end
if ~isfield(stimulus,'size')
    stimulus.size = 20; end

% Render the text
if stimulus.center % center word at x,y pos
    Screen('TextSize', display.windowPtr, stimulus.size);
    Screen('TextFont', display.windowPtr, stimulus.font);
    xLoc = display.numPixels(1)*stimulus.xPos;
    yLoc = display.numPixels(2)*stimulus.yPos;
    width = RectWidth(Screen('TextBounds', display.windowPtr, stimulus.text));
    Screen('DrawText', display.windowPtr, stimulus.text, xLoc-width/2, yLoc, stimulus.color);
else % draw word from left to right starting at x,y pos
    Screen('TextSize', display.windowPtr, stimulus.size);
    Screen('TextFont', display.windowPtr, stimulus.font);
    xLoc = display.numPixels(1)*stimulus.xPos;
    yLoc = display.numPixels(2)*stimulus.yPos;
    Screen('DrawText', display.windowPtr, stimulus.text, xLoc, yLoc, stimulus.color);
end