function PSsaveData(subjectParams, newDataSum)
% function PSsaveData(subjectParams, newDataSum)
% save data after running PhaseScrambleStaircase
% Try to merge with existing dataSum if it exists

dataSumName = subjectParams.dataSumName;
sumExists = 1;
try
    load(dataSumName);
catch
    sumExists = 0;
end

fprintf('\n');
if sumExists
    dataSum = [dataSum newDataSum];
    save(dataSumName, 'dataSum');
    disp(['DataSum file ' dataSumName ' updated.']);
else
    disp(['DataSum file ' dataSumName ' not found.']);
    dataSum = newDataSum;
    save(dataSumName, 'dataSum');
    disp(['New dataSum file ' dataSumName ' saved.']);
end

return