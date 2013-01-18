function [dataDir] = ewInitDataDir
% function [dataDir] = ewInitDataDir
% choose the directory to store data for ewStaircase

dataDir = '/Users/Shared/PsychophysData/equiWords';

if(~exist(dataDir,'dir')),
    mkdir(dataDir);
end