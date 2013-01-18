flashLumLed = logspace(log10(0.5), log10(0.9), 10)

%flashLumLed = flashLumLed(2:2:8);
%flashLumLed = [flashLumLed, logspace(log10(0.8),log10(0.95), 5)];
%flashLumLed = flashLumLed(1:end);

%flashLumLed = [0.8];
%flashLumLed = flashLumLed(4);

flashOrd = randperm(length(flashLumLed))

%greg
% Luminance recorded from the spectrophotometer at 
lum_lcd_255_led_200_cdm2 = 100;

% gamma_lcd(x) * gamma_led(x) * luminance_max
gamma_lcd = 2.6;
gamma_led = 1;
flashLumLcd = 0.5;
flashLum_cdm2 = flashLumLed .* flashLumLcd .* lum_lcd_255_led_200_cdm2;


for ii = flashOrd
%for ii = 2:length(flashLum)
    hdrFlashProbeExpt(flashLumLed(ii));
    disp(sprintf('Press a key (last trial=%0.2f)',flashLumLed(ii)));
    pause;
end



%plot(flashLum_cdm2, flashLum_cdm2 .* thresh