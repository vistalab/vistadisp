function spline = scaleSpline(spline, xMin, yMin, xMax, yMax, xOffset, yOffset)
% spline = scaleSpline(spline, xMin, yMin, xMax, yMax, [xOffset], [yOffset])
%
% scales the spline, optionally shifing its position.
% (basically just multiplies each dimention by the specified
% range and adds the min and, optionally, adds the offsets.)
%
% RFD

if(~exist('xOffset','var') | isempty(xOffset))
    xOffset = 0;
end
if(~exist('yOffset','var') | isempty(yOffset))
    yOffset = 0;
end

xScale = xMax-xMin;
yScale = yMax-yMin;

for ii=1:length(spline)
   spline(ii).x = spline(ii).x*xScale + xMin + xOffset;
   spline(ii).y = spline(ii).y*yScale + yMin + yOffset;
end

return;