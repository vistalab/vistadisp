function etFlag = ewETCheck

while 1
    clc;
    etFlag = input('Will you be performing eye tracking during this session? (0 = No, 1 = Yes)\n');
    if etFlag~=0 && etFlag~=1
        disp('[ERROR] - Invalid Input');
        disp('Please re-enter your choice.');
    else
        clc;
        if etFlag==0
            disp('Disabling Eye Tracking');
        elseif etFlag==1
            disp('Enabling Eye Tracking');
        end
        break;
    end
end