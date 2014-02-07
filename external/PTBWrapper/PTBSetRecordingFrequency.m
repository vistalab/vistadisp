%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetRecordingFrequency.m
%
% Set the frequency to record sound trigger data at.
%
% Args: 
%   - Frequency: The frequency to record at
%
% Usage: PTBSetRecordingFrequency(44100)
%
% Author: Doug Bemis
% Date: 4/13/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetRecordingFrequency(freq)

global PTBRecordingFrequency;
PTBRecordingFrequency = freq;
