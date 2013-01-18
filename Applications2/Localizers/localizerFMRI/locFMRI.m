function P = locFMRI(varargin)
%% Run a block-design localizer for fMRI
%
%   P = locFMRI(varargin)
%
% This code presents stimuli and collects subject responses for fMRI
% localizer experiments using a block design. The assumption is that the
% the experiment will consist of periods of fixation interleaved with
% blocks of images. It is assumed that for each block, stimuli belong to a
% single class (i.e., come from a single directory). Any number of classes
% can be presented in any arbitrary order. The blocks and fixation periods
% can have varying or identical lengths. 
%
% INPUT (varargin)
%   Inputs come in parameter pairs ('ParameterName', value). 
%   
%   For a list and description of parameters that can be set by the user,
%   see comments and help for locSetParams.m
%
% OUTPUT (P)
%   P is a struct with fields pertaining to the stimulus, display,
%   responses, and so forth. The fields of P are also written out as a
%   matlab file (path is P.logfile). A subset of the fields are written out
%   as a text file (P.parfile). The text file contains three columns: onset
%   time, class number, class name. The par file can be read without
%   modification by vistasoft GLM code.
%
% Example:
%         params{1} = 'Blank Color';
%         params{2} = 128; 
% 
%         params{3} = 'Subj Initials';
%         params{4} = 'xx';
% 
%         params{5} = 'display';
%         params{6} = 'cni_lcd';
% 
%         params{7} = 'Circular Aperture';
%         params{8} = true;
% 
%         params{9} = 'Block Order';
%         params{10} = [1 2 2 1];
% 
%         params{11} = 'Block Length';
%         params{12} = 6;
% 
%         params{13} = 'Fix Length';
%         params{14} = 6;
% 
%         params{15} = 'Condition Names';
%         params{16} = {'faces', 'houses'};
%
%         params{17} = 'Condition Dirs';
%         params{18} = {'faces', 'houses'};
%
%         params{19} = 'Root Directory';
%         params{20} = fullfile(vistastimRootPath, 'localizers','facesHouses400');
%
%         locFMRI(params{:})
%
% Adapted from the function, doWordLocalizer, which runs a visual word form
% ("VWFA") localizer. 
% 
% written: JW 2011-07-19
%
%
% TODO: save parfile BEFORE experiment and save subject data on every trial

% define experiment-specific parameters
P = locSetParams(varargin{:});

% set up display
P = locSetDisplay(P);

% write out a par file (time and condition number and names)
P = locMakeParFile(P);

% assign stimuli (file names of images) to blocks
P = locAssignImages(P);

% load and show experiment blocks
P = locShowBlocks(P);

% get fixation performance for all blocks
P = locFixationPerformance(P);

% save variables to a file for experimental info and write out parfile
P = locSaveData(P);

% Reset priority and screen
Screen('Close'); Screen('CloseAll'); Priority(0); ShowCursor;

return

