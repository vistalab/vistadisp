function curve_out = test_spline(points_in)

npoints = length(points_in);

%spline the rough face
n1 = 1;
n2 = npoints;
t = [n1:1:n2];
resolution = 100;


ppx = spline(t,points_in(:,1));
ppy = spline(t,[0 points_in(:,2)' 0]'); %ensures slope = 0 at bottom
xx = ppval(ppx, linspace(n1,n2,(n2-n1)*resolution+1));
yy = ppval(ppy, linspace(n1,n2,(n2-n1)*resolution+1));

curve_out = [xx', yy'];
