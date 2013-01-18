function [dataDir] = fovInitDataDir
% function [dataDir] = fovInitDataDir
% choose the directory to store data for fovStaircase

dataDir = '~/PsychophysData/fovStaircase';

if(~exist(dataDir,'dir')),
    mkdir(dataDir);
end

return