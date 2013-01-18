function params = ArduinoGetParams(params)

%% example 1 
disp(sprintf('[%s]:All of conditions have same amplitudes of LMS cone contrast, phase.', mfilename));
disp(sprintf('[%s]:There is just one wave form, not two.', mfilename));
disp(sprintf('[%s]:A Flickering frequency varies in each condtion.', mfilename));

Conditions = {};
Amp1L = 0.3;
Amp1M = 0.3;
Amp1S = 0.3;
Amp2L = 0;
Amp2M = 0;
Amp2S = 0;

Freq = [10 30];

for ii = 1:size(Freq, 2)
    Conditions{ii}.Numwave{1}.Freq   = Freq(ii);
end

for ii = 1:size(Conditions, 2)
    Conditions{ii}.Numwave{1}.Phase  = 0;
    Conditions{ii}.Numwave{1}.Amp1L  = Amp1L;
    Conditions{ii}.Numwave{1}.Amp1M  = Amp1M;
    Conditions{ii}.Numwave{1}.Amp1S  = Amp1S;
    Conditions{ii}.Numwave{1}.Amp2L  = Amp2L;
    Conditions{ii}.Numwave{1}.Amp2M  = Amp2M;
    Conditions{ii}.Numwave{1}.Amp2S  = Amp2S;
end


for ii = 1:size(Conditions, 2)
    Conditions{ii}.StimRept = 10;    
end

%% sequence prameteres

Envelope.StimDur = 4.5;   % (sec):stimulus duration, which should be integral multiple of TRs for optseq2.
Envelope.Winfunc = 0.5; % (sec):window function duration, which is cosinusoid function now.
Sequence.Envelope = Envelope;

Sequence.ScanTime = 192;    %(sec):total scan time, which should be integral multiple of TRs, Of course.
Sequence.TR       = 1.5;      %(sec):TR
Sequence.PSDwin   = 3;     %(sec):PSD window should ve long enouph catpure response. Post-stimulus delay (PSD = 0 = Stimulus onset)

params.startScan        = Sequence.TR * 2;

% give an error message if you put wrong number
if mod(Sequence.ScanTime, Sequence.TR) + mod(Envelope.StimDur, Sequence.TR) > 0
    error('Stimulus duration and total scan time should be integral multiple of TR.')
end

%% for optseq2
Sequence.NumCandidateParfile = 3;   % how many parfiles will be made in optseq2

Sequence.NumSearch = 100000;        % howa many trial to search the best candidates of random presentation event-related in optseq2 
params.filename = 'test';           % a name pf parfile. In optseq2, <params.filename>-001.par, <params.filename>-002.par, ... 
                                    % After coverting for mrVista, <params.filename>-001_vista.par, <params.filename>-002_vista.par, ... 

%% put parameters in params                                   
params.Conditions = Conditions;
params.Sequence = Sequence;  

return