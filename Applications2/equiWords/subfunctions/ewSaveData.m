function ewSaveData(dataSumName, dataSum, abort)
% function ewSaveData(dataSumName)
% save data after running ewStaircase
% Try to merge with existing dataSum if it exists

if abort
    partFileCheck = 0;
    while ~isempty(partFileCheck)
        partFileCheck = partFileCheck + 1;
        extension = sprintf('part%02d.mat', partFileCheck);
        if ~exist([dataSumName extension],'file')
            save([dataSumName extension],'dataSum');
            disp(['Partial DataSum file ' dataSumName extension ' saved.']);
            return;
        end
    end
else
    dataSum = rmfield(dataSum,'abort');
    save(dataSumName, 'dataSum');
    disp(['DataSum file ' dataSumName ' saved.']);
    launch('SaveSubjSess');
end