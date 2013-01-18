
function [k pauseKey quitKey resumeKey] = getKeyboardOr10key

% d = getDevices;
% if isempty(d.keyInputInternal)
%     fprintf('Laptop keyboard not found! Try restarting MATLAB.\n');
% else
%     lapkey = d.keyInputInternal;
% end
% if isempty(d.keyInputExternal)
%     fprintf('10-key not found! Try restarting MATLAB.\n');
% else
%     tenkey = d.keyInputExternal;
% end
d = PsychHID('Devices');
lapkey = 0;
tenkey = 0;
for n = 1:length(d)
    if strcmp(d(n).usageName,'Keyboard')&&(d(n).productID==560) % laptop keyboard
        lapkey = n;
    elseif strcmp(d(n).usageName,'Keyboard')&&(d(n).productID==38960) % set to 10-key
        tenkey = n;
    end
end
if lapkey==0
    fprintf('Laptop keyboard not found! Try restarting MATLAB.\n');
end
if tenkey==0
    fprintf('10-key not found! Try restarting MATLAB.\n');
end

while 1
    choice = input('Do you want to use [1] laptop keyboard, or [2] 10-key input? ');
    if choice==1
        k = lapkey; 
        pauseKey = 'p';
        resumeKey = 'r';
        quitKey = 'q';
        break
    elseif choice==2
        k = tenkey;         
        pauseKey = '/';
        resumeKey = '*';
        quitKey = '3';
        break
    end
end
