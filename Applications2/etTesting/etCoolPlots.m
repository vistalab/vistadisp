function etCoolPlots(data,params)
close all

display = loadDisplayParams('displayName', 'NEC485words.mat');
refVals = [ 90,     0;      
            90,     2.5;    
            90,     5;      
            180,    2.5;    
            180,    5;      
            270,    2.5;    
            270,    5;      
            360,    2.5;    
            360,    5];      
refMarks = {'k.'; 'gx'; 'g*'; 'rx'; 'r*'; 'bx'; 'b*'; 'mx'; 'm*'};

    
for i=1:size(data.screenLoc,2);
    figure(i);
    for iii=1:size(refVals,1)
        dot = computePosition(display,[.5 .5],refVals(iii,1),refVals(iii,2));
        plot(dot(3),dot(4),refMarks{iii},'MarkerSize',10); hold on;
    end
    plot(params.screenET(1,:),params.screenET(2,:),'bo');
    for ii=1:20
        jitterX = ((-1)^round(rand))*rand*5;
        jitterY = ((-1)^round(rand))*rand*5;
        markerType = refMarks(refVals(:,2)==data.distance{ii,i} & refVals(:,1)==data.angle{ii,i});
        plot(data.screenLoc{ii,i}(1,2:end)+jitterX,data.screenLoc{ii,i}(2,2:end)+jitterY,sprintf('%s',cell2mat(markerType)),'MarkerSize',5);
    end
end




