function sp = fitSplines(pts)
%
% sp = fitSplines(somePts)
%
%

% We fit one spline to each set of points.
%
% The spline is defined by two end points plus at least one control point. 
%
for(ii=1:length(pts))
    if(length(pts(ii).x)==2)
        % Easy one- fit a straight line
        sp(ii).x(1) = pts(ii).x(1);
        sp(ii).y(1) = pts(ii).y(1);
        sp(ii).x(2) = mean(pts(ii).x);
        sp(ii).y(2) = mean(pts(ii).y);        
        sp(ii).x(3) = pts(ii).x(2);
        sp(ii).y(3) = pts(ii).y(2);
    else
        % we actually need to search for a solution.
        if(length(pts(ii).x)==3)
            % initialize spline to the points. The spline will have one
            % control point.
            sp(ii) = pts(ii);
        else
            % initialize the spline to have length(pts)-3 control points.
            sp(ii).x(1) = pts(ii).x(1);
            sp(ii).y(1) = pts(ii).y(1);
            for(jj=2:length(pts(ii).x)-2)
                sp(ii).x(jj) = (pts(ii).x(jj) + pts(ii).x(jj+1))./2;
                sp(ii).y(jj) = (pts(ii).y(jj) + pts(ii).y(jj+1))./2;
            end
            sp(ii).x(end+1) = pts(ii).x(end);
            sp(ii).y(end+1) = pts(ii).y(end);
        end
        clear cp ep;
        cp(1,:) = sp(ii).x([2:end-1]);
        cp(2,:) = sp(ii).y([2:end-1]);
        ep(1,:) = sp(ii).x([1,end]);
        ep(2,:) = sp(ii).y([1,end]);       
        [cp,err] = fminsearch('splineErr', cp, [], ep, pts(ii));
        sp(ii).x([2:end-1]) = cp(1,:);
        sp(ii).y([2:end-1]) = cp(2,:);
    end
end
return;

