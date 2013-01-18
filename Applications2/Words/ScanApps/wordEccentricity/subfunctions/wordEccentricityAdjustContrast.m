function img = wordEccentricityAdjustContrast(img,rgbInForm,rgbOutForm)

img(img==1) = rgbInForm;
img(img==0) = rgbOutForm;
img = img/255;