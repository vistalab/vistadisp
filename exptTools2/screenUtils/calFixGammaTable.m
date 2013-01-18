function cal = calFixGammaTable(cal, calfile)
% function cal = calFixGammaTable(cal, [calfile])
%   
%   inputs:
%       cal:        a psychtoolbox calibration structure
%       calfile:    name of file to store the fixed calibration struct
%
%  purpose: 
%   check to see whetehr a PyschToolBox calibration file contains a series
%   of zeros at the beginning of hte gamma table for any of the three color
%   channels. If it does, then replace these values with linearly
%   interpolated values between 0 and the first non-zero value in the
%   table. 
%  
% 5.14.08: written by JW with help from RFD

for ii = 1:3
    z=cal.gammaTable(:,ii)==0;
    if length(find(z)) > 1
        z=find(~z);
        a = linspace(0,cal.gammaTable(z(1),ii),z(1));
        cal.gammaTable(1:length(a), ii) = a;
    end
end

if nargin == 2,
    SaveCalFile(cal, calfile)
end
return