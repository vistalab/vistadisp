function err = splineErr(splineControlPts, splineEndPts, pts)
%
% err = splineErr(splineControlPts, splineEndPts, pts)
%
% Computes the sum-of-squared distances between the points in pts and the
% b-spline specificed by the splineControlPts and splineEndPts. 
% 

sp.x = [splineEndPts(1,1) splineControlPts(1,:) splineEndPts(1,2)];
sp.y = [splineEndPts(2,1) splineControlPts(2,:) splineEndPts(2,2)];
[xx,yy] = bSpline(sp.x, sp.y, (length(sp.x)-2)*20);
err = 0;
for(jj=2:length(pts.x)-1)
    d = (pts.x(jj)-xx).^2 + (pts.y(jj)-yy).^2;
    err = err + min(d);
end
return;
