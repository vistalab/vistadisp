function params = ArduinoMakeSequence(params)

% The unit should be one Time flame ? - it doesn't matter actually. However, if you
% want to use the tool some one made; optseq2 which makes every timing
% adjust to TR.

%% Get some parameters
Sequence            = params.Sequence;
StimDur             = Sequence.Envelope.StimDur;
ScanTime            = Sequence.ScanTime;
TR                  = Sequence.TR;
NumTimeFlame        = ScanTime / TR;
NumofCond           = size(params.Conditions, 2);
PSDwin              = params.Sequence.PSDwin;
NumCandidateParfile = Sequence.NumCandidateParfile;
NumSearch           = Sequence.NumSearch;
filename            = params.filename;


%% Make Tag of parfile for each condition

params = ArduinoGiveTag(params);

%% make command for optseq2
foo = [];

for ii = 1:NumofCond
    foo = sprintf('%s--ev %s %d %d ',...
        foo, params.Conditions{ii}.parfileTag, StimDur, params.Conditions{ii}.StimRept);
end

foo = sprintf('optseq2 --ntp %d --tr %2.1f --psdwin 0 %d %s--nkeep %d --o %s --nsearch %d',...
    NumTimeFlame, TR, PSDwin, foo, NumCandidateParfile, filename, NumSearch);

system(foo)

%% convert pfiles for vistasoft

for ii = 1:NumCandidateParfile
    foo = sprintf('%s-00%1.0f.par', filename, ii);
    convertOptseqtoParfile(foo);
end

%% make sequence from parfile
for ii = 1:NumCandidateParfile
    
    parFilePath = sprintf('%s-00%1.0f_vista.par', filename, ii);
    
    [onsets, conditionOrder, labels, colors] = readParFile(parFilePath);
    
    nonfixIndex     = find(conditionOrder); % non-fixation condition indices
    fixIndex        = find(~conditionOrder);
    
    fixonsets       = onsets(fixIndex);
    nextfixIndex    = fixIndex + 1;
    nextfixIndex(end) = [];
    
    RestDurations = [onsets(nextfixIndex) ScanTime] - onsets(fixIndex);
    
    if size(nonfixIndex,2) * StimDur + sum(RestDurations) == ~ScanTime
        disp('something wrong may occur... please check the time sequence')
    end
    
    Seq = zeros(2, size(conditionOrder,2 ));
    Seq(1, nonfixIndex)   = conditionOrder(nonfixIndex);
    Seq(2, nonfixIndex)   = StimDur;
    Seq(2, fixIndex)      = RestDurations;
    params.runSeq{ii}.seq = Seq;
    
    % keep these parameters for reconstruction of parfile 
    params.parfiles{ii}.onset          = onsets;
    params.parfiles{ii}.cond           = conditionOrder;
    params.parfiles{ii}.label          = labels;
    params.parfiles{ii}.color          = colors;
    
    % if you want to reconstruct a parfile from these parameters,
    % try below;
    %
    % parPath = 'ANYPATH you want.par';
    % for ii = 1:size(params.parfiles{ii}, 2)
    %   writeParfile(params.parfiles{ii},parPath)
    % end
   
end

return


