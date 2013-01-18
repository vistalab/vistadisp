function HumphreyPerimetry;
% Perimetry - perform Humprey's perimetry

% 09/2006 sod wrote it

% initialize params
gp = hp_params;

% show stimulus
tic;
gp = hp_presentation(gp);
disp(sprintf('[%s]:Subject (%s) is finished[%.1f min].',mfilename,gp.subject,toc./60)); 

% get field map
gp.response.field = gp.response.coordDetected./gp.response.coordShown;

gp.grid.z(gp.grid.shown)  = gp.response.field;

% view results
% flip y axis because 0,0 is top-left on the screen but bottom-left on axis
figure(1);clf;
middleY = gp.screenSize(2)./2;
[c,h]=contourf(gp.grid.x,(gp.grid.y-middleY).*-1+middleY,gp.grid.z,[0:.2:1]);%[0.0211 0.5 1]);
clabel(c,h);
colormap('gray');colorbar;
set(gca,'XTick',gp.dot.coordCenter(1),...
        'YTick',(gp.dot.coordCenter(2)-middleY).*-1+middleY,...
        'XTickLabel',[],'YTickLabel',[]);
grid on;
%axis([1 gp.screenSize(1) 1 gp.screenSize(2)]);
axis equal;
hold on;
plot(gp.dot.coord(1).coords(1,:),(gp.dot.coord(1).coords(2,:)-middleY).*-1+middleY,'o');                      
plot(gp.screenSize(1)./2+gp.display.fixationOffsetInPixelsX,...
     (gp.screenSize(2)./2+gp.display.fixationOffsetInPixelsY),'r*');
title(sprintf('Dot detected: Diameter = %.1fdeg; Dot distance = %.1fdeg;',gp.screenHeightDeg,gp.screenHeightDeg./sqrt(gp.dot.ndots)));
     
figure(2);clf;
gp.grid.z(gp.grid.shown)  = gp.response.coordShown;
[c,h]=contour(gp.grid.x,(gp.grid.y-middleY).*-1+middleY,gp.grid.z);
clabel(c,h),
middleY = gp.screenSize(2)./2;
colormap('gray');colorbar;
set(gca,'XTick',gp.dot.coordCenter(1),...
        'YTick',(gp.dot.coordCenter(2)-middleY).*-1+middleY,...
        'XTickLabel',[],'YTickLabel',[]);
grid on;
%axis([1 gp.screenSize(1) 1 gp.screenSize(2)]);
axis equal;
hold on;
plot(gp.dot.coord(1).coords(1,:),(gp.dot.coord(1).coords(2,:)-middleY).*-1+middleY,'o');                      
plot(gp.screenSize(1)./2+gp.display.fixationOffsetInPixelsX,...
     (gp.screenSize(2)./2+gp.display.fixationOffsetInPixelsY),'r*');
title(sprintf('Dot Shown: Diameter = %.1fdeg; Dot distance = %.1fdeg;',gp.screenHeightDeg,gp.screenHeightDeg./sqrt(gp.dot.ndots)));


% save
filename = ['~/Desktop/' mfilename '-' gp.subject '-' datestr(now,30) '.mat'];
save(filename);
disp(sprintf('[%s]:saved data in: %s',mfilename,filename));
