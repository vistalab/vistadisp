
function getKey(key,k);

% Waits until user presses the specified key.
% Usage: getKey('a')
% Janice Chen 02/01/06

while 1
    while 1
        [keyIsDown,secs,keyCode] = KbCheck(k);
        if keyIsDown
            while KbCheck end
            break;
        end
    end
    theAnswer = KbName(keyCode);
    if ismember(key,theAnswer)  % this takes care of numbers too, where pressing 1 results in 1!
        break
    end
end
