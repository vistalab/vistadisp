function struct = classify_GetMeanTCs(file, trials)

load(file);

nVoxels = length(analysis);
nConds = length(analysis(1).labels);
nTrials = length(trials);

for i = 1:nVoxels
    for ii = 1:nConds
        eval(sprintf('struct.cond_%s(%d,:) = (sum(analysis(%d).allTcs(:, trials, %d),2)/nTrials)'';', ...
            strtrim(analysis(i).labels{ii}), i, i, ii));
    end
end