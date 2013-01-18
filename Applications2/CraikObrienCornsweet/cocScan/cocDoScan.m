function cocDoScan(params)
% cocDoScan(params)
%
% Runs edge presentation scans
%
% 99.08.12 RFD wrote it, consolidating several variants of retinotopy scan code.
% 05.06.09 SOD modified for OSX, lots of changes.
% 04/2006  SOD converted from doRetinotopyScan
% 05/2008  JW converted from doLocScan

% defaults
if ~exist('params', 'var')
	error('No parameters specified!');
end

% quit key
try, 
    quitProgKey = params.display.quitProgKey;
catch,
    quitProgKey = KbName('q');
end;

% make/load stimulus
[stimulus] = cocMakeStimulus(params);


% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that 
% the ones we are using are loaded.
KbCheck;GetSecs;WaitSecs(0.001);

try,
    % check for OpenGL
    AssertOpenGL;
    
    % Open the screen
    params.display                = openScreen(params.display);
    params.display.devices        = params.devices;

    % to allow blending
    %Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Store the images in textures
    stimulus = createTextures(params.display,stimulus);

    % getting to the source rather than doScan->doTrial->showStimulus 
    for n = 1:params.repetitions,
        % set priority
        Priority(params.runPriority);
        
        % wait for go signal
        pressKey2Begin(params.display, false);      

        % countdown + get start time (time0)
        [time0] = countDown(params.display,params.startScan+2,params.startScan);

        % go
        [response, timing, quitProg] = showScanStimulus(params.display,stimulus,time0);
        
        % reset priority
        Priority(0);
        
        % get performance
        [pc,rc,nn] = getFixationPerformance(params.fix,stimulus,response);
        fprintf('[%s]:Fixation dot task(%d): percent correct: %.1f %%, reaction time: %.1f secs\n',mfilename,nn,pc,rc);
                
        if params.savestimparams,
            filename = ['~/Desktop/' datestr(now,30) '.mat'];
            save(filename);                % save parameters
            fprintf('[%s]:Saving in %s.\n',mfilename,filename);
        end;
        
        % keep going?
        if quitProg, % don't keep going if quit signal is given
            break;
        end;
    end;
    
    % Close the one on-screen and many off-screen windows
    closeScreen(params.display);
catch ME
    % clean up if error occurred
    Screen('CloseAll');
    setGamma(0);
    Priority(0);
    ShowCursor;
    warning(ME.message);
end;
