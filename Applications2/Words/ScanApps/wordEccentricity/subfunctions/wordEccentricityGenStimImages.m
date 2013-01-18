function wordEccentricityGenStimImages(display,params)

    % Get letter files loaded or generated if they don't exist
    if ~exist(fullfile(params.wordEccDir,'trunk','letters.mat'),'file')
        letters = wordGenLetterVar;
        save(fullfile(params.wordEccDir,'trunk','letters.mat'),'letters');
    else
        load(fullfile(params.wordEccDir,'trunk','letters.mat'));
        letters = data.letters;
    end

    % Set xHeights for letters (this may change to being loaded from elsewhere)
    xHeights = {...
        '1degLeft'          .30; ...
        '1degRight'         .30; ...
        '3degLeft'          .50; ...
        '3degRight'         .50; ... 
        '6degLeft'          .80; ...
        '6degRight'         .80; ...
        '1degUp'            .30; ...
        '1degDown'          .30; ...
        '3degUp'            .50; ...
        '3degDown'          .50; ... 
        '6degUp'            .80; ...
        '6degDown'          .80; ...          
        };
    
    for run = 1:params.numRuns
        dirOpened = zeros(size(xHeights, 1),1);
        fid = fopen(fullfile(params.wordEccDir, 'checkerboards', sprintf('stimOrderRUN%02d.txt', run)), 'w');
        listTMP = eval(sprintf('params.run%02.0f;',run)); % Set words in run into tmp var
        for wordIndex = 1:length(listTMP)
            fprintf(fid, '%02d\n', mod(wordIndex, 2) + 1);
            [i j] = find(strcmpi(params.conditionName{wordIndex},xHeights));
            xHeightTMP = xHeights{i,2};
            [img wordParams] = wordGenerateImage(display,letters,listTMP{wordIndex}, ...
                'xHeight', xHeightTMP);
            img = wordEccentricityAdjustContrast(img,242,128);
                            
            wordStimDir = fullfile(params.wordEccDir,'stim',xHeights{i,j});
            if ~exist(wordStimDir, 'dir')
                mkdir(wordStimDir);
            end
            
            checkerStimDir = fullfile(params.wordEccDir, 'checkerboards', 'stim', xHeights{i,j});
            if ~exist(checkerStimDir, 'dir')
                mkdir(checkerStimDir);
            end
            
            if (~dirOpened(i))
                dirOpened(i) = 1;

                % Make checkerboards and save them out
                checkerboard = makeCheckerboard(round(wordParams.output.xHeight.pix/2), [4 10]);
                cbimgNorm = wordEccentricityAdjustContrast(checkerboard, 242, 128);
                cbimgInvert = wordEccentricityAdjustContrast(checkerboard, 128, 242);
                imwrite(cbimgNorm, fullfile(checkerStimDir, '01.bmp'));
                imwrite(cbimgInvert, fullfile(checkerStimDir, '02.bmp'));
                
            end
            imwrite(img,fullfile(wordStimDir,[listTMP{wordIndex} '.bmp']));
            save(fullfile(params.wordEccDir,'stim',xHeights{i,j},[listTMP{wordIndex} '.mat']), 'wordParams');
        end
        fclose(fid);
    end    
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