%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetUseStartScreen.m
%
% Can disable the start screen, if you want.
%
% Args:
%	- value: 1 to use it, 0 to turn it off.
%
% Usage: PTBSetUseStartScreen(0)
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetUseStartScreen(value)

% Set
global PTBUseStartScreen;
PTBUseStartScreen = value;
