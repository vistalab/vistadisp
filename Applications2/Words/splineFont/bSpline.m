function [xx,yy] = bSpline(x, y, n)
% [xx,yy] = bSpline(x, y, n)
%
% Finds n points along xx,yy given the b-spline
% defined by the control points in (x,y).
%
% [x(1),y(1)] & [x(end),y(end)] are the two on-curve
% end points- the rest are the off-curve control point(s).
%
% The final curve is rendered as a set of Bezier curves
% defined by 3 point (two on-curve end points and one
% off-curve control point).  
% If the 3 points of each Bézier curve are 
% (Ax, Ay), (Bx, By) and (Cx, Cy), then
%    xx = (1-t)^2.Ax + 2t(1-t).Bx + t^2.Cx
%    yy = (1-t)^2.Ay + 2t(1-t).By + t^2.Cy
% Varying t from 0 to 1 produces all the points on the curve.
% 
% If there is more than 1 off-curve control point specified,
% then intermediate on-curve control points are assumed to be
% at the midpoint connecting consecutive off-curve points.
%
% 99.05.21 RFD bobd@stanford.edu

if length(x) ~= length(y)
   error('x and y must be equal length vectors!');
end
if length(x) < 3
   error('need at least 3 points in x and y!');
end

if length(x) == 3
   % special case- a one Bezier segment contour
   t = linspace(0,1,n);
   xx = (1-t).^2.*x(1) + 2.*t.*(1-t).*x(2) + t.^2.*x(3);
   yy = (1-t).^2.*y(1) + 2.*t.*(1-t).*y(2) + t.^2.*y(3);
else
   nSegments = length(x) - 2;
   segn = ceil(n/nSegments);
   t = linspace(0,1,segn);
   xx = [];
   yy = [];
   for ii=2:length(x)-1
      if ii==2
      	segx1 = x(ii-1);
      	segy1 = y(ii-1);
         segx3 = (x(ii)+x(ii+1))/2;
         segy3 = (y(ii)+y(ii+1))/2;
      elseif ii==length(x)-1
      	segx1 = (x(ii)+x(ii-1))/2;
      	segy1 = (y(ii)+y(ii-1))/2;
         segx3 = x(ii+1);
         segy3 = y(ii+1);
      else
      	segx1 = (x(ii)+x(ii-1))/2;
      	segy1 = (y(ii)+y(ii-1))/2;
         segx3 = (x(ii)+x(ii+1))/2;
         segy3 = (y(ii)+y(ii+1))/2;
      end   
      xx = [xx (1-t).^2.*segx1 + 2.*t.*(1-t).*x(ii) + t.^2.*segx3];
   	yy = [yy (1-t).^2.*segy1 + 2.*t.*(1-t).*y(ii) + t.^2.*segy3];
   end  
end

% ensure that there are no points connected only by their corners
%ii = find(diff(xx)&diff(yy));

return;

