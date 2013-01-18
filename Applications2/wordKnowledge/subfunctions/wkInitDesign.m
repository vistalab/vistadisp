function params = wkInitDesign(params)

params.lexicon      = [zeros(1,length(params.nList)) ones(1,length(params.wList))];
params.stimList     = [params.nList params.wList];
params.stimFreq     = params.repeatList*ones(1,length(params.lexicon));
