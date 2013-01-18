function wordMatchDistribution(bins,property,varargin)

% wordMatchDistribution(bins,property,varargin)
%
% Purpose
%   Given a reference word list, create a non-word list whose distribution in
%   regards to a statistic of your choosing is matched.  This is done through
%   a process of binning and counting, and thus depending on how precise you
%   want this matching to be, you can vary the number of bins you will break
%   up the statistics of the word distribution into.
%
% Inputs
%   bins - Precision of the match - more bins = more precision
%   property - Value you plan to match between the two distributions
%   varargin - Series of options as follows...
%       'dataDir' - String of directory where files exist and will be stored
%       'sourceFileName' - String of name of .xls file containing word list and stats
%       'outFileName' - String of name for non-word list output file
%       'statFileName' - String of name for stats output file
%       'wordSheet' - String of label for sheet in .xls containing words
%       'nonWordSheet' - String of label for sheet in .xls containing non-words
%
% Outputs
%   N/A
%
% RFB 2009 [renobowen@gmail.com]

    params = wordSetDefaults(bins,property);

    % Parse options
    for ii = 1:2:length(varargin)
        switch lower(varargin{ii})
            case 'datadir',         params.dataDir = varargin{ii+1};
            case 'sourcefilename',  params.sourceFileName = varargin{ii+1};
            case 'outfilename',     params.outFileName = varargin{ii+1};
            case 'statfilename',    params.statFileName = varargin{ii+1};
            case 'wordsheet',       params.wordSheet = varargin{ii+1};
            case 'nonwordsheet',    params.nonWordSheet = varargin{ii+1};
            case 'makematfile',     params.makeMatFile = varargin{ii+1};
            case 'matfilename',     params.matFileName = varargin{ii+1};
        end
    end

    params = wordLoadLists(params);
    params = wordComputeBinSizes(params);
    params = wordBinCounts(params);
    params = wordMatchBins(params);
    params = wordWriteList(params);
    wordCompareStatistics(params);
         
end

function params = wordSetDefaults(bins,property,varargin)
    
    params.dataDir          = '/Users/Shared/PsychophysData/equiWords/trunk/';
    params.sourceFileName   = 'wordList.xls';
    params.outFileName      = 'matchedNonWords.txt';
    params.statFileName     = 'matchedNonWordsSTATS.txt';
    params.wordSheet        = 'wordList';
    params.nonWordSheet     = 'nonWordList';
    params.matFileName      = 'wordList.mat';
    params.makeMatFile      = 0;
    params.bins             = bins;
    params.property         = property;

end

function params = wordLoadLists(params)

    [n a params.words]  = xlsread(fullfile(params.dataDir,params.sourceFileName),params.wordSheet);
    [n a params.nwords] = xlsread(fullfile(params.dataDir,params.sourceFileName),params.nonWordSheet);
    wPropertyInd        = strcmp(params.property,params.words(1,:));
    params.wDist        = cell2mat(params.words(2:end,wPropertyInd));
    nPropertyInd        = strcmp(params.property,params.nwords(1,:));
    params.nDist        = cell2mat(params.nwords(2:end,nPropertyInd));

end


function params = wordComputeBinSizes(params)

    binWidth            = 1/params.bins;
    width               = max(params.wDist)-min(params.wDist);
    adjBinWidth         = width*binWidth;
    params.intervals    = min(params.wDist):adjBinWidth:max(params.wDist);

end

function params = wordBinCounts(params)

    params.wBinCount = zeros(1,params.bins);
    params.wBinCount(1)     = sum(params.wDist>=params.intervals(1) & params.wDist<=params.intervals(2));
    for i=2:(length(params.intervals)-1)
        params.wBinCount(i) = sum(params.wDist>params.intervals(i) & params.wDist<=params.intervals(i+1));
    end

end

function params = wordMatchBins(params)

    params.indices(1:params.wBinCount(1)) = randsample(find(params.nDist>=params.intervals(1) & params.nDist<=params.intervals(2)),params.wBinCount(1));
    for i=2:(length(params.intervals)-1)
        params.indices(end+1:end+params.wBinCount(i)) = randsample(find(params.nDist>params.intervals(i) & params.nDist<=params.intervals(i+1)),params.wBinCount(i));
    end

end

function params = wordWriteList(params)

    numeric = zeros(1,size(params.nwords,2));
    
    fid = fopen(fullfile(params.dataDir,params.outFileName),'w');
    
    for entry=1:size(params.nwords,2)
        params.list(:,entry)   = params.nwords(params.indices+1,entry);
        numeric(entry)  = isnumeric(params.list{1,entry});
        fprintf(fid,'%s, ',params.nwords{1,entry});
    end

    fprintf(fid,'\n');

    for row=1:size(params.list,1)
        for entry=1:size(params.list,2)
            if numeric(entry)
                fprintf(fid,'%f, ',params.list{row,entry});
            else
                fprintf(fid,'%s, ',params.list{row,entry});
            end
        end
        fprintf(fid,'\n');
    end

    fclose(fid);

end

function wordCompareStatistics(params)

    fid = fopen(fullfile(params.dataDir,params.statFileName),'w');
    fprintf(fid,' , ');
    
    for entry=2:size(params.nwords,2)
        entryType               = params.nwords{1,entry};
        fprintf(fid,'%s, ',entryType);
        wPropertyInd            = strcmp(entryType,params.words(1,:));
        nPropertyInd            = strcmp(entryType,params.nwords(1,:));
        stats.wColAvg(entry-1)  = mean(cell2mat(params.words(2:end,wPropertyInd)));
        stats.wColStd(entry-1)  = std(cell2mat(params.words(2:end,wPropertyInd)));
        stats.nColAvg(entry-1)  = mean(cell2mat(params.list(:,nPropertyInd)));
        stats.nColStd(entry-1)  = std(cell2mat(params.list(:,nPropertyInd)));
    end
    fprintf(fid,'\n');
    
    fprintf(fid,'wAverage, ');
    for entry=2:size(params.nwords,2)
        fprintf(fid,'%f, ',stats.wColAvg(entry-1));
    end
    fprintf(fid,'\n');
    
    fprintf(fid,'wStd, ');
    for entry=2:size(params.nwords,2)
        fprintf(fid,'%f, ',stats.wColStd(entry-1));
    end
    fprintf(fid,'\n');
    
    fprintf(fid,'nAverage, ');
    for entry=2:size(params.nwords,2)
        fprintf(fid,'%f, ',stats.nColAvg(entry-1));
    end
    fprintf(fid,'\n');
    
    fprintf(fid,'nStd, ');
    for entry=2:size(params.nwords,2)
        fprintf(fid,'%f, ',stats.nColStd(entry-1));
    end
    fprintf(fid,'\n');
    
    fclose(fid);
    
    if params.makeMatFile
        wList = params.words(2:end,1);
        nList = params.list(:,1);
        save(fullfile(params.dataDir,params.matFileName),'wList','nList');
    end

end

