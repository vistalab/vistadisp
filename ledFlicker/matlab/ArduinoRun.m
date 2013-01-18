function responses = ArduinoRun(Conditions, runSeq, Serial, devices)
% runSeq should be n x 2 matrix. First low indicates the conditions and
% second one durations (s). I gave up to add the function to stop this
% sequence with 'q'uit key due to get high temoral accuracy. However, it
% doesn't matter pussing ctrl+c to stop the sequence because Arduino
% functions don't use 'Screen' functions in psychtoolbox.

%% get some parametes
NumofSeq            = size(runSeq,2);    % sum of how many times to send command to Arduino and to rest
responses.keyCode   = zeros(1,NumofSeq); % get 1 buttons max
responses.secs      = zeros(1,NumofSeq);

%% main foop for running Audrino

T = 0; % actual total time
t0 = getSecs; % start time

for ii = 1:NumofSeq
    Totaltime = sum(runSeq(2,1:ii));
    
    if runSeq(1,ii) == 0    % just wait in resting state
        disp(sprintf('[%s %1.0fsec]:<Condition 0> No flickering. Duration: %1.0f sec.',...
            mfilename, Totaltime, runSeq(2,ii)));
        
    else % we'll send 'commands' to Audrino
        Condinds  = runSeq(1,ii);
        Command = Conditions{Condinds}.Command;
        Command = sprintf('%s[p]',Command);
        
        % Run Arduino
        fprintf(Serial, Command);
        disp(sprintf('[%s %1.0fsec]:<Condition %1.0f> Freq %g Hz. Duraition: %1.0f sec. %s',...
            mfilename, Totaltime, Condinds,...
            Conditions{Condinds}.Numwave{1}.Freq,...
            runSeq(2,ii),...
            Conditions{Condinds}.parfileTag));
    end
    
    % wait and get responses
    while T < Totaltime
        T = getSecs - t0;
        % Scan the keyboard for subject response
        %         [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(devices.keyInputExternal);
        [ssKeyIsDown,ssSecs] = KbCheck(devices.keyInputExternal);
        if(ssKeyIsDown)
            responses.keyCode(ii) = 1; % binary response for now
            responses.secs(ii)    = ssSecs - t0;
        end;
    end
end

return

