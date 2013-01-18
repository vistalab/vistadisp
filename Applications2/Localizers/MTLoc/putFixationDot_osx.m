function [answer col] = putFixationDot_osx(w,rect,fixSize,task,varargin);
%
% Usage: answer = putFixationDot_osx(w,rect,fixSize);
%
% task: 1=do fixation task, 0=just put a regulat white dot
% Puts a fixation dot (size="fixSize") at the center of screen
%
% sungjin 07/2007 

if nargin>4
    for i = 1:2:length(varargin)
        switch lower(varargin{i})
            case 'color', col = varargin{i+1};
            case 'keyforyes', keyForYes = varargin{i+1};
        end
    end
end

% if ~exist('keyForYes','var');
%     keyForYes = 44; %space
% end

if task==1
    if ~exist('col','var')
        taskNum = ceil(rand*2);
        switch taskNum
            % to find keycodes, use KbDemo
            case 1, col = [255 0 0]; answer = keyForYes; % keycode for YES
            case 2, col = [0 0 255]; answer = 31; % keycode for 2@
        end
    else
        if col==[255 0 0]; answer = keyForYes; 
        elseif col==[0 0 255]; answer = 31; 
        else warning('check input color \n');
        end
    end
elseif task==0
    col = 255;
else 
    warning('task not defined \n');
end    

X = rect(3); Y = rect(4);

screen('FillRect', w, col, CenterRect([0 0 fixSize-2 fixSize], [0 0 X Y]));
screen('FillRect', w, col, CenterRect([0 0 fixSize fixSize-2], [0 0 X Y]));
% screen('Flip', w);

return

