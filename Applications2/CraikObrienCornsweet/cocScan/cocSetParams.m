function params = cocSetParams(params)
% params = cocSetParams([params])
%
% Sets parameter values for the Craik-O'Brien-Cornsweet experiment.  Some
% fields should already be set (probably from GUI) when this function is
% called. This function sets the rest of the fields.
%
% 1999.08.12 RFD rewrote WAP's code with a cleaner wrapper.
% 2005.07.04 SOD ported to OSX; several changes
% 2006.04.05 SOD ported from ret to loc
% 2008.05.02 JW ported from loc to coc. All parameter setting farmed out to
%   subroutines.
%

%% Set the parameters
params = cocSetHousekeepingParams(params);
params = cocSetDisplayParams(params);
params = cocSetColorParams(params);
params = cocSetTimingParams(params);
params = cocSetStimulusParams(params);
params = cocSetFixationParams(params);

%Some checks
cocParamsCheck(params);


