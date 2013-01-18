function results20051118_3Tprojector;

mm_x = linspace(0,1,11)';

mm_y = [8.6 8.4 7.3;...
   8.7  19.6    7.9;...
   10.9 65.7    8.4;...
   17.2 147     9.8;...
   26.9 259     12.2;...
   41.5 407     16.3;...
   60   573     21.3;...
   83.6 753     28.2;...
   109  954     35;....
   140  1140    45.5;...    
   172  1350    58];

x = [mm_x];
y = [mm_y] ./ (ones(size(mm_y(:,1)))*mm_y(end,:));
normfac = mm_y(end,:);

% fit polynomial
xint = linspace(0,1,255)';
Npoly=9;
for n=1:3,
    p{n} = polyfit(x,y(:,n),Npoly);
    yint(:,n) = polyval(p{n},xint)/polyval(p{n},1);
end;
    
% invert
cmapMax = 255;
gamma = zeros(cmapMax+1,3);
precise = (0:0.01:cmapMax)'/cmapMax; 
for jj = 1:3
	tmp = polyval(p{jj},precise)/polyval(p{jj},1);
	for ii=0:cmapMax;
		[junk placetmp] = min(abs(ii/cmapMax-tmp));
		gamma(ii+1,jj) = precise(placetmp);
	end
end
gamma(gamma>1)=1;
gamma(gamma<0)=0;

% plot gamma
figure(1);clf;
X = [0:255]'./255;
plot(x,y,'o');hold on;
plot(x,mean(y,2),'kx','MarkerSize',20);hold on;
plot(xint,yint);
axis([0 1 0 1]);
axis square;

% plot inverted gamma
figure(2);clf;
plot(y,x,'o');hold on;
plot(mean(y,2),x,'kx','MarkerSize',20);hold on;
plot(xint,gamma);
axis([0 1 0 1]);
axis square;

yint(yint>1)=1;
yint(yint<0)=0;
gammaTable = round(gamma.*cmapMax);
save('gamma.mat','gamma','gammaTable');
return
