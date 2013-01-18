function keyPress = displayInstructions(display,params,allowKeys)
% keyPress = displayInstructions(display,params,allowKeys)
%
% Purpose
%   Take a structure filled with text you'd like to present as instructions
%   to a subject as well as parameters about each bit of text, and render it.
%   Afterwards, wait for a response (which can be specific or non-specific).
%   Return the key pressed.
%
% Input
%   display - Generated with loadDisplayParams and openScreen.
%   params(n) - Structure containing text parameters.  Each bit of text to be
%               presented should be inserted into a separate entry of params.  For
%               example, params(1) and params(2) will each contain information for
%               different bits of text.
%       .text - String to be rendered.
%       .xPos - Proportion of distance across x axis to render text.
%       .yPos - Proportion of distance across y axis to render text.
%       .center - Logical input, center text at the x,y position?
%       .color - RGB values to render text in.
%       .font - Font face with which to render text.
%       .size - Size to render text at.  Defaults to size which renders the
%               letter x 1.5 degrees in width.
%   allowKeys - Cell array containing strings of keys you'd like enabled.  If
%               left empty, all keys on the keyboard will remain enabled.
%
% Output
%   keyPress - Contains the key pressed by the user in string format.
%               KbName(keyPress) can change it into a key index, if necessary.
%
% RFB 2009 [renobowen@gmail.com]

% Use default device for responses, unless an external exists
device = getBestDevice(display);

% Determine number of text renders that will be completed
textRenders = size(params,2);

% If allowKeys wasn't given to the function, generate an empty input
if ~exist('allowKeys','var')
    allowKeys = []; end

% If any field is missing, it means it didn't exist across any of the
% entries.  Therefore, I create an empty cell in one, which in turn creates
% empty cells in the rest.  I can then use isempty to set defaults later.
if ~isfield(params,'text')
    error('Give me some text to work with!'); end % No text in the structure :(
if ~isfield(params,'xPos')
    params(1).xPos = []; end
if ~isfield(params,'yPos')
    params(1).yPos = []; end
if ~isfield(params,'center')
    params(1).center = []; end
if ~isfield(params,'color')
    params(1).color = []; end
if ~isfield(params,'font')
    params(1).font = []; end
if ~isfield(params,'size')
    params(1).size = []; end
    
for i=1:textRenders % Loop over all of the instances of text and their parameters
    % Pull out the specific render we're working with
    currentRender = params(i);
    
    % Remove the fields if we have nothing to work with.  makeText will set
    % defaults to the corresponding missing entries.
    if isempty(currentRender.text)
        currentRender = rmfield(currentRender,'text'); end
    if isempty(currentRender.xPos)
        currentRender = rmfield(currentRender,'xPos'); end
    if isempty(currentRender.yPos)
        currentRender = rmfield(currentRender,'yPos'); end
    if isempty(currentRender.center)
        currentRender = rmfield(currentRender,'center'); end
    if isempty(currentRender.color)
        currentRender = rmfield(currentRender,'color'); end
    if isempty(currentRender.font)
        currentRender = rmfield(currentRender,'font'); end
    if isempty(currentRender.size)
        currentRender = rmfield(currentRender,'size'); end
    
    % Send over the processed structure to makeText to be generated
    makeText(display,currentRender);
end

% Flip the instructions onto the screen
Screen('Flip',display.windowPtr);

% Generate list of allowed keys in a format the KbQueue routines can use
if isempty(allowKeys)
    keyList = ones(1,256);
else
    numKeys = size(allowKeys,2);
    keyList = zeros(1,256); % Disallow all keys on keyboard
    for i=1:numKeys % Loop over all keys, activating allowed keys
        keyList(KbName(allowKeys{i})) = 1;
    end
end

% Wait for an indicated keypress
KbQueueRelease();
KbQueueCreate(device,keyList);
KbQueueStart();
[k.pressed k.fPress k.fRelease k.lPress k.lRelease] = KbQueueWaitCheck();
% Find the first key pressed
keyPress = KbName(find(k.fPress==min(k.fPress(k.fPress~=0))));
% Explanation:
% k.fPress returns times of key presses.  A 0 will go in the place of any
% key not pressed, therefore to find the earliest time you must take the
% minimum of the values in the matrix that *aren't* 0, lest you get a ton
% of values returned for all of the keys set to 0.
