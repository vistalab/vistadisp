function [subj] = ewGetSubjParams(dataDir)

subjSessFile = fullfile(dataDir,'ewSubjSess');
if(~exist([subjSessFile '.mat'],'file'))
    launch('Initialize', subjSessFile, true);   % Collect sex info
    fprintf('equiWords Experiment Initialized...\n');
end

[subj.num subj.sess] = launch('GetSubjSess', subjSessFile, true);

dataSumFileName = sprintf('S%02ds%02d',subj.num,subj.sess);
subj.dataSumName   = fullfile(dataDir,dataSumFileName);

