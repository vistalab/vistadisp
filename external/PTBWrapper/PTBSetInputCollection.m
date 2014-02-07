%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetInputCollection.m
%
% Sets the input collection method
%
% Args:
%	- value: The type of collection to use.
%		* Queue: The most effective way to collect, however, only works in Macs
%			and has some bugs (i.e. crashes, doesn't work over multiple screens, etc.)
%		* Check: The next best way. Should be ok usually, but doesn't seem to be
%			able to collect from the MEG reliably.
%		* Char: The worst method timing-wise, but reliably gets the input
%			from the MEG...
%
% Usage: PTBSetInputCollection('Queue')
%
% Author: Doug Bemis
% Date: 3/2/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetInputCollection(value)

% Set
global PTBInputCollection;

% Check
if ~strcmp(value, 'Queue') && ~strcmp('Check', value) && ...
        ~strcmp('Char', value) 
	error(['Unknown collection method: ' value '.']);
end

% And set
PTBInputCollection = value;
