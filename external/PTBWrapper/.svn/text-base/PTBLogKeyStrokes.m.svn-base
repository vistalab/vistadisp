%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBLogKeyStrokes.m
%
% Log all keystrokes in the buffer. 
%
% Args:
%
% Usage: PTBLogKeyStrokes.
%
% Author: Doug Bemis
% Date: 7/7/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBLogKeyStrokes

% Need these
global PTBStartTime;
global PTBKeyFileName;

% Open up the file
if isempty(PTBKeyFileName)
	fid = 1;
else
	fid = fopen(PTBKeyFileName,'a');
end

% Header
fprintf(fid,'\n\n--------------------------------------------------\n\n');
fprintf(fid,['Keystrokes for experiment starting at : ' num2str(PTBStartTime) ' (' datestr(PTBStartTime) ')\n\n']);

% And log
while CharAvail
 	[ch w] = GetChar;
	fprintf(fid,[ch '\t' num2str(w.address) '\t' num2str(w.mouseButton) '\t' num2str(w.alphaLock) '\t' ...
		num2str(w.commandKey) '\t' num2str(w.controlKey) '\t' num2str(w.optionKey) '\t' num2str(w.shiftKey) '\t' ...
		num2str(w.ticks) '\t' num2str(w.secs) '\t' num2str(w.secs - PTBStartTime) '\n']);
end

% And done
if fid ~= 1
	fclose(fid);
end
