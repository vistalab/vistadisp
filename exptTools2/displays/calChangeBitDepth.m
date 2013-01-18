function cal = calChangeBitDepth(calfile, bitDepth)
% Change the bit depth of a PsychToolBox calibration file.
%
%   cal = calChangeBitDepth([calfile], [bitDepth])
%
% INPUTS
%   calfile: file name of Psychtoolbox calibration file (not including path
%               or extension) [default = use GUI]
%   bitDepth: bit depth for new calibration [default = 8]
%
% OUTPUT
%   cal: PsychToolBox calibration structure with new bit depth
% 
% Example 1
%   calfile = '3T1_LCD_2010_10_19';             % name it
%   cal08  = calChangeBitDepth(calfile, 8);     % change it
%   SaveCalFile(cal08, [calfile '_8bits'])      % save it
%
% Example 2, including comparison plot
%   calfile = '3T1_LCD_2010_10_19';
%   cal08  = calChangeBitDepth(calfile, 8);
%   cal10  = LoadCalFile(calfile);
%   figure; plot(linspace(0,1,256), cal08.gammaTable, '-')
%   hold on; plot(linspace(0,1,1024), cal10.gammaTable, 'x') 
%   legend({'r-8' 'g-8' 'b-8' 'r-10' 'g-10' 'b-10'}, 'Location', 'NorthWest')
%   

% JW, 4.20.2011

% check inputs; if no input, ask user to select cal file with GUI
if notDefined('calfile'),  calfile  = selectDisplay; end

if notDefined('bitDepth'), bitDepth = 8;             end

% load the calibration file 
cal = LoadCalFile(calfile);

% change bit depth
cal.describe.dacsize = bitDepth;

% recalculate gamma table
cal = CalibrateFitGamma(cal, 2^cal.describe.dacsize);

return

%% Debug
calfile = '3T1_LCD_2010_10_19';

cal10  = LoadCalFile(calfile);
cal08  = calChangeBitDepth(calfile, 8);

figure; plot(linspace(0,1,256), cal08.gammaTable, '-')
hold on; plot(linspace(0,1,1024), cal10.gammaTable, 'x')

legend({'r-8' 'g-8' 'b-8' 'r-10' 'g-10' 'b-10'}, 'Location', 'NorthWest')

