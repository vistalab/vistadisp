function params = setRetinotopyParams(expName, params)
% setRetinotopyParams - set parameters for different retinotopy scans 
%
% params = setRetinotopyParams([expName], [params])
%
% Sets parameter values for the specified expName.  
%
% params is a struct with at least the following fields:
%  period, numCycles, tr, interleaves, framePeriod, startScan, prescanDuration
%
% Returns the parameter values in the struct params.
%
% 99.08.12 RFD rewrote WAP's code with a cleaner wrapper.
% 05.07.04 SOD ported to OSX; several changes
% 05.2010  JW  moved code into subroutines to improve readability

disp(['[' mfilename ']:Setting stimulus parameters for ' expName '.']);

% Common defaults (Can be overwritten depending on fixation and experiment)
params = retSetCommonDefaults(params, expName);

% Experiment-specific parameters
params = retSetExperimentParams(params, expName);

% Fixation parameters 
params = retSetFixationParams(params, expName);

% Modality parameters (fMRI, EEG, MEG, ECoG)
params = retSetModalityParams(params);

% Derived parameters (not to be updated by user)
params = retSetDerivedParams(params);

% some checks, must be done before we reset certain params
params = retParamsCheck(params);
