function [allMPBF,meanMPBF,stdMPBF,allMPLF,freq] = bigramFreq(wordsFile,freqType)
%
%  [allMPBF,meanMPBF,stdMPBF,allMPLF,freq] = bigramFreq([wordsFile],[freqType])
%
% This function returns the mean positional bigram frequency (MPBF) for
% each word in a list of words (wordlist), as well as the mean and standard
% deviation across that list.  Positional bigram frequency is defined as
% the sum of the frequency of all words (within refList.m) that have a given bigram at
% the same index.  The MPBF is the mean of the PBFs for all the bigrams in the word.
% For more information on how to calculate the MPBF, see Binder et al (2006), Neuroimage.
%
%   inputs
%       wordsFile:  txt file or array of list of words for which you want MPBFs
%       freqType:  can be kFreq, tFreq, or bFreq
%           kFreq:  Kucera-Francis Written Frequency
%           tFreq:  Thorndike-Lorge Written Frequency
%           bFreq:  Brown Verbal Frequency
%   outputs
%       allMPBF:    array of MPBFs for each word
%       meanMPBF:   MPBF across all words in list
%       stdMPBF:    standard deviation of MPBF across words in list
%       allMPLF:    array of mean positional letter frequency for each word
%       freq:       frequency information for words in wordsFile
%
% Currently, this code only works for 4 letter words because only those are
% in the stored database (refList.mat).  We could extract the statistics of
% other words from the MRC Psycholinguistic Database website.
%
% Given all the for loops that could have been avoided, this code is
% incredibly inefficient.  Sorry.
%
% written by amr June 29, 2009
%

if notDefined('freqType')
    freqType = 'kFreq';  % Kucera-Francis written frequency is default
end

if notDefined('wordsFile')
    wordsFile = mrvSelectFile('r','txt','Select word list...',pwd);
    if isempty(wordsFile), return, end
end

% load in wordlist from txt file or from cell array
if ischar(wordsFile)  % then it's probably a path
    fid = fopen(wordsFile);
    cols = textscan(fid,'%s');
    fclose(fid);
    wordlist=cols{1};
    charwordlist = char(wordlist);
elseif iscell(wordsFile)
    wordlist = wordsFile;  % if it's not a file, we assume it's a list of words
    charwordlist = char(wordlist);
else
    disp('Not a valid wordlist.  Must be cell array or txt file path.')
    return
end

load refList.mat  % contains frequency statistics for all 4-letter words

%% First, get the frequencies of all the words in the list

% Get freq for every word in list
for i = 1:length(wordlist)
    % If which word is empty, there was no match and we can't find it in
    % the database; if which word has a number, it indicates the location
    % in the reference list where the word and its information can be found
    whichWord = cellfind(strfind(refList.words,upper(charwordlist(i,:))));
    if(~isempty(whichWord))
        % Do this if the word exists on the refList
        freqInfo.bFreq(i) = refList.bFreq(whichWord);
        freqInfo.tFreq(i) = refList.tFreq(whichWord);
        freqInfo.kFreq(i) = refList.kFreq(whichWord);
        freqInfo.famil(i) = refList.famil(whichWord);
    elseif isempty(whichWord)
        % Do this if it's a word but it's not on the refList
        freqInfo.bFreq(i) = -2; 
        freqInfo.tFreq(i) = -2;
        freqInfo.kFreq(i) = -2;
        freqInfo.famil(i) = -2;
    end
end

freq = eval(['freqInfo.' freqType]);  % get the frequency information for the frequency of choice

%% Get the MBPF of each word by averaging the PBF of each bigram for each word

refFreqType = eval(strcat('refList.',freqType));
for curWordNum = 1:length(wordlist)  % for each word in the input word list
    PBF(1:length(wordlist{1})-1) = 0;
    for bigramNum = 1:(length(wordlist{1})-1)  % THIS ASSUMES ALL WORDS ARE SAME LENGTH AS FIRST WORD  % for each bigram within that word
        refInds = [];
        curWord = char(wordlist(curWordNum));
        curBigram = curWord(bigramNum:bigramNum+1);
        for curRefNum = 1:length(refList.words)  % compare to same bigram in all the reference words
            curRefWord = char(refList.words(curRefNum));
            curRefBigram = curRefWord(bigramNum:bigramNum+1);
            if strcmp(curBigram,curRefBigram)  % then this reference word has same bigram at same position, so include
                refInds = [refInds curRefNum];
            end
        end
        refNoFreqInds = refInds(find(refFreqType(refInds)<0));  % reference words without frequency information
        usableRefInds = setdiff(refInds,refNoFreqInds);
        numWordsUsed = length(usableRefInds);
        PBF(bigramNum) = sum(refFreqType(usableRefInds));
    end
    allMPBF(curWordNum) = mean(PBF(~isnan(PBF)));  % don't use NaNs
    
    for letterNum = 1:length(wordlist{1})  % get MPLF (letter frequency)
        refInds = [];
        curWord = char(wordlist(curWordNum));
        curLetter = curWord(letterNum);
        for curRefNum = 1:length(refList.words)  % compare to same letter position in all the reference words
            curRefWord = char(refList.words(curRefNum));
            curRefLetter = curRefWord(letterNum);
            if strcmp(curLetter,curRefLetter)  % then this reference word has same letter at same position, so include
                refInds = [refInds curRefNum];
            end
        end
        refNoFreqInds = refInds(find(refFreqType(refInds)<0));  % reference words without frequency information
        usableRefInds = setdiff(refInds,refNoFreqInds);
        PLF(letterNum) = sum(refFreqType(usableRefInds));
    end
    allMPLF(curWordNum) = mean(PLF(~isnan(PLF)));  % don't use NaNs
end

% Get the mean and std MPBF
meanMPBF = mean(allMPBF);
stdMPBF = std(allMPBF);

%save('BigramInfo.mat','allMPBF','meanMPBF','stdMPBF');

return


