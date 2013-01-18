function [r, t, sf] = GaborPlotStaircase(stairParams, newDataSum)
% GaborPlotStaircase(stairParams, newDataSum)

% plot the history of the staircase (to check for proper convergence)
sf = stairParams.curStairVars{2};

if ~(nargout > 0), figure; end
for(ii=1:length(newDataSum))
    if ~(nargout > 0)
        subplot(length(newDataSum),1,ii);
        semilogy(newDataSum(ii).history);
        ylabel('Contrast'); xlabel('Trial number');
        title([num2str(sf(ii)) ' cpd']);
    end
    
    % calculate the mean reversal value
    n = sum(~isnan(newDataSum(ii).reversalStimLevel));
    r(ii) = mean(newDataSum(ii).reversalStimLevel(3:n));
    
    % if we get enough trials, we can fit a psychometric function
    analysis = analyzeStaircase(newDataSum(ii));
    t(ii) = analysis.thresh;
end

% Plot the CSF
if ~(nargout > 0), figure; end;
sr = log10(1./r);
st = log10(1./t);

if ~(nargout > 0)
    plot(log10(sf), sr, 'b-o'); hold on
    plot(log10(sf), st, 'r-x'); hold on
    
    ylabel('Sensitivity'); xlabel('Spatial Freq (cpd)');
    x = get(gca,'XTickLabel');
    x = num2str(10.^str2num(x), '%0.1f');
    set(gca,'XTickLabel', x);
    legend({'mean reversal value', 'fitted weibull threshold'});
end

