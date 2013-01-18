function [XYZ energy wave] = xyzFromDisp(disp, rgb)
% [XYZ energy wave] = xyzFromDisp(disp, rgb)
%
% Input 
%   disp: either a vistadisp display structure or a the name of a vistadisp
%          display path
%   rgb: a 3x1 vector of display RGB values in [0 1] (default = [1 1 1]')
% Output
%   XYZ values of the display when RGB are all set to max
%
% Example 1: Get the max xyz vales from the CNI display
%   xyz = xyzFromDisp('CNI_LCD_2011_03_13')
%
% Example 2: Get the max xyz values from the display of your choice
%   disp = selectDisplay;
%   xyz = xyzFromDisp(disp);
%
% Example 3: Get the xyz values for a particular rgb value
%   disp = 'CNI_LCD_2011_03_13';
%   rgb  = [1 1 0]; % (yellowish)
%   xyz = xyzFromDisp(disp, rgb);
%
% Note: RGB values are NOT gamma corrected.

% if no rgb value, assume monitor max 
if notDefined('rgb'), rgb = [1 1 1]; end

% if no display is input, try to give users a list
if notDefined('disp'), disp = selectDisplay; end

% check that our rgb vector is 1x3 and not 3x1
if size(rgb) == [3 1], rgb = rgb'; end

if ischar(disp)
    disp = loadDisplayParams(disp);
end


wave   = disp.wavelengths';     % should be 1 x num wavelengths
energy = rgb * disp.spectra';    % should be 1 x num wavelengths

XYZ = ieXYZFromEnergy(energy,wave);

return
