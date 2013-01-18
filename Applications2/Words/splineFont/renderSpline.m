function bitmap = renderSpline(spline, rows, cols, thick)
% bitmap = renderSpline(spline, rows, cols, [thick])
%
% renders the figure specified by the spline structure
% in an n x m box.  (background is 0 and foreground is 1)
%
% RFD

if ~exist('thick', 'var')
    thick = [];
end
if isempty(thick)
    thick = 1;
end

bitmap = zeros(rows, cols);

for i=1:length(spline)
    % *** HACK: there's probably an elegant way to figure 
    % out how many samples we need (n).  That would make the 
    % following code much more effiecient.
    n = round(rows*cols*2);
    [xx,yy] = bSpline(spline(i).x, spline(i).y, n);
    xy = unique([round(xx)' round(yy)'], 'rows');
    
    %xy = thicken(xy, thick);
    % constrain to bitmap boundaries
    index = find(xy(:,1)>0&xy(:,2)>0&xy(:,1)<=cols&xy(:,2)<=rows);
    if(~isempty(index))
        bitmap(sub2ind(size(bitmap),xy(index,2),xy(index,1))) = 1;
    end
end
bitmap = imdilate( bitmap, strel('disk', thick, 0));
% put the origin at lower-left
bitmap = flipud(bitmap);
