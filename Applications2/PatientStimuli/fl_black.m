
function flinit = fl_black(Window,trigRect)
% Draw black square in corner of screen for photodiode
% Window is an output arg from your OpenWindow cmd, e.g.,
%  [Window, Rect] = Screen('OpenWindow',screenNumber);
% trigRect should be defined outside this function as a proportion of your
% Rect size, a square in the lower right-hand corner of the screen, e.g., 
%  trigRect = [Rect(3)*0.97 Rect(4)*0.95 Rect(3) Rect(4)]; 
% You'll want to use the same trigRect white square every time you display
% a stim that you want to timestamp.
% 
% j.chen 06/10/09
% d.hermes 05/07/12

Screen(Window,'FillRect', 0, trigRect);


