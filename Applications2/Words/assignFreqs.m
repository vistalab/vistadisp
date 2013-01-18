function newData = assignFreqs(dataSum)
% Assign Frequencies
% newData = assignFreqs(dataSum)
%
% Compile a bunch of data into one structure with huge fields containing
% every word and relevant parameters about those words.  Should be helpful
% for analyzing what effect word frequency/familiarity has on judgments.
%
% May wind up changing the name of the program... hasn't been tested and
% will likely go some revisions.
%
% Make sure you have refList.mat in the directory to be capable of running
% the program.
%
% RFB 02/22/09

% Load MRC database information
load refList.mat
% Gotten with ...
% dict -u -PZ -q -HPSAT -o -RCUIPOV -h -OV -l 4 4 -K -T -B -F -W

% Initialize Variables
newData.mCoh = [];
newData.lCoh = [];
newData.stair = [];
newData.sessn = [];
newData.correct = [];
newData.wordType = [];
newData.words = {};
trial = 0;

% Calculate number of staircases
stairs = length(dataSum(1).stairParams.curStairVars{2});
% Calculate number of sessions
sessns = size(dataSum,2)/stairs;

for i=1:sessns % Go through each session
    for ii=1:stairs % Go through each staircase
        ind = ((i-1)*stairs)+ii; % index into dataSum
        % Ex: third session with 6 staircases each session, third
        % staircase in will be ((3-1)*6)+3 = 15 in dataSum indices
        for iii=1:size(dataSum(ind).history,2) % Go through each trial
            trial = trial+1;
            % Compute the actual motion and luminance coherence for each
            % value in the history of each staircase
            [mCoh lCoh] = cCompute(dataSum(ind).history(iii), ...
                dataSum(1).stairParams.curStairVars{2}(ii));
            % Store the motion coherence, luminance coherence, staircase,
            % session, correct (0 or 1), and which word it was
            newData.mCoh = [newData.mCoh mCoh];
            newData.lCoh = [newData.lCoh lCoh];
            newData.stair = [newData.stair ii];
            newData.sessn = [newData.sessn i];
            newData.correct = [newData.correct dataSum(ind).correct(iii)];
            newData.wordType = [newData.wordType dataSum(ind).wordType(iii)];
            newData.words{trial} = dataSum(ind).word{iii};
        end
    end
end

% At this point newData should have everything lumped together

% Initialize variables...
% Brown Verbal Frequency
newData.bFreq = ones(size(newData.words))*-10;
% Thorndike-Lorge Written Frequency
newData.tFreq = ones(size(newData.words))*-10;
% Kucera-Francis Written Frequency
newData.kFreq = ones(size(newData.words))*-10;
% Familiarity Rating
newData.famil = ones(size(newData.words))*-10;
% Convert strings to chars so they work in functions later
newData.words = char(newData.words);

% Go through every single word compiled together
% Maybe this should be a separate function of its own?
for i = 1:size(newData.words,1)
    % If which word is empty, there was no match and we can't find it in
    % the database; if which word has a number, it indicates the location
    % in the reference list where the word and its information can be found
    whichWord = cellfind(strfind(refList.words,upper(newData.words(i,:))));
    if(~isempty(whichWord))
        % Do this if the word exists on the refList
        newData.bFreq(i) = refList.bFreq(whichWord);
        newData.tFreq(i) = refList.tFreq(whichWord);
        newData.kFreq(i) = refList.kFreq(whichWord);
        newData.famil(i) = refList.famil(whichWord);
    elseif isempty(whichWord) && newData.wordType(i)==1
        % Do this if it's a word but it's not on the refList
        newData.bFreq(i) = -2; 
        newData.tFreq(i) = -2;
        newData.kFreq(i) = -2;
        newData.famil(i) = -2;
    end
end