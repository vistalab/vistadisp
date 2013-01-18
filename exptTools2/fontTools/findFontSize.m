function fontSize = findFontSize(display,fontFace,string,sizeDeg,ballPark)
% fontSizes = findFontSize(display,fontFace,string,sizeVector)
%
% Purpose
%   Given a font face and a string, determine what font size will be
%   necessary to subtend a given amount of visual angle.
%
% Input
%   display - Generated with loadDisplayParams (info specific to the
%             monitor you're using)
%   fontFace - ...
%   string - ...
%   sizeDeg - Degrees of visual angle to find the font size for
%
% Output
%   fontSize - Font size for the given visual angle
%
% RFB 2009 [renobowen@gmail.com]

% If no ballpark estimate is specified, just use a guess like size 20
if ~exist('ballPark','var')
    ballPark = 20; end

% Open the screen
display = openScreen(display);

Screen('Preference', 'TextAntiAliasing', 0); %0 = Disable, 1 = Enable, 2 = EnableHighQuality;
x = fminsearch(@(x) sizeDelta(display,fontFace,x,string,sizeDeg),ballPark);
fontSize = x;

% Close the screen when finished
closeScreen(display);
  
end

function delta = sizeDelta(display,fontFace,fontSize,string,goalDeg)
% delta = sizeDelta(display,fontFace,fontSize,string,goalDeg)
%
% Purpose
%   Given a goal of how many degrees of visual angle you'd like a word to
%   subtend, determine how far off you are with a chosen font size, face, and
%   string.
%
% Input
%   display - Generated with loadDisplayParams and openScreen.
%   fontFace - ...
%   fontSize - ...
%   string - ...
%   goalDeg - How many degrees of visual angle would you like the stimulus to
%             subtend?
% 
% Output
%   delta - Error in degrees of visual angle.
%
% RFB 2009 [renobowen@gmail.com]

    deg = angleTest(display,fontFace,fontSize,string);
    delta = abs(goalDeg - deg);
    
end

function deg = angleTest(display,fontFace,fontSize,string)
% deg = angleTest(display,fontFace,fontSize,string)
%
% Purpose
%   Determine the visual angle width of a word rendered with DrawText.
% 
% Input
%   display - Generated with loadDisplayParams and openScreen.
%   fontFace - ...
%   fontSize - ...
%   string - ...
% 
% Output
%   deg - Degrees of visual angle subtended by the word.
% 
% RFB 2009 [renobowen@gmail.com]

    fontSize = round(fontSize); % Round the font size - we can't deal in fractions
    Screen('TextSize', display.windowPtr, fontSize);
    Screen('TextFont', display.windowPtr, fontFace);

    % Prepare for position computations
    bounds = TextBounds(display.windowPtr,string);
    width = bounds(3)-bounds(1);

    deg = pix2angle(display,width);
    
end