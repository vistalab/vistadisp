
function flinit = ecogInitPhotodiode(Window,trigRect)
% Flash initiation sequence
% Window is an output arg from your OpenWindow cmd, e.g.,
%  [Window, Rect] = Screen('OpenWindow',screenNumber);
% trigRect should be defined outside this function as a proportion of your
% Rect size, a square in the lower right-hand corner of the screen, e.g.,
%  trigRect = [Rect(3)*0.97 Rect(4)*0.95 Rect(3) Rect(4)];
% You'll want to use the same trigRect white square every time you display
% a stim that you want to timestamp.
%
% j.chen 06/10/09

% Initialize flinit struct (flip info for start sequence)
flinit(1).init(1:4) = 0;
flinit(2).init(1:4) = 0;
flinit(3).init(1:4) = 0;

% Flashing start sequence
for n = 1:4
    Screen(Window,'FillRect', 255, trigRect); %  ***** TRIGGER *******
    [flinit(1).init(n)] = Screen(Window,'Flip');
    Screen(Window,'FillRect', 128);
    Screen(Window,'FillRect', 0, trigRect); %
    Screen(Window,'Flip');
    WaitSecs(0.020);
end
WaitSecs(1);
for n = 1:4
    Screen(Window,'FillRect', 255, trigRect); %  ***** TRIGGER *******
    [flinit(2).init(n)] = Screen(Window,'Flip');
    Screen(Window,'FillRect', 128);
    Screen(Window,'FillRect', 0, trigRect); %
    Screen(Window,'Flip');
    WaitSecs(0.050);
end
WaitSecs(1);
for n = 1:4
    Screen(Window,'FillRect', 255, trigRect); %  ***** TRIGGER *******
    [flinit(3).init(n)] = Screen(Window,'Flip');
    Screen(Window,'FillRect', 128);
    Screen(Window,'FillRect', 0, trigRect); %
    Screen(Window,'Flip');
    WaitSecs(0.100);
end
