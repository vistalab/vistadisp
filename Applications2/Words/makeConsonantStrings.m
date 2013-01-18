consonants = 'bcdfghjklmnpqrstvwxz';
% letter frequencies corresponding to each of above consonants
% from http://en.wikipedia.org/wiki/Letter_frequencies
freqs = [1.492 2.782 4.253 2.228 2.015 6.094 0.153 0.772 4.025 2.406 6.749 1.929 0.095 5.987 6.327 9.056 0.978 2.360 0.150 0.074];
stimLength = 4;  % number of characters is string

%% Output file
outDirName = 'stim';
%outDirBasename = '/snarp/u1/bob/fonts';
outDirBasename = '/Users/Shared/AndreasWordsMatlab/EventRelatedCode/PhaseScrambleER/';
if(~exist(fullfile(outDirBasename,outDirName),'dir')) mkdir(outDirBasename,outDirName); end
%fname = mrvSelectFile('w','txt','Output file',outDirBasename);
fname = fullfile(outDirBasename, outDirName, 'consonantStrings.txt');

%% Normalize list of letters by their frequency in English
letterPoolLen = 100;  % how long our list of letters will be
consNormbyFreq = [];
for xx=1:length(consonants)
    numLetters = floor(freqs(xx)*letterPoolLen);
    consNormbyFreq = [consNormbyFreq repmat(consonants(xx),1,numLetters)];
end

%% Make the stimuli and save them out
fid = fopen(fname,'wt');
for stimNum = 1:500
    letters=floor((rand(1,stimLength)*length(consNormbyFreq))+1); % random index of letters for each position in string
    disp(consNormbyFreq(letters));
    stimulusList{stimNum} = consNormbyFreq(letters);
    fprintf(fid,stimulusList{stimNum});
    fprintf(fid,'\n');
end

fclose(fid);
