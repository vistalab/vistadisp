function wkRunSession
% wkRunSession
%
% Purpose
%   Present words and non-words in central vision until subjects get the
%   lexical distinction correct.
%
% Inputs
%   N/A
%
% Outputs
%   N/A
%
% [AUTHOR(S)]
% RFB 03/19/09
% CEW - General Structure (Ted Wright [cewright@uci.edu])

[params]    = wkInitParams;
[params]    = wkSubjInfo(params);
[display]   = wkInitDisplay;
[params]    = wkInitDataDir(params);
[params]    = wkInitWordList(params);
[params]    = wkInitDesign(params);

rand('state',sum(100*clock));   % Initialize random numbers

%[subjNum sessNum] = launch('GetSubjSess', '/Users/rfbowen/PsychophysData/wordKnowledge/wkSubjSess');

% Within try/catch, open PTB screen and offscreen windows that we will use.  
try
    HideCursor;
    data = [];
    for blk = 1:2
        [tdat quitFlag] = wkRunBlock(params,display);
        
        data = [data; tdat];
        
        outFile = fullfile(params.dataDir,sprintf('S%02.mat',params.subj));
        save(outFile, 'data');
        
        if quitFlag % If we get a quitFlag back, close down.
            sca;
            return;
        end
    end
catch
    % Close window and shut down PTB screen
    ShowCursor;
    closeScreen(display);
    rethrow(lasterror);
end

% Save data from this session.  Once they are successfully saved, save the
% global variables with the updated next subject number.
ShowCursor;