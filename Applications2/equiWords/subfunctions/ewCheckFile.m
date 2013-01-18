function [content,fileName] = ewCheckFile(fileName,contentString,saveOption)

content = [];
if ~exist('saveOption','var'), saveOption=0; end

if exist(fileName,'file')
    content = load(fileName);
else
    fileName = mrvSelectFile('r','mat',['Load ' contentString]);
    if isempty(fileName)
        disp(['Load ' contentString ' - CANCELLED']);
        if saveOption
            fileName = mrvSelectFile('w','mat',['Save ' contentString]);
            if isempty(fileName)
                disp(['Save ' contentString ' - CANCELLED']);
            else
                disp(['Save ' contentString ' - PROCEEDING']);
            end  
        end
    else
        content = load(fileName);
        disp(['Load ' contentString ' - COMPLETED']);
    end
end