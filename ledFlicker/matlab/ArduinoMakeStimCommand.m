function params = ArduinoMakeStimCommand(params)
% Make the sentence for let Audrino work.
% params should inclde params.Conditions.
%
% Conditions.NumWave has these parameters below;
% Freq, Phase, C1.Amp1L, C1.Amp1M, C1.Amp1S, C1.Amp2L, C1.Amp2M, C1.Amp2S
%
% This command gives back us the sentence like this;
%
% [w,0,30,0,1,1,1,0,0,0]
% ,which means 30Hz freq, zero phase difference, equiluminance of LMS in
% one of LED output and no output of the other LED.


Conditions = params.Conditions;

if ~exist('params.NumofCond', 'var')
    params.NumofCond = size(params.Conditions, 2);
end

for ii = 1:params.NumofCond;
    if size(Conditions{ii}.Numwave, 2) == 1;
        C1 = Conditions{ii}.Numwave{1};
        Command = sprintf('[w,%g,%g,%g,%g,%g,%g,%g,%g,%g]'...
            ,0, C1.Freq, C1.Phase, C1.Amp1L, C1.Amp1M, C1.Amp1S, C1.Amp2L, C1.Amp2M, C1.Amp2S);
        params.Conditions{ii}.Command = Command;
        
    elseif Conditions.NumofWave == 2;
        C1 = Conditions{ii}.NumWave{1};
        C2 = Conditions{ii}.NumWave{2};
        Command = sprintf('[w,%g,%g,%g,%g,%g,%g,%g,%g,%g]'...
            ,0, C1.Freq, C1.Phase, C1.Amp1L, C1.Amp1M, C1.Amp1S, C1.Amp2L, C1.Amp2M, C1.Amp2S);
        Command = sprintf('%s[w,%g,%g,%g,%g,%g,%g,%g,%g,%g]'...
            ,Command, 1, C2.Freq, C2.Phase, C2.Amp1L, C2.Amp1M, C2.Amp1S, C2.Amp2L, C2.Amp2M, C2.Amp2S);
        params.Conditions{ii}.Command = Command;
        
    else
        error('Number of waves in each condition should be 1 or 2!')
    end
end