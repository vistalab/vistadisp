%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetPortInput.m
%
% Turns on and off the port input method.
%
% Args:
%	- value: 1 (on) or 0 (off)
%
% Usage: PTBSetPortInput(1)
%
% Author: Doug Bemis
% Date: 1/31/13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetPortInput(value)

% Set
global PTBPortInput;
global PTBPortValues;

% And check if we can use the Ports option
if value == 1
    try
        test_val = lptread(889); %#ok<NASGU>

        % For later, let's see what the port values can be
        port_responses = 0:9;
        PTBPortValues = zeros(length(port_responses),1);
        for i = 1:length(port_responses)
            PTBPortValues(i) = KbName(num2str(port_responses(i)));
        end
        
    catch %#ok<CTCH>
        
        % Show to the console
        disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');
        disp('Unable to read from response ports.');
        disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');

        % And to the screen
        PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
            'Unable to read from response ports.','WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
        PTBDisplayBlank({.1},'Ports warning');
        PTBPortInput = 0;
        return;	
    end
    PTBPortInput = 1;
    
% Don't need to do much to turn off...
else
    PTBPortInput = 0;
end

