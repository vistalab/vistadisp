function bmPoints = getSplinePts(imgFileName)

r = 200; c = 200;
cmap = [1 1 1; 0 0 0];
thick = 5;
colors = 'rmbcgy';

letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ\/';
for(ii=27:length(letters))
    img = renderText(letters(ii), 'Courier', 24, 8);
    good = false;
    while(~good)
        figure(99); clf(99); imagesc(img); colormap gray; axis image; truesize
        disp('left-click to select points for a spline');
        disp('Hit return when finished with a spline');
        disp('Hit return twice when finished with this letter.');
        
        spNum = 0;
        done = 0;
        allPts = [];
        pts = [];
        while ~done
            [x,y] = ginput;
            if ~isempty(x)
                spNum = spNum+1;
                hold on; plot(x,y,['.' colors(spNum)]); hold off;
                pts(spNum).x = x(:)';
                pts(spNum).y = y(:)';
                allPts = [allPts; [x(:), y(:)]];
            else
                done = 1;
            end
        end
        % rescale so that all points lie within 0-1
        % (preserving apect ratio)
        m = [min(allPts),max(allPts)]; % [min X, min Y, max X, max Y]
        scale = max(m(3:4))-min(m(1:2));
        %scale = m(3:4)-m(1:2);
        for jj = 1:length(pts)
            pts(jj).x = (pts(jj).x - m(1)) ./ scale;
            % remap y so that it goes from top to bottom
            pts(jj).y = 1 - ((pts(jj).y - m(2)) ./ scale);
        end
        sp = fitSplines(pts);
        spIm = renderSpline(scaleSpline(sp, 0, 0, c, r), r, c, thick);
        figure(98); clf(98); image(spIm+1); colormap(cmap); truesize; axis off;
        
        figure(97); clf(97);
        hold on; 
        for (jj=1:length(pts))
            [xx,yy] = bSpline(sp(jj).x, sp(jj).y, 10);
            plot(xx, yy, ['-' colors(jj)]);
            plot(pts(jj).x, pts(jj).y, ['o' colors(jj)]);
        end
        hold off;
        axis equal;
        
        resp = questdlg('Is this good?', 'Spline OK', 'Yes', 'No', 'Yes');
        if(strcmpi(resp,'yes'))
            good = true;
        end
    end
    
    myFont(ii).char = letters(ii);
    myFont(ii).spline = sp;
    myFont(ii).rawPts = pts;
end

uisave('myFont');


