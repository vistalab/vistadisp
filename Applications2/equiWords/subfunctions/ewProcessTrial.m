function [data,curStrImg] = ewProcessTrial(display,data,stimParams)

wordType = stimParams.wordType;

if(wordType=='W')
    data.curWStr = data.curWStr+1;
    
    % If we've exhausted the list of words, repeat word list
    if(data.curWStr>numel(data.wStrInds))
        data.curWStr = 1;
        data.wStrInds = Shuffle(data.wStrInds);
        disp('NOTE: Repeating the word list.');
    end
    
    % Set current stimulus to the next word in the list

    curStrImg = wordGenerateImage(display,data.letters,data.wList{data.wStrInds(data.curWStr)},'xHeight',stimParams.xHeight);
    
elseif(wordType=='N')
    data.curNStr = data.curNStr+1;
    
    % If we've exhausted the list of nonwords, repeat nonword list
    if(data.curNStr>numel(data.nStrInds))
        data.curNStr = 1;
        data.nStrInds = Shuffle(data.nStrInds);
        disp('NOTE: Repeating the nonword list.');
    end
    
    % Set current stimulus to the next nonword in the list
    curStrImg = wordGenerateImage(display,data.letters,data.nList{data.nStrInds(data.curNStr)},'xHeight',stimParams.xHeight);
end