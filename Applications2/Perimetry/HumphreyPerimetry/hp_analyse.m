function fitparams = hp_analyse(hp);
% hp_analyse - analyse (fit) Humphrey Perimetry with a cosine-sunk elipsoid. 
% Sequential fitting of the 6 parameters.
%
% fitparams = hp_analyse(hp);
% 
% 10/2006 sod: wrote it.

% key press error
kperror = 0.05; 

%--- convert coordinate system to visual space
coords.x = (hp.grid.x-hp.dot.coordCenter(1))...
    ./(min(hp.screenSize)./2).*(hp.screenHeightDeg./2);
coords.y = (hp.grid.y-hp.dot.coordCenter(2))...
    ./(min(hp.screenSize)./2).*(hp.screenHeightDeg./2);
coords.z = hp.grid.z;
coords.z(isnan(coords.z))=1;
coords.dotsx = (hp.dot.coord(1).coords(1,:)-hp.dot.coordCenter(1))...
    ./(min(hp.screenSize)./2).*(hp.screenHeightDeg./2);
coords.dotsy = (hp.dot.coord(1).coords(2,:)-hp.dot.coordCenter(2))...
    ./(min(hp.screenSize)./2).*(hp.screenHeightDeg./2);

%--- original plot
doplot(coords,1);

%--- upsample data
upsamplefactor = 0.25;
xx = [floor(min(coords.x(:))):upsamplefactor:ceil(max(coords.x(:)))];
yy = [floor(min(coords.y(:))):upsamplefactor:ceil(max(coords.y(:)))];
coords_org = coords;
[coords.x coords.y]=meshgrid(xx,yy);
coords.z = interp2(coords_org.x,coords_org.y,coords_org.z,coords.x,coords.y,'*cubic');
% correct for keypress error
coords.z = coords.z.*(1+2.*kperror)-kperror;
coords.z(coords.z<0) = 0;
coords.z(coords.z>1) = 1;



%--- upsample plot
doplot(coords,2);

%--- default scotoma parameters
% center on mininum
[v mindata] = min(hp.response.field);
fitparams([1 2]) =  (hp.dot.coord(1).coords(:,mindata(1))' - ...
                     hp.dot.coordCenter) ...
    ./(min(hp.screenSize)./2).*(hp.screenHeightDeg./2);
fitparams(3)     = sqrt((sum(coords.z(:)<0.5).*upsamplefactor)./pi).*2;

%--- default search options
searchOptions.MaxIter = 99999;
searchOptions.TolFun  = 1e-10;
searchOptions.TolX    = 1e-10;
searchOptions.MaxIter = 99999;
searchOptions.MaxFunEvalsIter = 99999;
searchOptions.Display = 'none';

%--- circle fit
tmpcoords = coords;
fitparams
fitparams([1:3]) = fminsearch(@(x) makescotoma_step1(x,coords),fitparams([1:3]),searchOptions);
[e tmpcoords.z] = makescotoma_step1(fitparams,coords);
fitparams
doplot(tmpcoords,3);


%--- brute force elipse fit
e = Inf;keep=[];
for jitterx = [-2:.5:2],
  for jittery = [-2:.5:2],
    jit = [jitterx jittery];
    for ratio = 0.2:0.1:1,
      for orientation = 1:10:360,
        tmpparams = [fitparams([1:2])+jit fitparams(3).*[1./ratio ratio] orientation];
        [tmpe tmpcoords.z] = makescotoma_step2(tmpparams,coords);
        if tmpe < e,
          keep = [jit ratio orientation];
          e = tmpe;
        end;
      end;
    end;
  end;
end;
fitparams = [fitparams([1:2])+keep([1:2]) fitparams(3).*[1./keep(3) keep(3)] keep(4)];
[e tmpcoords.z] = makescotoma_step2(fitparams,coords);
fitparams
doplot(tmpcoords,4);

%--- smooth elipse fit
e = Inf;keep=[];
for scale = 0.1:0.1:3,
  for edge = 0:0.1:5,
    tmpparams = [fitparams([1:2]) fitparams([3 4]).*scale fitparams(5) edge];
    [tmpe tmpcoords.z] = makescotoma_step3(tmpparams,coords);
    if tmpe < e,
      keep = [scale edge];
      e = tmpe;
    end;
  end;
