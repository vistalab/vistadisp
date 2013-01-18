
%%
Duration            = 4    ; % sec
RestDuration        = 12   ; % sec 
SameDurationFlag    = true ; 

SampRatio = 2000;

Phase   = 0;
MeanA   = 0.5;
Amp     = 1;
WinFDur = 0.2;


Ch123sameFlag = true;

StimFrequencies = [0 0.5 1.5 7.5 15 30 60];

for ii = 1:size(StimFrequencies,2)

    Condition(ii).Ch1Freq   = StimFrequencies(ii);
    Condition(ii).Ch1Ph     = Phase;
    Condition(ii).Ch1Amp    = Amp;
    Condition(ii).Ch1Mean   = MeanA;
    Condition(ii).WinFDur   = WinFDur;

    Condition(ii).Ch123sameFlag = true;

    if SameDurationFlag == true ; 
         Condition(ii).Duration = Duration;
    end

    if Condition(ii).Ch123sameFlag == false;
        Condition(ii).Ch2Freq;
        Condition(ii).Ch2Ph;
        Condition(ii).Ch2Amp;
        Condition(ii).Ch2Mean;
        Condition(ii).Ch3Freq;
        Condition(ii).Ch3Ph;
        Condition(ii).Ch3Amp;
        Condition(ii).Ch3Mean;
    end
end

FuncCaracter = 'w';
Channel = 1;

if WinFDur == 0;
    WinFDur = 0.001;
end
CommandEnv  = sprintf('[e,%g,%g]',Duration,WinFDur);
CommandStim = sprintf('[%s,%g,%g,%g,%g,%g]'...
                      ,FuncCaracter,Channel,Freq,Ph,Amp,Mean);

%%
OrderOfCondition = [4 7 3 5 1 6 2 5 7 3 4 1 6 2];

tmp = SampRatio * ((Duration + RestDuration) * size(OrderOfCondition,2));

Signals = zeros(1,tmp);

CheckFlag = true;

for ii = 1:size(OrderOfCondition,2)
    ij = OrderOfCondition(ii);
    Freq    = Condition(ij).Ch1Freq;
    Ph      = Condition(ij).Ch1Ph;
    Amp     = Condition(ij).Ch1Amp;
    Mean    = Condition(ij).Ch1Mean;
    WinFDur = Condition(ij).WinFDur;
    Duration= Condition(ij).Duration;
 
    [Signal Time CheckSig CStime] = ArduinoMakeFlicker(Freq,Ph,Amp,Mean,Duration,WinFDur,SampRatio);
    if CheckFlag == true; figure;plot(CStime,CheckSig);end
    tmp = ((ii - 1) * (Duration + RestDuration));
    Signals( tmp * SampRatio + 1 : (tmp + Duration) * SampRatio + 1) = Signal;
        
    % make rest condtion
    [Signal Time] = ArduinoMakeFlicker(0,0,0,0.5,RestDuration,0,SampRatio);
    Signals((tmp + Duration) * SampRatio + 2 : (tmp + Duration + RestDuration) * SampRatio + 1) = Signal(1:end-1);

end

Times = 0:1/SampRatio:(Duration + RestDuration) * size(OrderOfCondition,2);

figure, plot(Times,Signals)