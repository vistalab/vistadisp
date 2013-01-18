function params = wkInitDataDir(params)

if ~exist(params.dataDir,'dir')
    mkdir(params.dataDir);
end
