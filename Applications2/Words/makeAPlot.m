function makeAPlot(threshVals,threshErr)

pAngs =     [0 10 25 35 65 90];


for i=1:length(threshVals)
    [X(i) Y(i)] = cCompute(threshVals(i), pAngs(i));
end

%{
for i=1:6
    [X Y] = cCompute(0,pAngs(i));
    [Xend Yend] = cCompute(1,pAngs(i));
    plot([X Xend],[Y Yend],'-k','LineWidth',3);
    hold on;
end
%}

plot(X,Y,'-ks','LineWidth',2);
hold on

if exist('threshErr','var')
    errPos = threshVals + threshErr;
    errNeg = threshVals - threshErr;

    for i=1:length(pAngs)
        [errPosX(i) errPosY(i)] = cCompute(errPos(i), pAngs(i));
        [errNegX(i) errNegY(i)] = cCompute(errNeg(i), pAngs(i));
        plot([errNegX(i) errPosX(i)],[errNegY(i) errPosY(i)],'-ko','LineWidth',2);
        hold on
    end
end

%xlabel('Motion Coherence', 'fontSize', 16);
%ylabel('Luminance Contrast', 'fontSize', 16);
set(gca,'XTick',0:(1.4/5):1.4, 'fontSize', 16)
set(gca,'YTick',0:(.4/5):0.4, 'fontSize', 16)
xlim([0 1.4])
ylim([0 .4])