function params = retCreateDefaultGUIParams(curdata)
% params = retCreateDefaultGUIParams([curdata])
%
% set default values for ret params
%
% If new parameters are added to the ret code, this file should be updated.
%
% Example: 
%   params = retCreateDefaultGUIParams
%
% Example 2: 
%
%   params.fixation = 'dot';
%   params = retCreateDefaultGUIParams;
%
% May, 2010, JW: Split off from retMenu



if ~exist('curdata', 'var'), curdata = []; end

params.experiment      = '8 bars with blanks';
params.fixation        = 'double disk';
params.modality        = 'fMRI';
params.savestimparams  = 1;
params.repetitions     = 1;
params.runPriority     = 7;
params.skipCycleFrames = 0;
params.prescanDuration = 12;%seconds
params.period          = 192;%seconds
params.numCycles       = 1;
params.motionSteps     = 8; % number of checkerboard positions per luminance cycle
params.tempFreq        = 2; % frequency of checkerboard flicker (Hz)
params.contrast        = 1; % checkerboard contrast
params.interleaves     = NaN;
params.tr              = 1.5;%seconds
params.loadMatrix      = 'None';
params.saveMatrix      = 'None';
params.calibration     = 'None';
params.stimSize        = 'max';
params.countdown       = 0;
params.startScan       = 0;
params.trigger         = 'Scanner triggers computer';
params.triggerKey      = '5';
% If we input params, then use this for all defined fields
if ~isempty(curdata)
    s = fieldnames(params);
    for ii = 1:length(s)
        if isfield(curdata, s{ii})
            params.(s{ii}) = curdata.(s{ii});
        end
    end
end

return
