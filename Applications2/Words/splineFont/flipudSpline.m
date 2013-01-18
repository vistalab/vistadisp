function spline = fliplrSpline(spline)
% spline = fliplrSpline(spline)
%
% flips the spline about the x-axis.
%
% RFD

for i=1:length(spline)
   spline(i).y = 1-spline(i).y;
end
