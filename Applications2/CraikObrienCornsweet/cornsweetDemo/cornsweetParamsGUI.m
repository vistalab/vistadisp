function [params, stim, ok] = cornsweetParamsGUI(params)

f = 1;
figure(f); 
set(f, 'Color', 'k')

if ~exist('generalDialog.m', 'file'), addpath('mrVistaUtilities'); end
    
dlg(1).fieldName     = 'screenWidth';
dlg(end).style       = 'number';
dlg(end).string      = 'Image Width (pixels)';
dlg(end).value       = 600;
if ~isempty(params), dlg(end).value = params.screenWidth; end

dlg(end+1).fieldName = 'imageWidthInDegrees';
dlg(end).style       = 'number';
dlg(end).string      = 'Image Width (degrees)';
dlg(end).value       = 30;
if ~isempty(params), dlg(end).value = params.imageWidthInDegrees; end

dlg(end+1).fieldName = 'amplitude';
dlg(end).style       = 'number';
dlg(end).string      = 'Edge Amplidue [0 1]';
dlg(end).value       = 0.2;
if ~isempty(params), dlg(end).value = params.amplitude * 2; end

dlg(end+1).fieldName = 'realToCornAmpRatio';
dlg(end).style       = 'number';
dlg(end).string      = 'c-o-c / square wave ratio [0 2]';
dlg(end).value       = 2;
if ~isempty(params), dlg(end).value = params.realToCornAmpRatio; end

dlg(end+1).fieldName = 'framesPerCycle';
dlg(end).style       = 'number';
dlg(end).string      = 'frames per cycle';
dlg(end).value       = 10;
if ~isempty(params), dlg(end).value = params.framesPerCycle; end

dlg(end+1).fieldName = 'cyclesPerSecond';
dlg(end).style       = 'number';
dlg(end).string      = 'cycles per second';
dlg(end).value       = .5;
if ~isempty(params), dlg(end).value = params.cyclesPerSecond; end

dlg(end+1).fieldName = 'numRepetitions';
dlg(end).style       = 'number';
dlg(end).string      = 'number of cycles';
dlg(end).value       = 1;
if ~isempty(params), dlg(end).value = params.numRepetitions; end

dlg(end+1).fieldName = 'curvatureAmp';
dlg(end).style       = 'number';
dlg(end).string      = 'curvature';
dlg(end).value       = 1/6;
if ~isempty(params), dlg(end).value = params.curvatureAmp; end

dlg(end+1).style     = 'checkbox';
dlg(end).string      = 'Keep GUI open?';
dlg(end).value       = 1;
dlg(end).fieldName   = 'loop';
if ~isempty(params), dlg(end).value = params.loop; end

dlg(end+1).style     = 'checkbox';
dlg(end).string      = 'Plot luminance profile?';
dlg(end).value       = 1;
dlg(end).fieldName   = 'plotLuminanceProfile';
if ~isempty(params), dlg(end).value = params.plotLuminanceProfile; end

dlg(end+1).style     = 'checkbox';
dlg(end).string      = 'Show square wave?';
dlg(end).value       = 1;
dlg(end).fieldName   = 'showSquareWave';
if ~isempty(params), dlg(end).value = params.showSquareWave; end

dlg(end+1).style     = 'checkbox';
dlg(end).string      = 'Show C-O-C edge?';
dlg(end).value       = 1;
dlg(end).fieldName   = 'showCOC';
if ~isempty(params), dlg(end).value = params.showCOC; end

dlg(end+1).style     = 'checkbox';
dlg(end).string      = 'Show mixture?';
dlg(end).value       = 1;
dlg(end).fieldName   = 'showMixture';
if ~isempty(params), dlg(end).value = params.showMixture; end

dlg(end+1).style     = 'checkbox';
dlg(end).string      = 'Luminance modulation?';
dlg(end).value       = 1;
dlg(end).fieldName   = 'modLuminance';
if ~isempty(params), dlg(end).value = params.modLuminance; end

dlg(end+1).style     = 'checkbox';
dlg(end).string      = 'Rotaton?';
dlg(end).value       = 0;
dlg(end).fieldName   = 'modRotation';
if ~isempty(params), dlg(end).value = params.modRotation; end

dlg(end+1).style     = 'checkbox';
dlg(end).string      = 'add noise?';
dlg(end).value       = 0;
dlg(end).fieldName   = 'addNoise';
if ~isempty(params), dlg(end).value = params.addNoise; end



if ~isempty(params), figPos = params.figPos; else figPos = 'center'; end

[params ok figPos] = generalDialog(dlg, mfilename, figPos);


if ~ok, params = []; stim = []; return; end

% Derived
params.framePerSecond = params.framesPerCycle * params.cyclesPerSecond;
params.nRows          = 1 + params.plotLuminanceProfile;
params.nCols          = params.showSquareWave + params.showCOC + params.showMixture;
params.screenHeight   = params.screenWidth / 2;
params.amplitude      = params.amplitude /2;
x                     = linspace(-params.imageWidthInDegrees/2, params.imageWidthInDegrees/2, params.screenWidth);
stim.edge             = (x < 0) * 2 - 1;
params.figPos         = figPos;

set(1, 'UserData', params);
% fixationLoc          = -20; %negative numbers for left of edge, pos for right side of edge
% fixationDutyCycle    = 1;

end