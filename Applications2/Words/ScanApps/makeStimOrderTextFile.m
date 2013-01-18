function [stimList stimOrderFilePath] = makeStimOrderTextFile(blockOrder,numStimsPerBlock,checkerFlag,dummyBlockType)
% Make a stim order text file for a block-type scan.  This was used to make
% stimOrder text files for the RotatingWordLocalizer (RotatingWordLocalizer/stim/stimOrder_WvUD1.txt)
% blockOrder should be e.g. 'ABCABC'
% if checkerFlag = 1, then blocks of type C will be treated as checkerboards,
% which will alternate between check and revcheck


stimList = []; % initialize stimList
if ~isempty(dummyBlockType) && ~strcmp(dummyBlockType,'Fix')
    blockOrder = [dummyBlockType blockOrder];  % add dummy block to beginning of list of blocks
end

% input word list file
originalStimList = mrvSelectFile('r','txt','Choose file with list of word stimuli',pwd);
fid = fopen(originalStimList);
col = textscan(fid,'%s');
fclose(fid);
stims = col{1};
stims = Shuffle(stims);  % randomize order

% output word list file
stimOrderFilePath = mrvSelectFile('w','txt','Choose or create stimOrder txt file',fileparts(originalStimList));
fid = fopen(stimOrderFilePath,'wt');

% create and write out stimOrder text file
curStimNum = 1;
checkCount = 1;
for blockNum = 1:length(blockOrder)
    if strcmp(blockOrder(blockNum),'C') && (checkerFlag == 1)      % special case of a checkerboard block
        for stimNum = 1:numStimsPerBlock
            checkCount = checkCount + 1;
            if mod(checkCount,2)==0  % alternate by checking whether count is even or odd
                curstim = 'check';
            else
                curstim = 'revcheck';
            end
            fprintf(fid,'%s\n',curstim);
            stimList = [stimList {curstim}];
        end
        
    else   % anything but checkerboards uses real words
        for stimNum = 1:numStimsPerBlock
            if curStimNum > length(stims)
                curStimNum = 1;
                disp('WARNING: List of words not long enough for unique stimuli.  Repeating list!')
            end
            fprintf(fid,'%s\n',stims{curStimNum});
            stimList = [stimList {stims{curStimNum}}];
            curStimNum = curStimNum + 1;
        end
    end
end

stimList = stimList';
fclose(fid);

return