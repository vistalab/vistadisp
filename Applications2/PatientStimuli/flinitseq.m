function flinit = flinitseq(Window, trigRect, duration, interval)
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

ifi         = Screen(Window, 'GetFlipInterval');
last_flip   = GetSecs + interval;

% Flashing start sequence
for n = 1:8
    Screen(Window,'FillRect', 255, trigRect); %  ***** TRIGGER *******
        Screen(Window,'Flip', last_flip(n) - (ifi*0.5), 1);  
    Screen(Window,'FillRect', 0, trigRect);
    	Screen(Window,'Flip', last_flip(n) + duration, 1);
end


end

% 
% WaitSecs(1);
% for n = 1:4
%     Screen(Window,'FillRect', 255, trigRect); %  ***** TRIGGER *******
%     [flinit(2).init(n)] = Screen(Window,'Flip',0,1);
%         Screen(Window,'FillRect', 0, trigRect);
%     Screen(Window,'Flip',0,1);
%     WaitSecs(0.050);
% end
% WaitSecs(1);
% for n = 1:4
%     Screen(Window,'FillRect', 255, trigRect); %  ***** TRIGGER *******
%     [flinit(3).init(n)] = Screen(Window,'Flip',0,1);
%         Screen(Window,'FillRect', 0, trigRect);
%     Screen(Window,'Flip',0,1);
%     WaitSecs(0.100);
% end
