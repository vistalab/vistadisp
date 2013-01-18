level = 100;
pair = 15;
stimsize = 512;
[x, y] = meshgrid(1:stimsize, 1:stimsize);
targetX = stimsize/2;
targetY = stimsize/2;
[sm in] = makeShape(level, pair, stimsize, x, y, targetX, targetY);

%%
im = 0;
for ii = 25:25:1000
    [~, in] = makeShape(ii, pair, stimsize, x, y, targetX, targetY);
    im = double(im) + double(in);
    fprintf('%d ',ii); drawnow;
end

%%
f = fft2(double(in));
m = abs(f);
ph = angle(f);

inds = randperm(length(ph(:)));
ph = reshape(ph(inds), size(ph));
%m = reshape(m(inds), size(m));
f2 = m.*exp(1i*ph);
newimage = ifft2(f2);

figure(1); clf 
subplot(1,2,1)
imshow(in)
subplot(1,2,2)
imshow(abs(newimage))
