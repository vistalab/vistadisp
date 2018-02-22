function PTBWaitForClearResponsePorts

% % NOTE: The channels are noisy, so wait for at least this many "all clears"
% %   in a row. Last check showed a max of 3 when a button was pressed.
% num_clears = 10;
% is_clear = 0;
% while ~is_clear
%     is_clear = 1;
%     for i = 1:num_clears
%         if ~isempty(PTBCheckResponsePorts)
%             is_clear = 0;
%             break;
%         end
%     end
% end


% NOTE: The channels are noisy, so wait for at least this many "all clears"
%   in a row. Last check showed a max of 3 when a button was pressed.
num_clears = 15;
k = 0;
while k < 12
    k = 0;
    for i = 1:num_clears
        if isempty(PTBCheckResponsePorts) 
            k = k+1;
        end
    end
end
