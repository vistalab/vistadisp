function makeTextRenderingBMPs(stimDir, outDir)
%
%           makeTextRenderingBMPs(stimDir, outDir)
%
% Ported from makeDegradedStimuli in RotatingWords directory
%
%  created by amr 2/3/09

font = 'Monospaced';
fontSize = 10;
sampsPerPt = 8;
rotations = 0;  % list of rotations amounts in degrees

if notDefined('outDirBase') || isempty(outDir)
    outDirBase = 'stim';
end

% read in all the words
if notDefined('stimDir') || isempty(stimDir)
    if exist('/Users/Shared/AndreasWordsMatlab/WordFiles','dir')
        WordStimFile = mrvSelectFile('r','txt','Select file with stimuli','/Users/Shared/AndreasWordsMatlab/');
    else
        WordStimFile = mrvSelectFile('r','txt','Select file with stimuli',pwd);
    end
    if isempty(WordStimFile), disp('No stimuli selected!'); %user cancelled
        wordlist=[];
    else
        fid = fopen(WordStimFile);
        tempStrs = textscan(fid,'%s');
        fclose(fid);
        for ii = 1:length(tempStrs{1})
            wordlist(ii)=tempStrs{1}(ii);  % get them out of the cell array
        end
        clear tempStrs;
    end
end

% Render text and save out images for rotations
%numStimsPerRotation = floor(length(wordlist)/length(rotations));
%wordlist = Shuffle(wordlist);  % reorder the stimuli out of alphabetic order

dirNum = 1;
for wordIndex = 1:length(wordlist)
        % render text
        curWord = wordlist{wordIndex};
        fprintf('%s%0.0f%s%s\n','Rendering text # ',wordIndex,': ',wordlist{wordIndex});
        wordImg = renderText(curWord,font,fontSize,sampsPerPt);
        
                % invert into black text on white background
        index_text = find(wordImg==1);
        index0 = find(wordImg==0);
        wordImg(index_text)=0.5;  % mark the text as gray to differentiate from black artifact of rotation
        wordImg(index0)=1; % make the background around the text white
        
        for numRotations = 1:length(rotations)
            deg = rotations(numRotations);
            outDir = [outDirBase];  %num2str(dirNum)
            outFname = [curWord '.bmp'];  % the file name
            outPath = fullfile(outDir, outFname);  % the full path
            rotWordImg = imrotate(wordImg, deg);  % rotate the image by deg degrees (pos is counter-clockwise, neg is clockwise)
            index0 = find(rotWordImg==0);  % find black areas (artifact of rotation and sizing)
            rotWordImg(index0) = 1; % turn the black areas white
            index_gray = find(rotWordImg == 0.5);
            rotWordImg(index_gray) = 0;  % turn the text black again
            index_background = find(rotWordImg == 1);  % background is white at this step
            rotWordImg(index_background) = 0.5; % make the background gray
            imwrite(rotWordImg, outPath, 'BMP');  % write out the new image
            dirNum = dirNum+1;
            if dirNum > length(rotations)
                dirNum = 1;
            end
        end
        
        dirNum = dirNum + 1;
        if dirNum > length(rotations)
            dirNum = dirNum - length(rotations);
        end
end

return