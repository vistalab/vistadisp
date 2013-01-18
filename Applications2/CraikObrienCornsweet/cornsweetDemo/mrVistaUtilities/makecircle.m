function [matrix] = makecircle(Diameter,Size,edgewidth)
% MAKECIRCLE - make a circle with hard or soft edgesin a matrix of minimum size
% [matrix]=MakeCircle(Diameter,Size,edgewidth);
% Sizes are in pixels, edgewith > 1 = with of raised cosine function

if nargin < 1,
	help(mfilename);
	return;
end;
if nargin < 2,
	Size=round(Diameter);
end;
if nargin < 3,
	edgewidth = 0;
end;

% check
if Diameter+edgewidth>Size,
	fprintf('Diameter + edgewidth are larger than Size\n');
end;


% Make matrix coordinate system with 0 in center:
coords=-Size/2+.5:Size/2-.5;
[xx,yy]=meshgrid(coords);
dist_from_center = sqrt((xx.*xx)+(yy.*yy));clear xx yy;
fix_circ_calc = dist_from_center <= Diameter/2;
if edgewidth,
   edge_calc     = find(dist_from_center >  Diameter/2 & ...
                        dist_from_center <= Diameter/2 + edgewidth);
end;

%Make actual matrix
image_matrix=zeros(Size,Size);
image_matrix(fix_circ_calc)=1;
if edgewidth,
	dist_from_center = cos((dist_from_center-Diameter/2)./(edgewidth).*pi)./2+.5;
	image_matrix(edge_calc)=dist_from_center(edge_calc);
end;

matrix=image_matrix;
%ImageShow(matrix);
