function blockInfo = locMakeAperture(blockInfo, blankColor)
% Show stimulus through a circular aperture, whose diameter is equal to the
% shorter length of the rectangular window defined by the image
%      
% blockInfo = makeAperture(blockInfo, blankColor)     
sz   = size(blockInfo.images{1});
diam = min(sz(1:2));
mask = makecircle(diam, diam);


for ii = 1:numel(blockInfo.images)
    sz   = size(blockInfo.images{ii});
    dims = length(sz);
    switch dims
        case 2 % gray scale
            blockInfo.images{ii}(~mask) = blankColor;
        case 3 % rgb
            for d = 1:3
                im = blockInfo.images{ii}(:,:,d);
                im(~mask) = blankColor;
                blockInfo.images{ii}(:,:,d) = im;
            end
            %                blockInfo.images{ii}(:,:,4) = mask*255;
        case 4 % rgb-alpha
            % do nothing. not smart but we'll deal with this later
    end
end
return
