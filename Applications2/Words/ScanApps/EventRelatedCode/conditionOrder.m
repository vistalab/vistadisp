function [parfileorder, stimlistorder] = conditionOrder(subjNum)
%
% This is a look up table for parfile (which determines condition order and timing)
% and stimulus order (i.e. the particular stimuli assigned to each
% condition), based on subject number (subjNum).
%
% Written specifically for response sorting experiment, but could be used
% for anything.  Just a way of keeping things organized.
%
% There may be a better way to determine these orders.  Here, I have two
% different stimulus list orderings.  Each parfileorder goes forward and
% backward, so subjects come in sets of 4.  I'm not sure whether the
% particular stimuli within the stimulus lists should also be
% counterbalanced or randomized, but either way that's not handled by this
% function.
%

switch subjNum
    case 1
        parfileorder = 1:10;
        stimlistorder = 1:10;
    case 2
        parfileorder = 10:-1:1;
        stimlistorder = 1:10;
    case 3
        parfileorder = 1:10;
        stimlistorder = 10:-1:1;
    case 4
        parfileorder = 10:-1:1;
        stimlistorder = 10:-1:1;
    case 5
        parfileorder = [6 8 4 10 2 9 5 7 3 1];
        stimlistorder = 1:10;
    case 6
        parfileorder = fliplr([6 8 4 10 2 9 5 7 3 1]);
        stimlistorder = 1:10;
    case 7
        parfileorder = [6 8 4 10 2 9 5 7 3 1];
        stimlistorder = 10:1;
    case 8
        parfileorder = fliplr([6 8 4 10 2 9 5 7 3 1]);
        stimlistorder = 10:1;
    otherwise
        fprintf('\nNo orderings defined for this subject number.  Please add in conditionOrder.m.')
        parfileorder = [];
        stimlistorder = [];
end
        

return