% Practice trials (outside scanner) for response sorting

% Load words
ScanName = 'ResponseSorting';  % Enter the name of your functional scan here (important)
baseDir = ['/Users/Shared/AndreasWordsMatlab/EventRelatedCode/' ScanName];
wordstimFilePath = fullfile(baseDir,'stim','wordlists','PracticeTrials_wordlist.txt');
if ~exist(wordstimFilePath,'file')
    try
        wordstimFilePath = mrvSelectFile('r','txt','Select your word list',[baseDir '/stim']);
    catch
        wordstimFilePath = mrvSelectFile('r','txt','Select your word list',pwd);
    end
end
fid = fopen(wordstimFilePath);
cols = textscan(fid,'%s');
fclose(fid);
stims=cols{1};
    
for curWordNum = 1:20  %length(stims)
    curStim = stims{curWordNum};
    scr = (1-(1/curWordNum));  % more and more difficult
    curImg = scrambleWord(curStim,scr,1);
    figure(33)
    h= imshow(curImg,'InitialMagnification',300);
    %movegui(h,'northwest')
    pause
end