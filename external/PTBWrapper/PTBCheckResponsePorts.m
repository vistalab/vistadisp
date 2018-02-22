%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBCheckPortsResponse.m
%
% Checks the value of the MEG response button ports.
%
% Args:
%
% Usage: PTBCheckPortsResponse
%
% Author: Doug Bemis
% Date: 12/4/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [key_codes key_time] = PTBCheckResponsePorts

% Unfortunately, there is some noise on the resonse ports
% Seems like 12/15 is a good ratio...
global PTBPortValues;
key_time = GetSecs;
num_samples = 15;
num_needed = 12;
key_counts = zeros(max(PTBPortValues),1);
for s = 1:num_samples
    kc = getResponsePortKeyCodes();
    key_counts(kc) = key_counts(kc)+1;
end

% Only return those over the required count
key_codes = find(key_counts > num_needed);



function key_codes = getResponsePortKeyCodes()


% This is the mapping of buttons

% Left
%   1 - Top: 16 (LPT2)
%   2 - Yellow: 32 (LPT2)
%   3 - Green: 64 (LPT2)
%   4 - Red: 24 (LPT3)
%   5 - Blue: 216 (LPT3)

% Right
%   6 - Top: 8 (LPT1)
%   7 - Yellow: 16 (LPT1)
%   8 - Green: 32 (LPT1)
%   9 - Red: 64 (LPT1)
%   0 - Blue: 8 (LPT2)

% These are the port numbers to poll
%   LPT1 = 889;  
%   LPT2 = 48353; 
%   LPT3 = 48369; [152 by default]

% Read from the ports
% NOTE: If simultaneous keys are pressed, will just
%   one of them (more or less arbitrarily) for now.
key_codes = [];
port_val_1 = lptread(889);
if port_val_1 > 0
    key_codes = getKeyCodes(port_val_1,1,key_codes,{'6','7','8','9'});
end
port_val_2 = lptread(48353);
if port_val_2 > 0
    key_codes = getKeyCodes(port_val_2,2,key_codes,{'0','1','2','3'});
end

% This one is weird. Only three possible values...
% NOTE: Using the EGI sync seems to cause lptread(48369) to always return a
%   24. So, we're going to disable that key for now...
port_val_3 = lptread(48369);
if port_val_3 ~= 152
    switch port_val_3
        case 24
%             key_codes(end+1) = KbName('4');

        case 216
            key_codes(end+1) = KbName('5');

        % This is both keys, of course...
        case 88
%             key_codes(end+1) = KbName('4');
            key_codes(end+1) = KbName('5');

        otherwise
            disp(['WARNING: Unknown response code recorded on port 3: ' num2str(port_val_3)]);
    end
end


function key_codes = getKeyCodes(port_val,port_num,key_codes,keys)

% Values are binary*8, so 8, 16, 32, 64
if mod(port_val,8) ~= 0
    disp(['WARNING: Unknown response code recorded on port ' ...
        num2str(port_num) ': ' num2str(port_val_1)]);
    return;
end

flags = dec2bin(port_val/8);
for k = 1:length(flags)
    if strcmp(flags(end-k+1),'1')
        key_codes(end+1) = KbName(keys{k}); %#ok<AGROW>
    end
end

