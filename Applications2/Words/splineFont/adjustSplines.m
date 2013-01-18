r = 50;
c = 50;
thick = 3;
cmap = [1 1 1; 0 0 0];
colors = 'rmbcgy';
for(ii=27:length(myFont))
    sp = myFont(ii).spline;
    disp(['Working on "' myFont.char '"']);
    
    spIm = renderSpline(scaleSpline(sp, c*.1, r*.1, c*.9, r*.9), r, c, thick);
    figure(98); clf(98); image(spIm+1); colormap(cmap); truesize; axis off;
    figure(97); clf(97); hold on; grid on;
    set(97,'CurrentCharacter','g');
    allSp = [];
    for (jj=1:length(sp))
        [xx,yy] = bSpline(sp(jj).x, sp(jj).y, 30);
        plot(xx, yy, ['-' colors(jj)]);
        plot(sp(jj).x, sp(jj).y, ['o' colors(jj)]);
        allSp = [allSp, [sp(jj).x; sp(jj).y; repmat(jj,1,length(sp(jj).x)); [1:length(sp(jj).x)]]];
    end
    hold off; axis equal;
    
    curChar = '';
    while(isempty(curChar) | (curChar~='q' & curChar~='x'))        
        waitforbuttonpress;
        curChar = get(97,'CurrentCharacter');
        clickPt = get(gca,'CurrentPoint');
        clickPt = clickPt(1,1:2); % extract x,y
        d = (clickPt(1)-allSp(1,:)).^2 + (clickPt(2)-allSp(2,:)).^2;
        if(curChar~='q' & curChar~='x' & min(d)<.01)
            newPt = ginput(1);
            if(~isempty(newPt))
                nearest = find(d==min(d));
                nearest = nearest(1);
                sp(allSp(3,nearest)).x(allSp(4,nearest)) = newPt(1);
                sp(allSp(3,nearest)).y(allSp(4,nearest)) = newPt(2);
            end
        end
        if(curChar=='r')
            sp = myFont(ii).spline;
            set(97,'CurrentCharacter','g');
        end
        spIm = renderSpline(scaleSpline(sp, c*.1, r*.1, c*.9, r*.9), r, c, thick);
        figure(98); clf(98); image(spIm+1); colormap(cmap); truesize; axis off;
        figure(97); clf(97); hold on; grid on;
        allSp = [];
        for (jj=1:length(sp))
            [xx,yy] = bSpline(sp(jj).x, sp(jj).y, 30);
            plot(xx, yy, ['-' colors(jj)]);
            plot(sp(jj).x, sp(jj).y, ['o' colors(jj)]);
            allSp = [allSp, [sp(jj).x; sp(jj).y; repmat(jj,1,length(sp(jj).x)); [1:length(sp(jj).x)]]];
        end
        hold off; axis equal;
    end
    disp('Finished.');
    if(curChar~='x')
        myFont(ii).spline = sp;
        disp('Changes applied.');
    else
        disp('All changes cancelled.');
    end
end
uisave('myFont');
