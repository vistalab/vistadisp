%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetExitKey.m
%
% Sets the exit key. Hitting this key for any response
% will exit the program.
%
% Args:
%	- value: The key to set.
%       * Keys can be simple letters ('e') or numbers ('1'), or
%           some special keys (like 'ESCAPE')
%
% Usage: PTBSetExitKey('ESCAPE')
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetExitKey(value)

% Set
global PTBExitKey;
PTBExitKey = value;
