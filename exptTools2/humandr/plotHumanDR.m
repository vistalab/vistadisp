function plotHumanDR(path, thresh_method)

if(~exist('thresh_method','var') || isempty(thresh_method))
    thresh_method = 2;
end

files = dir(fullfile(path,'human*'));
% Luminance recorded from the spectrophotometer for the patch
% at 3/18/06 5:27 PM
lum_lcd_255_led_200_cdm2 = 2.9754e+003;
% gamma_lcd(x) * gamma_led(x) * luminance_max
flashLumLcd = 0.5;

if (length(files) < 1)
    disp('No files found.');
    return;
end


for ii = 1:length(files)
    load(fullfile(path,files(ii).name));
    
    % data.flashLum is just the luminance of the LED (flashLumLed)
    flashLumLed(ii) = data.flashLum;
    flashLum_cdm2(ii) = data.flashLum .* flashLumLcd .* lum_lcd_255_led_200_cdm2;
	thresh_log10Delta(ii) = QuestMean(data.quest);
end


if (thresh_method == 1)
    % Old method (Method 1) of computing threshold in hdrFlashProbeExpt
    thresh_cdm2 = flashLumLed .* 10.^ thresh_log10Delta .* lum_lcd_255_led_200_cdm2; 
elseif (thresh_method == 2)
    % 10.^ thresh_log10Delta is in units of percentage of the input flash
    % luminance
    thresh_cdm2 = flashLum_cdm2 .* 10.^thresh_log10Delta;
else
    return;
end

plotdata = sortrows([flashLum_cdm2(:) thresh_cdm2(:)]);

% TODO: sort them.
loglog(plotdata(:,1), plotdata(:,2), 'ro--');
ylabel('Threshold (cd/m^2)');
xlabel('Flash intensity (cd/m^2)');
title('Detection threshold in flash-probe experiment on the HDR display')
%ylim([10^0, 10^1]);    

%plot(flashLum_cdm2, flashLum_cdm2 .* thresh