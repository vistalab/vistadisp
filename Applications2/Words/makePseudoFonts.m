load myFont

r = 50; c = 50;
cmap = [1 1 1; 0 0 0];
thick = 2;

clear im;
for(ii=1:length(myFont))
    im(:,:,ii) = renderSpline(scaleSpline(myFont(ii).spline,c*.2,r*.2,c*.8, r*.8), r, c, thick);
end
montage = makeMontage(im(:,:,:)+1);
figure; image(montage); colormap(cmap); truesize; axis off;

% Reminder:
%	z = amp * exp(i*phase);  amp = abs(z);  phase = angle(z);
newPh = rand(size(im))*2*pi-pi;
for(ii=1:length(myFont))
    ftim(:,:,ii) = fft2(double(im(:,:,ii)>.5));
end
triplet = [im(:,1:36,7), im(:,1:36,19), im(:,1:36,2), im(:,1:36,11)];
scramble = [.3:.05:.8]; %1-logspace(0,-1,5);
scramble = [.3 .45 .55 .65 75];
h = figure;
for(ii=1:length(scramble))
    sc = scramble(ii);
    newPh = rand(size(triplet))*2*pi-pi;
    %scrambleIm = real(ifft2(abs(ftim) .* exp(i*((1-sc)*angle(ftim)+sc*newPh))));
    fftIm = fft2(triplet);
    scrambleIm = real(ifft2(abs(fftIm) .* exp(i*((1-sc)*angle(fftIm)+sc*newPh))));
    scrambleIm(scrambleIm>1) = 1;
    scrambleIm(scrambleIm<-1) = -1;
    subplot(length(scramble), 1, ii);
    imagesc(makeMontage(scrambleIm(:,:,:))); colormap(gray); axis equal tight off;
    %title(sprintf('Scramble = %0.2f',sc));
end
truesize;

% find the x-coordinate of all the endpoints
for(ii=1:length(myFont)) 
    for(jj=1:length(myFont(ii).spline)) 
        x{ii,jj} = myFont(ii).spline(jj).x([1,end]);
    end 
end
maxX = max([x{:}]);
maxX = ceil(maxX*10)/10;
xPix = ceil(c*maxX);

% Generate font pict files
distort = linspace(0,1,4);
colDiff = [0,0,0;0,0,-.35];
outDirName = 'pseudoFontsSmall';
outDirBasename = '/snarp/u1/bob/fonts';
for(fontNum=1:length(myFont))
    clear im;
    for(distortIndex=1:length(distort))
        sp = myFont(fontNum).spline;
        % distort font
        d = distort(distortIndex);
        for(jj=1:length(sp))
            sp(jj).x = sp(jj).x + (rand(size(sp(jj).x))-.5)*d;
            sp(jj).y = sp(jj).y + (rand(size(sp(jj).y))-.5)*d;
            %sp(jj).y = (1-d)*sp(jj).y + d*(sp(jj).x);
            sp(jj).x(sp(jj).x>maxX) = maxX; sp(jj).x(sp(jj).x<0) = 0;
            sp(jj).y(sp(jj).y>1) = 1; sp(jj).y(sp(jj).y<0) = 0;
        end
        tmpIm = renderSpline(scaleSpline(sp,c*.1,r*.1,c*.9, r*.9), r, c, thick);
        im(:,:,distortIndex) = tmpIm(:,1:xPix);
        
        % Save font
        letter = myFont(fontNum).char;
        fname = [letter '_' num2str(round(d*100),'%03d') '_dist05'];
        if(~exist(fullfile(outDirBasename,outDirName),'dir')) mkdir(outDirBasename,outDirName); end
        fname = fullfile(outDirBasename,outDirName, fname);
        imwrite(im(:,:,distortIndex)+1, cmap, [fname '_1.bmp']);
        imwrite(im(:,:,distortIndex)+1, cmap-colDiff, [fname '_2.bmp']);
        disp(fname);
    end
    %montage = makeMontage(im(:,:,:)+1,[],[],length(distort));
    %figure; image(montage); colormap(cmap); truesize; axis off;
end

