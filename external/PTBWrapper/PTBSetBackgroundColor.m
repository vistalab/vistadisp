%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetBackgroundColor.m
%
% Sets the background screen color.
%
% Args:
%	- value: The color as an RGB triple
%       (e.g. [255 0 0] - is all red).
%
% Usage: PTBSetBackgroundColor([127 127 127])
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetBackgroundColor(value)

% Set
global PTBBackgroundColor;
PTBBackgroundColor = value;
