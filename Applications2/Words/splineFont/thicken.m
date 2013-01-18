function xy = thicken(xy, thick)
% xy = thicken(xy, thick)
%
% Thickens the figure specified by the points in xy
% by adding points.  xy must be of the form:
% [x1,y1; x2,y2; ... xn,yn]
%
% RFD

if thick==1
   return;
end
oldXY = xy;
for i=1:ceil(thick/2)
   xy = [xy; oldXY(:,1)+i, oldXY(:,2)+i];
end
for i=1:floor(thick/2)
   xy = [xy; oldXY(:,1)-i, oldXY(:,2)-i];
end
