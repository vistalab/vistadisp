function [moviesDir,totNumBlocks] = buildWordScanBlocks(sequenceFile, stimsPerBlock, data, params, wStr, nwStr, exptCode, ISIframes)
%
% moviesFile = buildWordScanBlocks(sequenceFile, stimsPerBlock, data,
%        params, wStr, nwStr, [exptCode], [ISIframes])
%
% This function will build the sequence of blocks used for the word scan,
% assigning the stimuli to the blocks (subfields of movies) based on the
% sequence given in sequenceFile.  A new directory is created that
% contains a separate mat file for each block of stimuli.  It saves the
% movies for each block to a file moviesFile under the name movStruct.
%
% SequenceFile is a text file with the following format, where the first
% column is the condition (motion/luminance) and the second column
% specifies whether it's a word, nonword, or noise.
%
% motion word
% motion noise
% luminance word
% luminance noise
% motion nonword
% luminance nonword
% lumtion word --> amr added motion/luminance ("lumtion") mix case 08/21/08
%
% assumptions:
% 1) block lengths are constant and pre-specified
% 2) each block is followed by a blank period of constant duration
%
% How the function works:
% Given our list of words and nonwords, we start with the first one (which means,
% right now, you must randomize your list beforehand- the script will not
% do it for you).  A "for loop" goes through each block.  For every block,
% we will see whether it is a word, nonword, or noise block.  Noise blocks
% will be made from a word, but we won't advance within our list of words
% since by definition the noise stimuli are not readable.  We simply make
% noise conditions illegible by going to the extreme in our params values
% (e.g. making a 0 coherence or making the color of dots the same within
% and outside the form).
% Once we have the blocks, we figure out the sequence of frames to play,
% since we are saving space on luminance "movies" by only creating a single
% frame and replaying this frame several times.  Then we save this block to
% a file for later loading (within doWordScan) and move on to the next
% block.
%
% written by amr 08/04/08
%

if notDefined('exptCode'), exptCode = 1; end;

if notDefined('ISIframes'), ISIframes = 0; end;

pathName = fileparts(sequenceFile);
moviesDir = fullfile(pathName,['MovieBlocks_exptCode_' num2str(exptCode)]);
if ~exist(moviesDir,'dir')
    mkdir(moviesDir);
else
    fprintf('Movie directory %s',moviesDir,' already exists.  Please try again.')
    return
end

fid = fopen(sequenceFile);
cols = textscan(fid,'%s%s');
fclose(fid);

numRefreshesPerFrame = round(params.frameDuration * params.display.frameRate);
framesPerStim = round((params.display.frameRate * params.duration)/numRefreshesPerFrame);

wordCount = 1;
nonwordCount = 1;
noiseCount = 1; % noise condition will use words to make up the stimuli, but these will not be readable.  Just in case we will use different words for each stimulus

totNumBlocks = length(cols{1});
fprintf('Please be patient.  (Total number of blocks: %0.0f)\n\n',totNumBlocks);

%% Big for loop for each block

for blockNum=1:length(cols{1})  %for every block, we'll make a movies structure array consisting of an entry for each stimulus 
    fprintf('Building movies for block %0.0f:  %s  %s\n',blockNum,char(cols{1}(blockNum)),char(cols{2}(blockNum)));%

    %movStruct.stimType = [cols{1}(blockNum) cols{2}(blockNum)];  % word or nonword

    if strcmp(cols{2}(blockNum),'word')
        [blockInfo, wordCount] = ...
            buildWordBlock(cols{1}(blockNum),data.wStrImg,params,framesPerStim,wStr,stimsPerBlock,ISIframes,wordCount);

    elseif strcmp(cols{2}(blockNum),'nonword')
        [blockInfo, nonwordCount] = ...
            buildWordBlock(cols{1}(blockNum),data.nwStrImg,params,framesPerStim,nwStr,stimsPerBlock,ISIframes,nonwordCount);

    elseif strcmp(cols{2}(blockNum),'noise')   % note: don't need to count words in this condition
        % You can change the nature of the "noise" stimulus here by
        % changing the params values for a particular block, making sure to
        % reset those values after (for the next block).

        % Memory for params values to set back
%         old.outFormDir = params.outFormDir;
%         old.inFormDir = params.inFormDir;
%         old.coherence = params.coherence;
         old.inFormRGB = params.inFormRGB;
         old.outFormRGB = params.outFormRGB;
        % initWordParams no longer sets inFormDir and outFormDir separately
        old.dotDir = params.dotDir;
        old.motCoherence = params.motCoherence;

        if strcmp(cols{1}(blockNum),'motion')
            %params.coherence = 1;  %set coherence to 0 for noise stimuli?
            params.motCoherence = 1;
            %params.inFormDir = -params.inFormDir;
            params.dotDir(1) = -params.dotDir(1);
            %params.outFormDir = params.inFormDir; %make a uniformly moving background
            params.dotDir(2) = params.dotDir(1);
        elseif strcmp(cols{1}(blockNum),'luminance')
            %params.coherence = 0;  %set coherence to 0 for noise stimuli
            params.motCoherence = 0;
        end
        [blockInfo, noiseCount] = ...
            buildWordBlock(cols{1}(blockNum),data.wStrImg,params,framesPerStim,wStr,stimsPerBlock,ISIframes, noiseCount);

        % reset old params values
%         params.coherence = old.coherence;
%         params.inFormDir = old.inFormDir;
%         params.outFormDir = old.outFormDir;
%         params.inFormRGB = old.inFormRGB;
%         params.outFormRGB = old.outFormRGB;
        params.motCoherence = old.motCoherence;
        params.dotDir = old.dotDir;
        params.inFormRGB = old.inFormRGB;
        params.outFormRGB = old.outFormRGB;

    else  % not a valid condition
        sprintf('Bad sequence file. Condition not recognized: %s',char(cols{2}(blockNum)))
        return;
    end

%% Save the block to file and erase-- all still within the for loop

    fprintf('Saving movies for block %0.0f\n',blockNum);
    moviesFile = fullfile(moviesDir,['block_' num2str(blockNum) '.mat']);
    save(moviesFile,'blockInfo');
    clear blockInfo;
    clear moviesFile;

end

return;
