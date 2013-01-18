function scotoma = makeArtificialScotoma(mSizePixels,mSizeDeg,params);
% makeArtificialScotoma - which can then be used to mask stimuli
%
% makeArtificialScotoma(mSizePixels,mSizeDeg,params);
%
% Inputs: mSizePixels : size of matrix array in pixels (max size)
%         mSizeDeg    : size of matrix array in degrees (diameter)
%         params      : parameters defining scotoma which is
%                       modeled as a smooth elipsoid:
%                       [center_x, center_y,...
%                        size_x, size_y,...
%                        rotation,...
%                        edgewidth]
%                       Units are all in degrees.
%
% 2007/01 SOD: wrote it.

% fill params with zeros
if numel(params)<6,
  params(6)=0;
end
% if one size make it symmetric
if ~params(4),
  params(4)=params(3);
end;

%  make matrix
[xx yy] = meshgrid(linspace(-mSizeDeg,mSizeDeg,mSizePixels));

% center
xx = xx - params(1);
yy = yy - params(2);

% rotate
theta = params(5)./360*(2.*pi);
xx2 = xx .* cos(theta) - yy .* sin(theta);
yy2 = xx .* sin(theta) + yy .* cos(theta);

% size
acc = 50;
c   = zeros(size(xx));
for n=acc:-1:1,
  add = params(6).*(n-1)./acc;
  tmp = (xx2.^2)./((params(3)+add).^2) +  (yy2.^2)./((params(4)+add).^2);
  c(tmp<=1) = cos(((n-1)/acc)*pi)./2+.5;
end;

scotoma  = flipud(1 - c);

if ~nargout,
  imagesc(scotoma,[0 1]);axis off image;colorbar;
end;
return;
