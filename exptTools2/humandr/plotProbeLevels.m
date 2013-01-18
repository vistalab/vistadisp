function plotProbeLevels(data)

len1 = length(data.trials);
for ii=1:len1
    data1(ii) = data.trials(ii).probeLcdLevel - data.trials(ii).flashLcdLevel;
    data2(ii) = data.trials(ii).response;
end

figure;
subplot(211);plot(data1)
subplot(212); plot(data2)
