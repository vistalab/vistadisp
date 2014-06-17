function dataDir = attInitDataDir
% function dataDir = attInitDataDir
% choose the directory to store data for attInitDataDir

dataDir = '/Volumes/server/Projects/MEG/Attentional_MEG/staircase_psychophysics/';

if(~exist(dataDir,'dir')), mkdir(dataDir); end

return