function rgbImg = paintDots(indImage, indRGB)
% indRGB = cell array with RGB values for each formInd
% indImage = matrix of color indices
%

sz = size(indImage);
if length(sz)==2 % this probably means you only have 1 frame
    sz(3) = 1;  % explicitly tell it that there is only 1 frame
end
% cmap is like indRGB, but a Nx3 array (e.g. cmap = round(gray(42)*255))
cmap=cell2mat(indRGB');

rgbImg = cmap(indImage(:),:);
rgbImg = reshape(rgbImg,[sz(1), sz(2), sz(3) 3]);
rgbImg = permute(rgbImg,[1 2 4 3]);

return

% colorInd = unique(indImage(:))'; % 800 ms
% colorInd = find(~cellfun('isempty',indRGB));
% 
% rgbImage = zeros(sz(1), sz(2), 3, sz(3)); % 250 ms - create empty matrix with room for RGB values and the frame(s)
% 
% for jj = colorInd
%     tmp1 = indImage==jj; % 50 ms - select one color index
%     n = size(indRGB{jj},1); % .05 ms check how many color options you have
%     curColor = round(rand(1,sum(tmp1(:)))*(n-1)+1); % 400 ms - randomly assign one of the colors to each dot
% 
%     for kk = 1:3 % 1600 ms
%         tmp2 = rgbImage(:,:,kk,:);
%         tmp2(tmp1) = indRGB{jj}(curColor,kk);
%         rgbImage(:,:,kk,:) = tmp2;
%     end
% end
