function imgList = ewRenderList(stimParams,stringList)

for i=1:length(stringList)
    fprintf('Rendering Text: %s\n',stringList{i});
    tmp = renderText(stringList{i}, stimParams.fontName, ...
        stimParams.fontSize, stimParams.sampsPerPt, ...
        stimParams.antiAlias, stimParams.fractionalMetrics, ...
        stimParams.boldFlag);
    imgList{i} = uint8(tmp);
    % Size correcting loop
    %{
    sz = size(tmp);
    if(any(sz>stimParams.stimSizePix)) %true if some stimulus is larger than allowed
        r = stimParams.stimSizePix(1);
        c = stimParams.stimSizePix(2);
        error('Largest stimulus exceeds specificed stimulus size (%d %d).',r,c);
    end

    imgList{i} = zeros(stimParams.stimSizePix, 'uint8');

    % rect is [left,top,right,bottom]. Matlab array is usually y,x
    r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimParams.stimSizePix]);
    imgList{i}(r(1):r(3),r(2):r(4)) = uint8(tmp);
        %}
end