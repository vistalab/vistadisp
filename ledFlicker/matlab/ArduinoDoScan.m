function [params, SerialPort] = ArduinoDoScan(params, SerialPort)
% 
% Arduino Codes are written for controling to Arduino board, which gives us
% precise temporal frequency of LED blinking. You can change any temporal
% frequency flicker to modify parameters in ArduinoGetParams. If you have
% saved parms file for ArduinoDoScan, you can run this code after loading
% the matfile.
%
% [params, SerialPort] = ArduinoDoScan(params)
% 
% before running the code, please confirm the connection between USB port
% and the Arduino board.
% written by hh - April, 2010

%%
try
    if ~exist('params','var')
        %% as a default, confirm time series with a graph and save all parameters (stimulus condition, sequence, responses, etc)
        params.StimConfirmFlag = true;
        params.savestimparams = true;
        
        %% GetParams
        params = ArduinoGetParams(params);
        
        %% Each Condition should have these parameters;
        % NumWave, Freq, Phase, Amp1L, Amp1M, Amp1S, Amp2L, Amp2M, Amp2S
        % GetCommand characters
        params = ArduinoMakeStimCommand(params);
        
        %% Make Stimulus sequence - using optseq2
        % it takes a litte time to make random representation event related
        % sequence
        params = ArduinoMakeSequence(params);
        
    end
    %% Confirm time series of stimulus
    
%     for NrunSeq = 1:size(params.runSeq, 2);
%         ArduinoConfirmParams(params, params.runSeq{NrunSeq}.seq, NrunSeq);
%     end
    
    %% load mex functions first for temporal accuracy
    % loading mex functions for the first time can be
    % extremely slow (seconds!), so we want to make sure that
    % the ones we are using are loaded.
    KbCheck;GetSecs;WaitSecs(0.001);
    
    %% get devices
    params.devices = getDevices;
    
    if isempty(params.devices.keyInputExternal),
        params.devices.keyInputExternal = params.devices.keyInputInternal(1);
        
    elseif length(params.devices.keyInputExternal) > 1
        params.devices.keyInputExternal = params.devices.keyInputExternal(1);
    end;
    
    fprintf('[%s]:Getting subjects responses from device #%d\n',mfilename,params.devices.keyInputExternal);
    fprintf('[%s]:Getting experimentor''s responses from device #%d\n',mfilename,params.devices.keyInputInternal);
    
    %% Get a serial port
    if notDefined('SerialPort')
        try
            % don't run this sentence twice otherwise you might have some probrems...
            SerialPort = serial('/dev/tty.usbserial-A900ae4s','BaudRate',57600);
        catch SomeError
            disp(SomeError)
            return
        end
    end
    %% open the serial port
    fclose(SerialPort); % to avoid error
    fopen(SerialPort);
    
    %% put the envelope of stimulus
    SafetyMargin = 0.05;
    Envelope = params.Sequence.Envelope;
    StimDurCut = Envelope.StimDur - SafetyMargin;
    Command = sprintf('[e,%g,%g]', StimDurCut, Envelope.Winfunc);
    fprintf(SerialPort, Command);
    
    %% Run the stimuli
    for NrunSeq = 1:size(params.runSeq, 2); % or NrunSeq = ANYNUM;
        ArduinoPressKey2Begin(params);
        countDownArduino(params.startScan+2, params.startScan);
        fprintf('[%s]:Examination %1.0f starts',mfilename, NrunSeq);
        t0 = getSecs;
        params.responses{NrunSeq}  = ArduinoRun(params.Conditions, params.runSeq{NrunSeq}.seq, SerialPort, params.devices);
        ActualTime = getSecs - t0;
        fprintf('[%s]:Stimulus run time: %f seconds [should be: %1.0fs].',...
            mfilename, ActualTime, params.Sequence.ScanTime);
        %% save filename params
        
        if params.savestimparams,
            filename = ['~/Desktop/' datestr(now,30) '.mat'];
            save(filename,'params');                % save parameters
            fprintf('[%s]:Saving in %s.',mfilename,filename);
        end;
    end
    
    %% close serial port
    % if you disconnect arduino before closing the port, matlab will be shut
    % down suddenly.
    fclose(SerialPort);
    delete(SerialPort);
    
catch someError
    disp('Error occurs.')
    disp(someError);   
end