function spline = perturbSpline(spline, curveStd, endStd, PflipUD, PflipLR)
% spline = perturbSpline(spline, curveStd, endStd, PflipUD, PflipLR)
%
% Perturbs the spline given the pertubation params.
%  curveStd = standard deviation of the curvature control points
%  endStd = standard deviation of the end-point position
%  PflipUD = probability of a flip about the x-axis
%  PflipLR = probability of a flip about the y-axis
%
% RFD

if rand>PflipLR
   spline = fliplrSpline(spline);
end
if rand>PflipUD
   spline = fliplrSpline(spline);
end

for i=1:length(spline)
   spline(i).x(2:end-1) = spline(i).x(2:end-1) + ...
      					randn(1,length(spline(i).x(2:end-1))).*curveStd;
   spline(i).y(2:end-1) = spline(i).y(2:end-1) + ...
      					randn(1,length(spline(i).y(2:end-1))).*curveStd;
   spline(i).x(1,end) = spline(i).x(1,end) + ...
      					randn(1,length(spline(i).x(1,end))).*endStd;
   spline(i).y(1,end) = spline(i).y(1,end) + ...
      					randn(1,length(spline(i).y(1,end))).*endStd;
end
