function [cmapRGB]=create_LMScmap(display,maxLMS)
% create_LMScmap - create cone-based colormap
% 
% [cmapRGB]=create_LMScmap(display,maxLMS)
%
% example: 
% create achromatic and blue/yellow (s-cone) colormap at 80% contrast:
% cmapRGB = create_LMScmap(display,[1 1 1;0 0 1].*.8);

% 20061524 SOD: wrote it

% default
if nargin < 2,
    maxLMS = [1 1 1;...
              -1 1 0;...
              0 0 1];
end;

% make LMS colormap
cmaplength = size(display.gamma,1);
cmapLMS = zeros(cmaplength,3,size(maxLMS,1));
lin = linspace(-1, 1, cmaplength)';
for n=1:size(maxLMS,1),
    cmapLMS(:,:,n) = lin*maxLMS(n,:);
end;

% convert 
cmapRGB = Cmap_cone2RGB(display, cmapLMS);

% compute contrast (assuming first one is achromatic)
gray = mean(cmapRGB(:,:,1),2);
disp(sprintf('[%s]: Michelson contrast = %.1f%%',mfilename,(max(gray)-min(gray)).*100));

% correct for gamma
x = linspace(0,1,cmaplength)';
for n=1:3,
    y = display.gamma(:,n);
    cmapRGB(:,n,:) = interp1(x,y,cmapRGB(:,n,:),'spline');
end;

return;