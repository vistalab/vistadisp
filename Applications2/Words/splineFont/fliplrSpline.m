function spline = fliplrSpline(spline)
% spline = fliplrSpline(spline)
%
% flips the spline about the y-axis.
%
% RFD

for i=1:length(spline)
   spline(i).x = 1-spline(i).x;
end
