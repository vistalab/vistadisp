function [Signal Time CheckSig CStime] = ArduinoMakeFlicker(Freq,Ph,Amp,Mean,Duration,WinFDur,SampRatio);
%% Comfirm Stimuli
if Freq < 10 && Freq > 2
    ShortPeriod = 1:(SampRatio+1);
elseif Freq >= 10
    ShortPeriod = 1:(SampRatio+1) / 5;
elseif Freq == 0
    ShortPeriod = 1:(SampRatio+1);
else
    ShortPeriod = 1: SampRatio * Duration + 1;
end

NumTime = 0 : Duration * SampRatio;
ph = 2*pi .* NumTime * Freq  / SampRatio + 2*pi*Ph;
tmp     = sin(ph) ./ 2;

% Cosine window function
if WinFDur > 0
    NumAtten = round(SampRatio * WinFDur);
    windFunc = 0.5 * cos([pi:pi/(NumAtten-1):2*pi]) + 0.5;
    tmp(1:NumAtten) = tmp(1:NumAtten) .* windFunc;
    tmp(end-NumAtten+1:end) = tmp(end-NumAtten+1:end) .* fliplr(windFunc); 
end

Signal = tmp .* Amp + Mean;
Time = 0:1/SampRatio:Duration;
CheckSig = Signal(ShortPeriod);
CStime = Time(ShortPeriod);
return