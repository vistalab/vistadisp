%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSaveSoundKeyData.m
%
% Save any sound key data that was recorded during the experiment.
%
% Args:
%
% Usage: PTBSaveSoundKeyData
%
% Author: Doug Bemis
% Date: 4/23/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Possibly allow changing during the experiment.
function PTBSaveSoundKeyData

global PTBSoundKeyData;
global PTBRecordAudio;
global PTBRecordAudioFileNames
global PTBRecordingFrequency;
global PTBSoundNameFirst;

% If we have none, get out of here
if isempty(PTBSoundKeyData)
	return;
end

% We're done recording...
if isempty(PTBRecordAudioFileNames)
    sound_file_name = 'No_Name';
else
    sound_file_name = PTBRecordAudioFileNames{1};
    PTBRecordAudioFileNames = {PTBRecordAudioFileNames{2:end}}; %#ok<CCAT1>
end
PTBRecordAudio = PTBRecordAudio(2:end,:);

% Otherwise, write it to the file.
% Name it by date to avoid overwriting
if PTBSoundNameFirst
    file_name = sound_file_name;
else
    file_name = '';
end

% Now the clock
t = fix(clock);
for i = 1:6
    file_name = [file_name '_' num2str(t(i))]; %#ok<AGROW>
end

% And the end
if PTBSoundNameFirst
    file_name = [file_name '.wav'];
else
    file_name = [file_name '_' sound_file_name '.wav'];
end
wavwrite(transpose(PTBSoundKeyData), PTBRecordingFrequency, 16, file_name);

% Clear the buffer
PTBSoundKeyData = [];

