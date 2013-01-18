function makeText(w,text,xPercent,yPercent,centered,size,textColor,textFont)

% [MAKE TEXT]
% Author(s): Reno Bowen
%
% Explanation:
% Make text provides a simple function to save space and simplify the
% process of creating text through the Screen command (which often can
% create a lot of excess computational mess).  By providing text,
% preferably in the form of sprintf, as well as a number of other simple
% input arguments, one can easily create the required text in two lines of
% brief and easy to understand code.
%
% The default settings for size, color, and font are 25, black, and Arial,
% respectively.  By using more input arguments, one overwrites the
% defaults, and can make further modifications to the presented text.
%
% It should also be noted that makeText only creates the text to be used,
% and a Screen Flip command must still be issued externally to present the
% text.
%
% [4 Input Args]
% This is the basic set of inputs.  The text, position, and whether or not
% it should be horizontally centered are given.  Defaults are used for the
% size, color, and font.
%
% [5, 6 and 7 Input Args]
% Specification of a custom text size, color, and font, respectively.
%
% Inputs:
% text =        text in the form of sprintf
% xPercent =    percent across x axis, from left to right
% yPercent =    percent across y axis, from top to bottom
% centered =    whether or not text is horizontally centered at xPercent
% size =        size of text
% textColor =   color of text (vector)
% textFont =    font of text
%
% Outputs:
% N/A

% Internally generate the central screen coordinates
r=Screen('Rect', w);
[rcx, rcy] = RectCenter(r);
% Default size, color, and font values
finalSize = 25;
finalTextColor = [0 0 0];
finalTextFont = 'Arial';

% Overwrite defaults based on number of input arguments
if nargin == 5
    ;
elseif nargin == 6
    finalSize = size;
elseif nargin == 7
    finalSize = size;
    finalTextColor = textColor;
elseif nargin == 8
    finalSize = size;
    finalTextColor = textColor;
    finalTextFont = textFont;
end

% If centered text is desired
if centered == 1;
    Screen('TextSize', w, finalSize);
    Screen('TextFont', w, finalTextFont);
    xLoc = rcx*2*xPercent*.01;
    yLoc = rcy*2*yPercent*.01;
    width = RectWidth(Screen('TextBounds', w, text));
    Screen('DrawText', w, text, ...
            xLoc-width/2, yLoc, finalTextColor);
% Uncentered text
else
    Screen('TextSize', w, finalSize);
    Screen('TextFont', w, finalTextFont);
    xLoc = rcx*2*xPercent*.01;
    yLoc = rcy*2*yPercent*.01;
    Screen('DrawText', w, text, ...
            xLoc, yLoc, finalTextColor);
end