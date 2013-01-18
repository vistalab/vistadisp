function [matrixout] = gp_interp(matrix);
% gp_interp - interpolate NaNs using nearest neighbor interpolation
%

% 08/2005 SOD wrote it.

% get sizes
[ylen, xlen] = size(matrix);

% define coords
zi = matrix(:);
xi = ones(ylen,1)*[1:xlen];
xi = xi(:);
yi = [1:ylen]'*ones(1,xlen);
yi = yi(:);



% these next steps can create very large matrix
xd = xi*ones(1,length(xi));
yd = yi*ones(1,length(yi));
dist = sqrt((xd-xd').^2+(yd-yd').^2);

% remove to be filled in values
dist(isnan(zi*ones(1,length(zi))))=xlen*ylen;

% now find closest 
[c, closest] = min(dist);


% and reshape back
matrixout = reshape(zi(closest),[ylen xlen]);
