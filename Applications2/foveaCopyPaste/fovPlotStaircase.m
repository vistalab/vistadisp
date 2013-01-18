function fovPlotStaircase(stairParams, newDataSum, figurenum)
% fovPlotStaircase(stairParams, newDataSum, [figurenum])
%
% Plot staircase data from foveal-copy-paste expt

% how many staircasaes are there?
nstaircases = length(newDataSum);
thresh      = NaN(1, nstaircases);

% plot the results
if exist('figurenum', 'var')
    figure(figurenum); clf
else
    figurenum = figure;
end

for ii=1:nstaircases
    % if we get enough trials, we can fit a psychometric function
    analysis = analyzeStaircase(newDataSum(ii));
    thresh.weibull(ii) = analysis.thresh;
    n = sum(~isnan(newDataSum(ii).reversalStimLevel));
    thresh.reversal(ii) = mean(newDataSum(ii).reversalStimLevel(3:n));
    resp = newDataSum(ii).numCorrect./newDataSum(ii).numTrials;
    level = newDataSum.stimLevels;

    % ********************
    % Trial History
    % ********************    
    subplot(2, nstaircases,ii);
    
    plot(newDataSum(ii).history, 'o-'); hold on   
    ylabel(stairParams.adjustableVarName); xlabel('Trial number');
    title(stairParams.conditionName{ii}); 
    axis tight;
    ylim([0 max([newDataSum.history])]);
    % plot the threshold val
    xl = get(gca, 'xlim');
    plot(xl, [thresh.reversal(ii) thresh.reversal(ii)], 'r');
    plot(xl, [thresh.weibull(ii) thresh.weibull(ii)], 'g');
    
    % *********************
    % Psychometric function
    % *********************   
    subplot(2, nstaircases,ii+nstaircases);

    % plot raw data points
    plot(level(resp>=0), resp(resp>=0), 'x'); hold on

    % plot fitted weibull
    plot(analysis.wx, analysis.wy)
    ylabel('correct (%)'); xlabel(stairParams.adjustableVarName);
    title(stairParams.conditionName{ii}); 
    ylim([0 1])

    % plot the threshold val
    plot([thresh.reversal(ii) thresh.reversal(ii)], [0 1], 'r');
    plot([thresh.weibull(ii)  thresh.weibull(ii)], [0 1], 'g');
    xlims(ii, 1:2) = get(gca, 'xlim');    
    %set(gca, 'xscale', 'log')

end

% set all the axes to be the same 
for ii=1:nstaircases
    subplot(2, nstaircases,ii+nstaircases);
    xlim([min(xlims(:, 1)) max(xlims(:,2))]);    
end


figure(figurenum + 1); 
bar([thresh.reversal; thresh.weibull]')
legend({'mean of reversals', 'weibull fit'})
title('Thresholds across conditions', 'FontSize', 14);
set(gca, 'XTickLabel', stairParams.conditionName)
ylabel('Distance in parameterized shape space')
