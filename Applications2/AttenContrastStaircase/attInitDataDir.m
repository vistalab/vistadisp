function dataDir = attInitDataDir
% function dataDir = attInitDataDir
% choose the directory to store data for attInitDataDir

MegDataDir = '~/Desktop/Experiments/Winawer/staircase_psychophysics/';
LabDataDir = '/Volumes/server/Projects/MEG/Attention_MEG/staircase_psychophysics/';

global PTBStimTrackerInitialized

if PTBStimTrackerInitialized
    dataDir = MegDataDir;
else
    dataDir = LabDataDir;
end

if ~exist(dataDir, 'dir'), mkdir(dataDir); end

return