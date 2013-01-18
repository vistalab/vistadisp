function [dataDir] = cocInitDataDir
% function [dataDir] = cocInitDataDir
% choose the directory to store data for cocStaircase

dataDir = '/Users/Shared/PsychophysData/cocStaircase';

if(~exist(dataDir,'dir')),
    dataDir = '~/matlab/VISTADISP/Applications2/CraikObrienCornsweet/psychophysics';
end

if(~exist(dataDir,'dir')),
    mkdir(dataDir);
end

return