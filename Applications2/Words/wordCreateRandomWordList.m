function [outputlists,outFiles] = wordCreateRandomWordList(inputlistPath,numItems,numLists)
%
% Function to read in a list of words (or nonwords), choose some subset of
% them, randomly order them, and output numItems number of UNIQUE lists.
% 
% inputlist is a textfile with a list of words or nonwords
% numItems is how many items you want in each outputlist
% numLists is how many outputlists will be created
%
% outputlists is a cell array of lists of output stimuli
% outFiles is a cell array of path names of output files
%
% New lists are saved as textfiles in same directory as inputlistPath.
%
%       [list,outFile] = wordCreateRandomWordList(inputlist,numItems)
%
% written by amr March 3, 2009
%

%% Gather inputs if not defined
if notDefined('inputlistPath')
    inputlistPath = mrvSelectFile('r','txt','Choose list of words to randomize','/Users/Shared/AndreasWordsMatlab/EventRelatedCode/PhaseScrambleER/stim');
    if isempty('inputlistPath'), return, end;
end
if notDefined('numItems')
    numItems = input('How long do you want your new lists to be?  ');
end
if notDefined('numLists')
    numLists = input('How many lists do you want?  ');
end

%% Read in the list
fid=fopen(inputlistPath);
tmp = textscan(fid,'%s');
inputlist = tmp{1};
fclose(fid);

%% Check to make sure there are enough items to make new lists
if length(inputlist) < (numItems*numLists)
    fprintf('\nYou do not have enough items in your input list\nto make as many lists with as many items as you want!\n')
    return
end

%% Shuffle the list
inputlist = Shuffle(inputlist);

%% Make new lists and output
[outFilesBase,inFname] = fileparts(inputlistPath);
% create a separate list and a separate file for each list
for listnum=1:numLists
    outFiles{listnum} = fullfile(outFilesBase, [inFname num2str(numItems) 'Items_list' num2str(listnum) '.txt']);  %outputfile pathname for this list
    fid = fopen(outFiles{listnum},'wt');
    
    startItem = ((listnum-1)*numItems)+1;
    endItem = startItem+numItems-1;
    outputlists{listnum}=inputlist(startItem:endItem);
    
    curlist = outputlists{listnum};
    for x=1:length(curlist), fprintf(fid,'%s\n',curlist{x}); end
    fclose(fid);
end


return