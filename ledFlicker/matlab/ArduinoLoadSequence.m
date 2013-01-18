function params = ArduinoLoadSequence(params)


%% Get some parameters
Sequence            = params.Sequence;
StimDur             = Sequence.Envelope.StimDur;
ScanTime            = Sequence.ScanTime;

%% Make Tag of parfile for each condition

params = ArduinoGiveTag(params);

%% convert pfiles for vistasoft
Existfiles = dir('*_vista.par');
if isempty(Existfiles)
    try
        ExistOtherfiles = dir('*.par');
        Ans = input('Found some parfiles in this directory. Do you want to convert them for mrVista? (y/n)');
        if Ans == 'y'
            for ii = 1:size(ExistOtherfiles,1)
                VistaParfilePath{ii} = convertOptseqtoParfile(ExistOtherfiles(ii).name);
            end
        elseif Ans == 'n'
            error('abort the process');
        else
            error('abort the process');
        end        
    catch
        disp('.parfile does not exist here')
    end
else disp('vista.par file has already exist here.')
    Ans = input('Found some vista_parfiles in this directory. Do you want to use all of them? (y/n)');
    for ii = 1:size(Existfiles,1)
        if Ans == 'y'
            VistaParfilePath{ii} = Existfiles(ii).name;
        else
            error('abort the process');
        end
    end
end

%% make sequence from parfile
for ii = 1:size(VistaParfilePath, 2)
    
    [onsets,conditionOrder,labels,colors] = readParFile(VistaParfilePath{ii});
    
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
    
end