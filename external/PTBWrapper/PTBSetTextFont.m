%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetTextFont.m
%
% Sets the text font.
%
% Args:
%	- value: The font to use.
%
% Usage: PTBSetText('Courier')
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetTextFont(value)

% Set
global PTBTextFont;
PTBTextFont = value;
