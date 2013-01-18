function scrambleIm = scrambleImage(im,scrambleLevel)
%
% Function to scramble an image.  Differs from scrambleWord in that
% scrambleWord takes a string as an input, while this function takes an
% image as an input.
%
%    scrambleIm = scrambleImg(im,scrambleLevel)
%

fftIm = fft2(im);
newPh = angle(fftIm) + scrambleLevel*(rand(size(im))-.5)*pi*2;
% We want to preserve some phases (DC level- but that shouldn't
% matter?)
k = [1,1];
sz = size(newPh);
keep = sub2ind(sz, k(:,1), k(:,2));
newPh(keep) = angle(fftIm(keep));
scrambleIm = real(ifft2(abs(fftIm) .* exp(i*newPh)));
% 
% % For colormap out of 255 e.g. some words, faces/objects
scrambleIm(scrambleIm<1) = 1;
scrambleIm(scrambleIm>255) = 255;
scrambleIm = double(scrambleIm);

% For 0s and 1s (old version of makeMovingWordTrial2.m used this format)
% scrambleIm(scrambleIm>1) = 1;
% scrambleIm(scrambleIm<-1) = -1;
% scrambleIm = uint8(round(scrambleIm*127.5+127.5));

% To display the resulting image
%figure;image(scrambleIm); colormap(gray(256)); truesize;

