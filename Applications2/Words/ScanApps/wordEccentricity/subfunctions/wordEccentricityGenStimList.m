function params = wordEccentricityGenStimList(params)

fields      = fieldnames(params); % Get all of the fields in params
runFields   = strfind(fields,'run'); % Find how many fields start with 'run'
params.numRuns     = length(cellfind(runFields)); % Count these fields
stimDir     = fullfile(params.wordEccDir, 'stim');
if (~exist('stimDir', 'dir'))
    mkdir(stimDir);
end
for run = 1:params.numRuns
    runTMP = eval(sprintf('params.run%02.0f;',run)); % Set words in run into tmp var
    blkTMP = eval(sprintf('params.blockNumber%02.0f;',run)); % Set block order tags into a tmp var
    prepareToSort = [blkTMP, runTMP];
    runTMP = sortrows(prepareToSort,1);
    runTMP = runTMP(:,2);
    fid = fopen(fullfile(stimDir, sprintf('stimOrderRUN%02.0f.txt',run)),'w+');
    for wordIndex = 1:length(runTMP)
        fprintf(fid,'%s\n',runTMP{wordIndex});
    end
    fclose(fid);
end