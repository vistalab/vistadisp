%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetRecordingChanels.m
%
% Set the channels to record sound trigger data at.
%
% Args: 
%   - Channels: The channels to record at
%
% Usage: PTBSetRecordingChannels(2)
%
% Author: Doug Bemis
% Date: 7/2/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetRecordingChannels(channels)

global PTBRecordingChannels;
PTBRecordingChannels = channels;
