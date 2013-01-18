function [params] = scissionSetHousekeepingParams(params)

params.type = params.experiment; 
params.startScan   = 0;
params.quitProgKey = KbName('q');
params.stereoFlag = 0;
params.seqDirection = 0;	% 0 or 1- just plays the movie backwards if set to 1
params.showProgess = true;

return