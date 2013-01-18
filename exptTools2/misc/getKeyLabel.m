function response = getKeyLabel(response)
%
% response = getKeyLabel(response)
%

if(~isempty(response.keyCode))
    keyLabel = KbName(response.keyCode);
    if(iscell(keyLabel))
        response.keyLabel = keyLabel{1}(1);
    else
        response.keyLabel = keyLabel(1);
    end
else
    response.keyLabel = '';
end
return;