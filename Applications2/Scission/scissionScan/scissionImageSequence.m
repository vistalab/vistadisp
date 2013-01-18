function [sequence] = scissionImageSequence(params)

%% aquire parameters
durationStimframe     = params.stimulus.stimframe;
nStimFramesPerScan    = params.ncycles * params.period ./ durationStimframe;
nStimframesPrescan    = round(params.prescanDuration./durationStimframe);
nStimframesPerCycle   = round(params.period./durationStimframe);
NumOfDevision         = params.stimulus.NumOfDevision;
NumOfReptOneCycle     = params.stimulus.NumOfReptOneCycle;
DurationShortOneCycle = 1 / params.stimulus.frequency;
ShortCycleRepetition  = params.period / DurationShortOneCycle / NumOfDevision;
numImages             = NumOfDevision * NumOfReptOneCycle * round(1 / params.stimulus.frequency / params.stimulus.stimframe);
% params.period * params.stimulus.frequency / params.stimulus.NumOfDevision
% should be integer...

%% make subsequence
nStimframesShortCycle = nStimframesPerCycle / NumOfDevision / ShortCycleRepetition;
nStimframesSubsequence= nStimframesShortCycle * ShortCycleRepetition ;

Subsequence1 = zeros(1, nStimframesPerCycle); ii = 1;

% make sequence within one cycle
while  all(Subsequence1) ~= 1,
    
    Subsequence2 = zeros(1, nStimframesSubsequence); ik = 1;
    % make reptition of same direction
    while  all(Subsequence2) ~= 1,
        ij = 1 + (ii - 1) *  nStimframesShortCycle;       
        tmp = [ij : ij - 1 + nStimframesShortCycle];
        Subsequence2( 1 + (ik-1) * nStimframesShortCycle : ik * nStimframesShortCycle) = tmp;
        ik = ik + 1;
    end
    Subsequence1(1 + (ii-1) * nStimframesSubsequence : ii * nStimframesSubsequence ) = Subsequence2;
    ii = ii + 1;
end

% make sequence across whole scanned cycle
sequencePerScan = repmat(Subsequence1, 1, nStimFramesPerScan / nStimframesPerCycle);

% pick up from aquired sequence randamly if you have some image sets of one cycle
if NumOfReptOneCycle ~= 1;
    a = [1:NumOfReptOneCycle]';
    b = ones(NumOfReptOneCycle,1) * sequencePerScan;
    c = (a - 1) * numImages / NumOfReptOneCycle;
    d = ones (1, nStimFramesPerScan);

    sequencePerScanMatrix = b + c * d;

    n = size(sequencePerScanMatrix, 2); 
    tmp = rand(n,NumOfReptOneCycle)';
    tmp = 1 + tmp - (repmat(max(tmp), NumOfReptOneCycle, 1));
    tmp(tmp < .999999999) = 0;
    sequencePerScan = tmp .* sequencePerScanMatrix;
    sequencePerScan = round(max(sequencePerScan));
end

% make whole sequence including prescan
sequencePreScan = sequencePerScan((end - nStimframesPrescan) + 1 : end);
sequence = [sequencePreScan sequencePerScan];


return