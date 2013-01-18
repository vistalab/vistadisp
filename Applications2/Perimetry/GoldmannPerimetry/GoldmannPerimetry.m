function GoldmannPerimetry;
% GoldmannPerimetry - perform's Goldmann perimetry

% 08/2005 sod wrote it

% initialize params
gp = gp_params;

% show stimulus
tic;
gp = gp_presentation(gp);
fprintf(1,'[%s]:Done (%.1f min).\n',mfilename,toc./60);

% get field map
gp.response.field = gp.response.coordDetected./gp.response.coordShown;

% scale and interp response field
f.scaled = gp_scale(gp.response.field,max(gp.screenSize)/50);
f.interp = gp_interp(f.scaled);

% view
imagesc(f.interp,[0 1]);colormap('gray');axis('image','off');

% save
save
filename = ['~/Desktop/' mfilename '-' gp.subject '-' datestr(now,30) '.mat'];
save(filename);
disp(sprintf('[%s]:saved data in: %s',mfilename,filename));
