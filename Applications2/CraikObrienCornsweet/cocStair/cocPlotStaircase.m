function cocPlotStaircase(stairParams, newDataSum)

if(~isempty(stairParams.curStairVars))
    val = stairParams.curStairVars{2};
    var = stairParams.curStairVars{1};
else
    var = '';
    val = [];
end
figure;
for(ii=1:length(newDataSum))
    n = length(newDataSum);
    subplot(n,2,ii*2-1);
    %semilogy(newDataSum(ii).history, 'o-');
    plot(newDataSum(ii).history, 'o-');    
    ylabel(stairParams.adjustableVarName); xlabel('Trial number');
    if(~isempty(var)), title([var '=' num2str(val(ii))]); end

    
    % if we get enough trials, we can fit a psychometric function
    resp = newDataSum(ii).numCorrect./newDataSum(ii).numTrials;
    level = newDataSum.stimLevels;
    subplot(n,2,ii*2);
    plot(level(resp>=0), resp(resp>=0), 'x-'); hold on
    ylabel('p match > test'); xlabel('contrast of match stimulus');
    if(~isempty(var)), title([var '=' num2str(val(ii))]); end

    analysis = analyzeStaircase(newDataSum(ii));
    n = sum(~isnan(newDataSum(ii).reversalStimLevel));
    thresh(ii) = mean(newDataSum(ii).reversalStimLevel(3:n));

    %plot the threshold val
    plot([thresh(ii) thresh(ii)], [0 1], 'r');
end
figure
plot(val, thresh, 'ro-')
xlabel(var)
ylabel('thresh')

