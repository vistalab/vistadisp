function params = wkInitWordList(params)

load(fullfile(params.dataDir,'trunk',params.wordList));
load(fullfile(params.dataDir,'trunk','letters.mat'));

params.wList    = wList;
params.nList    = nList;
params.letters  = data.letters;