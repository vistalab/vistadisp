function [motCoh, lumCoh] = cCompute(pValue, pAngle)
% Polar Computations
%
% Inputs:
% pVect = percent distance along line
% pAngle = polar angle in degrees of line to be tested (0 to 90)
%
% Outputs:
% motCoh = motion coherence
% lumCoh = luminance coherence
%
% RFB 12/09/08

if notDefined('pValue'), pValue = [.5]; end
if notDefined('pAngle'), pAngle = 45; end

if pAngle>45, flag=1; pAngle=90-pAngle; else flag=0; end
pAngle = (pAngle/90)*(pi/2);

r = 1/cos(pAngle);

rValue = pValue*r;

if flag==0
    motCoh = rValue*cos(pAngle);
    lumCoh = rValue*sin(pAngle);
elseif flag==1
    motCoh = rValue*sin(pAngle);
    lumCoh = rValue*cos(pAngle);
end

    
