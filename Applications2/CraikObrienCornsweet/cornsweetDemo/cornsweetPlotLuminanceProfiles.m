function cornsweetPlotLuminanceProfiles(params, stim, ii)

if ~params.plotLuminanceProfile, return; end

rows = params.nRows;
cols = params.nCols;

t  = 2*pi*ii/params.framesPerCycle;

% image midpoint
ind = size(stim.realEdge,1)/2;

yrng = [-params.amplitude params.amplitude ]*1.1 + .5;
yrng = round(255*yrng);
xrng = linspace(-1,1, size(stim.thisrealEdge,2));

ii = 1;
if params.showSquareWave,
    subplot(rows, cols, cols + ii)
    plot(xrng, round(255*stim.thisrealEdge(ind,:)), '.', 'MarkerSize', 2);
    axis square; ylim(yrng)
    set(gca, 'XColor', 'w', 'YColor', 'w')
    xlabel('horizontal position')
    ylabel('frame buffer value');
    ii = ii +1;
end

if params.showCOC,
    subplot(rows, cols, cols + ii)
    plot(xrng, round(255*stim.thiscocEdge(ind,:)), '.', 'MarkerSize', 2);
    axis square; ylim(yrng)
    set(gca, 'XColor', 'w', 'YColor', 'w')
    xlabel('horizontal position')
    ylabel('frame buffer value');
    ii = ii +1;
end

if params.showMixture,
    subplot(rows, cols, cols + ii)
    plot(xrng, round(255*stim.thismixture(ind,:)), '.', 'MarkerSize', 2);
    axis square; ylim(yrng)
    set(gca, 'XColor', 'w', 'YColor', 'w')
    xlabel('horizontal position')
    ylabel('frame buffer value');
end

end


