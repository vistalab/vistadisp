function [deviceNumKeyboard deviceNumButtonbox] = getDeviceNumbers_osx;

% copied from JC's getBoxNumber & getKeyboardNumber
% detecting laptop internal keyboard and buttonbox, and get devices numbers
% if not detected, returns zero
% sungjin, 9/25/07

d=PsychHID('Devices');
deviceNumKeyboard = 0;
deviceNumButtonbox = 0;
for n = 1:length(d)
    if (d(n).productID == 535) & strcmp(d(n).usageName,'Keyboard');
        deviceNumKeyboard = n;
        break;
    end
end
for n = 1:length(d)
    if (d(n).productID == 612) & (strcmp(d(n).usageName,'Keyboard'))
        deviceNumButtonbox = n;
    end
end
if deviceNumKeyboard == 0
    fprintf(['\n KEYBOARD NOT FOUND. Check the productID number.\n']);
else
    fprintf('\n Laptop Internal Keyboard Device Number: %i\n',deviceNumKeyboard);
end
if deviceNumButtonbox == 0
    fprintf(['\n Button box NOT FOUND.\n']);
else
    fprintf('\n Button Box Device Number: %i\n',deviceNumButtonbox);
end
       
return;