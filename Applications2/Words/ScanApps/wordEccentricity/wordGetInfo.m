function wordInfo = wordGetInfo(word,varargin)
% wordInfo = wordGetInfo(word,varargin)
% 
% Purpose
%   Search an excel file containing word parameters for a given word,
%   returning either all or a subset of these parameters in one of two
%   formats (structure or vector);
%
% Input
%   word - A string you'd like to search for
%   varargin - Series of options as follows...
%       output - Format of the output ('structure' or 'vector').  Structure
%                returns a structure wordInfo.word or wordInfo.nonword, which then
%                contains fields pertaining to the word.  Vector returns a structure
%                wordInfo.statsEntries (values) and wordInfo.statsLabels (labels for
%                reference).  The first entry will always be wordType, which is 1 for
%                words and 2 for non-words.
%                [DEFAULT: 'structure']
%       select - Which entries you'd like to return from the excel file if
%                you already know.  Entered in a 1xn cell array containing strings
%                of each column header that you'd like returned.
%                [DEFAULT: empty, processes all columns]
%       directory - Directory in which the excel file is contained.
%                   [DEFAULT: '/Users/rfbowen/matlab/svn/vistadisp/trunk/Applications2/Words/ScanApps/wordEccentricity']
%       file - Name of excel file.
%              [DEFAULT: 'MatchedLists_ResponseSorting.xls']
% Output
%   wordInfo - Structure or vector containing info about word, depending upon
%              inputs as described above.  Returns NaN if it can't find the
%              word in either list.
%
% RFB 2009 [renobowen@gmail.com]

% Set defaults
dir    = '/Users/Shared/ScanData/wordEccentricity/trunk/';
file   = 'MatchedLists_ResponseSorting.xls';
output = 'structure';
select = [];

% Parse options
for ii = 1:2:length(varargin)
	switch lower(varargin{ii})
		case 'output',      output  = varargin{ii+1};
		case 'select',      select  = varargin{ii+1};
        case 'directory',   dir     = varargin{ii+1};
        case 'file',        file    = varargin{ii+1};
	end
end

[wnum wtxt wraw]    = xlsread(fullfile(dir,file),'AllWords');
[nwnum nwtxt nwraw] = xlsread(fullfile(dir,file),'AllNW');

wrow = find(strcmp(word,wraw(:,1)));
nwrow = find(strcmp(word,nwraw(:,1)));

switch lower(output)
    case 'structure'
        if ~isempty(wrow)
            for measures = 2:size(wraw,2)
                if ~isempty(select)
                    if isempty(find(strcmp(wraw{1,measures},select),1)), continue; end
                end
                try
                    eval(sprintf('wordInfo.word.%s = wraw{wrow,measures};',wraw{1,measures}));
                catch
                    fprintf('Couldn''t store info under header ''%s''',wraw{1,measures});
                end
            end
        elseif ~isempty(nwrow)
            for measures = 2:size(nwraw,2)
                if ~isempty(select)
                    if isempty(find(strcmp(nwraw{1,measures},select),1)), continue; end
                end
                try
                    eval(sprintf('wordInfo.nonword.%s = nwraw{nwrow,measures};',nwraw{1,measures}));
                catch
                    fprintf('Couldn''t store info under header ''%s''',nwraw{1,measures});
                end
            end
        else
            wordInfo = NaN;
        end
    case 'vector'
        iteration = 1;
        if ~isempty(wrow)
            wordInfo.statsEntries(1) = 1;
            wordInfo.statsLabels{1} = 'wordType';
            for measures = 2:size(wraw,2)
                if ~isempty(select)
                    if isempty(find(strcmp(wraw{1,measures},select),1)), continue; end
                end
                iteration = iteration + 1;
                wordInfo.statsEntries(iteration)  = wraw{wrow,measures};
                wordInfo.statsLabels{iteration}   = wraw{1,measures};
            end
        elseif ~isempty(nwrow)
            wordInfo.statsEntries(1) = 2;
            wordInfo.statsLabels{1} = 'wordType';
            for measures = 2:size(nwraw,2)
                if ~isempty(select)
                    if isempty(find(strcmp(wraw{1,measures},select),1)), continue; end
                end
                iteration = iteration + 1;
                wordInfo.statsEntries(iteration)  = nwraw{nwrow,measures};
                wordInfo.statsLabels{iteration}   = nwraw{1,measures};
            end
        else
            wordInfo = NaN;
        end
end