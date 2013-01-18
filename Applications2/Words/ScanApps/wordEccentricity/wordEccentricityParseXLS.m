function wordEccentricityParseXLS(xlsName, displayToUse)

if (notDefined('xlsName')), xlsName = 'wordEccentricityUD.xls'; end
if (notDefined('displayToUse')), displayToUse = '3T2_projector_2010_09_01'; end

display = loadDisplayParams('displayName', displayToUse);
params.wordEccDir = '/Users/Shared/ScanData/wordEccentricity';
[num txt raw] = xlsread(fullfile(params.wordEccDir, 'trunk', xlsName));

extractLabels = {'condition','conditionName', ...
                 'blockNumber01', ...
                 'blockNumber02', ...
                 'blockNumber03', ...
                 'blockNumber04', ...
                 'blockNumber05', ...
                 'run01','run02','run03', 'run04', 'run05'};
for labels=1:length(extractLabels)
    [r c] = find(strcmpi(raw(1,:),extractLabels{labels}));
    eval(sprintf('params.%s = raw(2:end,c);',extractLabels{labels}));
end

params = wordEccentricityGenStimList(params);
wordEccentricityGenStimImages(display,params);