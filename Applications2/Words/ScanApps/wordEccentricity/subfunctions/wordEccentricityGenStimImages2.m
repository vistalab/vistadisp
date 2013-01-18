function wordEccentricityGenStimImages2(display, wordEccDir, wordList)

    % Get letter files loaded or generated if they don't exist
    if ~exist(fullfile(wordEccDir, 'trunk', 'letters.mat'), 'file')
        letters = wordGenLetterVar;
        save(fullfile(wordEccDir, 'trunk', 'letters.mat'), 'letters');
    else
        load(fullfile(wordEccDir, 'trunk', 'letters.mat'));
        letters = data.letters;
    end
    
    % Set xHeights for letters (this may change to being loaded from elsewhere)
    xHeights = {...
        '1degRight'         .30; ...
        '1degLeft'          .30; ...
        '3degRight'         .50; ...
        '3degLeft'          .50; ...
        '6degRight'         .80; ...
        '6degLeft'          .80; ...
        '1degUp'            .30; ...
        '1degDown'          .30; ...
        '3degUp'            .50; ...
        '3degDown'          .50; ... 
        '6degUp'            .80; ...
        '6degDown'          .80; ...          
        };
    
    for condIndex = 1:size(xHeights, 1)
%         fid = fopen(fullfile(params.wordEccDir, 'checkerboards', sprintf('stimOrder.txt', run)), 'w');
%         listTMP = eval(sprintf('params.run%02.0f;',run)); % Set words in run into tmp var
        %% Set up parameters
        condition   = xHeights{condIndex, 1};
        xHeight     = xHeights{condIndex, 2};
        wordStimDir = fullfile(wordEccDir, 'stim', condition);
        checkerStimDir = fullfile(wordEccDir, 'checkerboards', 'stim', condition);
        
        if (~exist(wordStimDir, 'dir')), mkdir(wordStimDir); end
        if (~exist(checkerStimDir, 'dir')), mkdir(checkerStimeDir); end

        %% Make words
        for wordIndex = 1:length(wordList)
            word = wordList{wordIndex};
            [img wordParams] = wordGenerateImage(display, letters, word, ...
                'xHeight', xHeight);
            img = wordEccentricityAdjustContrast(img, 242, 128);

            imwrite(img, fullfile(wordStimDir, [word '.bmp']));
            save(fullfile(wordEccDir, 'stim', condition, [word '.mat']), 'wordParams');
        end
        
        %% Make checkerboards
        checkerboard = makeCheckerboard(round(wordParams.output.xHeight.pix/2), [4 10]);
        cbimgNorm = wordEccentricityAdjustContrast(checkerboard, 242, 128);
        cbimgInvert = wordEccentricityAdjustContrast(checkerboard, 128, 242);
        imwrite(cbimgNorm, fullfile(checkerStimDir, '01.bmp'));
        imwrite(cbimgInvert, fullfile(checkerStimDir, '02.bmp'));
    end
    %fclose(fid);
end

function checkerboard = makeCheckerboard(xHeight, checkerDims)
    buildingBlock = [zeros(xHeight) ones(xHeight); ones(xHeight) zeros(xHeight)];
    checkerboardRows = xHeight * checkerDims(1);
    checkerboardCols = xHeight * checkerDims(2);
    oversizeBlockRows = ceil(checkerboardRows/size(buildingBlock, 1));
    oversizeBlockCols = ceil(checkerboardCols/size(buildingBlock, 2));
    oversizeCheckerboard = repmat(buildingBlock, oversizeBlockRows, oversizeBlockCols);
    checkerboard = oversizeCheckerboard(1:checkerboardRows, 1:checkerboardCols);
end