function commands = parseString(string,separator)

if ~exist('separator','var')
    separator = '|';
end

% use | symbol as statement separator
stringBreaks = findstr(string,separator);

if isempty(stringBreaks)
    commands{1} = string;
else
    if stringBreaks(1) ~= 1
        commands{1} = string(1:stringBreaks(1)-1);
        for piece = 1:length(stringBreaks)
            if length(stringBreaks)>piece
                commands{1+piece} = string(stringBreaks(piece)+1:stringBreaks(piece+1)-1);
            else % last segment
                if stringBreaks(piece)+1>length(string)
                    commands{1+piece} = [];
                else
                    commands{1+piece} = string(stringBreaks(piece)+1:end);
                end
            end
        end
    else
        for piece = 1:length(stringBreaks)
            if length(stringBreaks)>piece
                commands{piece} = string(stringBreaks(piece)+1:stringBreaks(piece+1)-1);
            else % last segment
                if stringBreaks(piece)+1>length(string)
                    commands{piece} = [];
                else
                    commands{piece} = string(stringBreaks(piece)+1:end);
                end
            end
        end
    end
end