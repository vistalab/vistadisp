function wordEccentricityParseTxt(filename, displayToUse)

    if (notDefined('filename')), filename = 'stimOrder.txt'; end
    if (notDefined('displayToUse')), displayToUse = '3T2_projector_2010_09_01'; end
    
    display = loadDisplayParams('displayName', displayToUse);
    wordEccDir = '/Users/Shared/ScanData/wordEccentricity';
    
    fidWord = fopen(fullfile(wordEccDir, 'stim', filename), 'r');
    wordList = textscan(fidWord, '%s');

    fidChecker = fopen(fullfile(wordEccDir, 'checkerboards', 'stim', 'stimOrder.txt'), 'w');
    checkerString = '01\n02\n';
    nReps = size(wordList{1}, 1) / 2;
    checkerString = repmat(checkerString, [1 floor(nReps)]);
    if (rem(nReps, floor(nReps))), checkerString = [checkerString '01\n']; end

    fprintf(fidChecker, checkerString);
    wordEccentricityGenStimImages2(display, wordEccDir, wordList{1});
end