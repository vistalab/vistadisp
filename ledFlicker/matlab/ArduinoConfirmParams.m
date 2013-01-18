function ArduinoConfirmParams(params, runSeq, NrunSeq);


Conditions  = params.Conditions;
Sequence    = params.Sequence;
Envelope    = Sequence.Envelope;
Winfunc     = Envelope.Winfunc;
ScanTime    = Sequence.ScanTime;

SampRatio = 500;
%% get condition vs time
TP = cumsum([0 runSeq(2,:)]); TP(end) = Sequence.ScanTime;
CP = runSeq(1,:); CP = [CP CP(end)];

%% get signal intensity vs time

WholeTime = 0 : TP(end) * SampRatio;
Signal    = zeros(6,size(WholeTime,2));

for ii = 1 : size(runSeq, 2)
    Condinds  = runSeq(1,ii);
    if Condinds == 0;
        
    else
        NumTime = 0 : (TP(ii+1) - TP(ii)) * SampRatio;
        ph12LMS = zeros(6, size(NumTime,2));
        
        if size(Conditions{Condinds}.Numwave, 2) == 1
            C = Conditions{Condinds}.Numwave{1};
            BasicWave = sin(2*pi .* NumTime * C.Freq / SampRatio + 2*pi*C.Phase);
            ph12LMS(1,:) = BasicWave * C.Amp1L;
            ph12LMS(2,:) = BasicWave * C.Amp1M;
            ph12LMS(3,:) = BasicWave * C.Amp1S;
            ph12LMS(4,:) = BasicWave * C.Amp2L;
            ph12LMS(5,:) = BasicWave * C.Amp2M;
            ph12LMS(6,:) = BasicWave * C.Amp2S;
            
        else disp('sorry. underconstruction')
        end
    
        % Cosine window function
        if Winfunc > 0
            NumAtten = round(SampRatio * Winfunc);
            windFunc = 0.5 * cos([pi:pi/(NumAtten-1):2*pi]) + 0.5;
            ph12LMS(:,1:NumAtten) = ph12LMS(:,1:NumAtten) .* repmat(windFunc, 6,1);
            ph12LMS(:,end-NumAtten+1:end) = ph12LMS(:,end-NumAtten+1:end) .* fliplr(repmat(windFunc, 6,1));
        end
        
        T = (TP(ii) * SampRatio : TP(ii+1) * SampRatio) + 1;
        Signal(:,T) = ph12LMS;        
    end
end

%% draw graphs

figure('position',[0,0, 1200,600]);
subplot(2,1,1), h = stairs(TP, CP, 'k','LineWidth', 3);
set(gca,'yTick',0:size(params.Conditions,2));
grid on

conname{1} = '0 - NoFlicker';
for ii = 1:size(params.Conditions,2)
    conname{ii+1} = sprintf('%g - %3.1fHz',ii, params.Conditions{ii}.Numwave{1}.Freq);
end
set(gca,'yTickLabel', conname);

ylabel('conditions'), xlabel('time(s)');
axis tight, ylim([-0.5 0.5 + size(params.Conditions,2)]);
Titlename = sprintf('Examination %d', NrunSeq);
title(Titlename)

Time = 0:1/SampRatio:ScanTime;    
subplot(2,1,2), hold on

zeroSignal = zeros(1,6);
h          = zeros(1,6);

for ii = 1:6
    if sum(Signal(ii,:)) ~=0
    h(ii) = plot(Time,Signal(ii,:));
    zeroSignal(ii) = sum(Signal(ii,:));
    end
end

tmp = find(zeroSignal);

try set(h(1), 'Color', 'r', 'Line','-'); catch; end;
try set(h(2), 'Color', 'g', 'Line','-'); catch; end;
try set(h(3), 'Color', 'b', 'Line','-'); catch; end;
try set(h(4), 'Color', 'r', 'Line','--'); catch; end;
try set(h(5), 'Color', 'g', 'Line','--'); catch; end;
try set(h(6), 'Color', 'b', 'Line','--'); catch; end;


Tags = {'W1 L','W1 M','W1 S','W2 L','W2 M','W2 S'};

switch  params.Conditions{1}.w1name
    
    case 'equal'
        Titlename = 'W1 equal ';
    case 'L cone isolated'
        Titlename = 'W1 L cone isolated ';
    case 'M cone isolated'
        Titlename = 'W1 M cone isolated ';
    case 'S cone isolated'
        Titlename = 'W1 S cone isolated ';
    otherwise
        Titlename = [];
end


switch  params.Conditions{1}.w2name
   
    case 'equal'
        Titlename = sprintf('%sW2 equal', Titlename);
    case 'L cone isolated'
        Titlename = sprintf('%sW2 L cone isolated', Titlename);
    case 'M cone isolated'
        Titlename = sprintf('%sW2 M cone isolated', Titlename);
    case 'S cone isolated'
        Titlename = sprintf('%sW2 S cone isolated', Titlename);
    otherwise
        Titlename = sprintf('%s', Titlename);
end

legend(Tags{tmp}); title(Titlename);
ylabel('LMS amplitude'), xlabel('time(s)')
axis tight

drawnow

return    