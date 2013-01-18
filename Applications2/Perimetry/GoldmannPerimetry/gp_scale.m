function [matrixout] = gp_scale(matrix,factor);
% gp_interp - scale ignoring NaNs 
%

% 08/2005 SOD wrote it.

% get sizes
[ylen, xlen] = size(matrix);

newmatrix = zeros(round(ylen/factor),round(xlen/factor));

% define original coords
zi = matrix(:);
xi = ones(ylen,1)*[1:xlen];
xi = xi(:);
yi = [1:ylen]'*ones(1,xlen);
yi = yi(:);

% keep finites
keep = finite(zi);
zi = zi(keep);
xi = xi(keep);
yi = yi(keep);

% scale coords
x = round(xi/factor);
y = round(yi/factor);
x(x<1)=1;
y(y<1)=1;

% put in new values
sum = newmatrix;
num = newmatrix;
for n=1:length(x),
    sum(y(n),x(n)) = sum(y(n),x(n)) + zi(n);
    num(y(n),x(n)) = num(y(n),x(n)) + 1;
end;

% new values - rest is NaN
matrixout = sum./num;
