function cocSaveData(subjectParams, newDataSum)
% Save data after running GaborStaircase
%
%   GaborSaveData(dataSumName)

% Try to merge with existing dataSum if it exists

dataSumName = subjectParams.dataSumName;

try
    eval('load(dataSumName)');
    dataSum = [dataSum newDataSum];
    save(dataSumName, 'dataSum');
    disp(['DataSum file ' dataSumName ' updated.']);
catch
    disp(['DataSum file ' dataSumName ' not found.']);
    dataSum = newDataSum;
    save(dataSumName, 'dataSum');
    disp(['New dataSum file ' dataSumName ' saved.']);
end

return