function retResetColorMap(params)
% retResetColorMap(params)
%
% 4/2010, JW: Broken off from doRetinotopyScan
%
% For some reason, the experiments '8 bars (slow)', '8 bars (LMS)', and '8
% bars (LMS) with blanks' have some special demands for setting the
% colormaps. This bit of code is for those three experiments only. For any
% other experiment, there is NO ACTION taken.


switch params.experiment,
    case {'8 bars (slow)'},
        % get subject input on stimulus contrast
        answer = 'a';
        while (~isnumeric(answer) || isempty(answer)),
            % say it just in case the screen is in mirror mode and you
            % cannot see the screen
            if params.display.screenNumber == 0,
                eval('system(sprintf(''say please enter percent stimulus contrast.''));');
            end;
            answer = input('Please enter percent stimulus contrast [100]: ');
        end;
        sz = size(params.display.gamma,1)*([-1 1]*answer/100/2+0.5);
        if sz(1)==0,sz(1)=1;end;
        % make new gamma
        putgamma = zeros(256,3);
        putgamma(2:255,:) = params.display.gamma(round(linspace(sz(1),sz(2),254)),:);
        % load gamma
        putgamma(1,:)   = params.display.fixColorRgb(1,1:3)./255;
        putgamma(256,:) = params.display.fixColorRgb(2,1:3)./255;
        Screen('LoadNormalizedGammaTable', params.display.screenNumber,putgamma);
        
    case {'8 bars (LMS)','8 bars (LMS) with blanks'},
        % get subject input on stimulus type
        answer = 'a';
        while (~isnumeric(answer) || isempty(answer) || answer>3 || answer<1),
            % say it just in case the screen is in mirror mode and you
            % cannot see the screen
            if params.display.screenNumber == 0,
                eval('system(sprintf(''say please enter  stimulus type 1, 2, or 3.''));');
            end;
            answer = input('Please enter  stimulus type [1=LMS,2=L-M,3=S]: ');
        end;
        if answer == 1,
            stimtype = [ 1 1 1];
        elseif answer == 2,
            stimtype = [-1 1 0];
        else
            stimtype = [0 0 1];
        end;
        
        % get subject input on stimulus contrast
        answer = 'a';
        while (~isnumeric(answer) || isempty(answer) || answer<0 || answer>100),
            % say it just in case the screen is in mirror mode and you
            % cannot see the screen
            if params.display.screenNumber == 0,
                eval('system(sprintf(''say please enter percent stimulus contrast 0 to 100.''));');
            end;
            answer = input('Please enter percent stimulus contrast: ');
        end;
        stimcontrast = answer;
        
        % these lines appear not to be used:
        % sz = size(params.display.gamma,1)*([-1 1]*answer/100/2+0.5);
        % if sz(1)==0, sz(1)=1;end;
        
        % make new gamma
        newgamma = create_LMScmap(params.display,stimtype.*(stimcontrast./100));
        putgamma = zeros(256,3);
        if size(newgamma,1)~=256,
            putgamma(2:255,:) = newgamma(round(linspace(1,size(newgamma,1),254)),:);
        end;
        % load gamma
        putgamma(1,:)   = params.display.fixColorRgb(1,1:3)./255;
        putgamma(256,:) = params.display.fixColorRgb(2,1:3)./255;
        Screen('LoadNormalizedGammaTable', params.display.screenNumber,putgamma);
        
        
        
    otherwise,
        % well.. nothing
end;
return;