end;
fitparams = [fitparams([1:2]) fitparams([3 4]).*keep(1) fitparams(5) keep(2)];
[e tmpcoords.z] = makescotoma_step3(fitparams,coords);
fitparams
doplot(tmpcoords,5);

%--- re-estimate center
fitparams([1:2]) = fminsearch(@(x) makescotoma_step4(x,coords,fitparams),fitparams([1:2]),searchOptions);
[e tmpcoords.z] = makescotoma_step3(fitparams,coords);
fitparams
doplot(tmpcoords,6);


    

disp(sprintf('[%s]:SUMMARY:x,y-center: [%.2f %.2f]deg',mfilename,fitparams([1 2])));
d =  fitparams([3 4]);
disp(sprintf('[%s]:SUMMARY:diameter (absolute): [%.2f %.2f] (%.2f)deg',mfilename,...
             d(1),d(2),mean(d)));
disp(sprintf('[%s]:SUMMARY:area %.2fdeg2 (absolute)',mfilename,pi.*d(1).* ...
             d(2)));
d =  fitparams([3 4])+2.*fitparams(6);
disp(sprintf('[%s]:SUMMARY:diameter (relative): [%.2f %.2f] (%.2f)deg',mfilename,...
             d(1),d(2),mean(d)));
disp(sprintf('[%s]:SUMMARY:area %.2f deg2 (relative)',mfilename,pi.*d(1).* ...
             d(2)));



return
    
function doplot(coords,fig);
figure(fig);clf;
contourf(coords.x,coords.y,coords.z,[0:.1:1])
colormap('gray');colorbar;
set(gca,'XTick',0,...
        'YTick',0,...
        'XTickLabel',[],'YTickLabel',[]);
grid on;
axis equal;
hold on;
plot(coords.dotsx,coords.dotsy,'o');
hold off;
drawnow;
return

function [e c] = makescotoma_step1(fitparams,coords);
% fit circle
xx = coords.x - fitparams(1);
yy = coords.y - fitparams(2);
c  = (xx.^2)./(fitparams(3).^2) +  (yy.^2)./(fitparams(3).^2);
c  = c >= 1;

try,    e = nansum((coords.z(:)-c(:)).^2);
catch,  e = NaN;
end;
return;

function [e c] = makescotoma_step2(fitparams,coords);
% fit circle
xx = coords.x - fitparams(1);
yy = coords.y - fitparams(2);

theta = fitparams(5)./360*(2.*pi);
xx2 = xx .* cos(theta) - yy .* sin(theta);
yy2 = xx .* sin(theta) + yy .* cos(theta);

c  = (xx2.^2)./(fitparams(3).^2) +  (yy2.^2)./(fitparams(4).^2);
c  = c >= 1;

try,    e = nansum((coords.z(:)-c(:)).^2);
catch,  e = NaN;
end;
return;

function [e c] = makescotoma_step3(fitparams,coords);
% fit circle
xx = coords.x - fitparams(1);
yy = coords.y - fitparams(2);

theta = fitparams(5)./360*(2.*pi);
xx2 = xx .* cos(theta) - yy .* sin(theta);
yy2 = xx .* sin(theta) + yy .* cos(theta);

acc = 50;
c   = zeros(size(xx));
for n=acc:-1:1,
  add = fitparams(6).*(n-1)./acc;
  tmp = (xx2.^2)./((fitparams(3)+add).^2) +  (yy2.^2)./((fitparams(4)+add).^2);
  c(tmp<=1) = cos(((n-1)/acc)*pi)./2+.5;
end;

c  = 1 - c;

try,    e = nansum((coords.z(:)-c(:)).^2);
catch,  e = NaN;
end;
return;

function [e c] = makescotoma_step4(x,coords,fitparams);
% fit circle
xx = coords.x - x(1);
yy = coords.y - x(2);

theta = fitparams(5)./360*(2.*pi);
xx2 = xx .* cos(theta) - yy .* sin(theta);
yy2 = xx .* sin(theta) + yy .* cos(theta);

acc = 50;
c   = zeros(size(xx));
for n=acc:-1:1,
  add = fitparams(6).*(n-1)./acc;
  tmp = (xx2.^2)./((fitparams(3)+add).^2) +  (yy2.^2)./((fitparams(4)+add).^2);
  c(tmp<=1) = cos(((n-1)/acc)*pi)./2+.5;
end;

c  = 1 - c;

try,    e = nansum((coords.z(:)-c(:)).^2);
catch,  e = NaN;
end;
return;
