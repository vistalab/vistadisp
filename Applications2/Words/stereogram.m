function [M]= stereogram(A,varargin)
% stereogram     Random Dot Stereogram
% 
% stereogram(A), where A is a monochromatic image, plots the
% Random Dot Stereogram (RDS) of A.
% A should be defined as a matrix of doubles, but with integer
% values. In the stereogram, the regions of A with positive values
% will seem virtually fly in front of the screen, while those with
% negative values will seem to be behind the screen.
% The best maximum range of the values of A is -15,15.
% The script will NOT autoscale the data, allowing you to set
% the absolute height of each level with respect to the screen.
% 
% stereogram(A,'method') specifies alternate viewing methods.
% The default is parallel-eyes method.  Available methods are:
% 
%  'parallel-eyes'
%  'crossed-eyes'
% 
% See http://www.vision3d.com/ to learn viewing stereograms.
%
% The vertical white line in the stereogram helps the visualization.
% You can remove it to obtain a Single-Image Stereogram.
% 
% A Random Dot Stereogram (RDS) is a technique created by Dr. Bela Julesz,
% described in the book Foundations of Cyclopean Perception. RDS describes
% a pair of 2D images showing random dots which when viewed with a
% stereoscope produced a 3D image. When this technique is used to
% create an Autostereogram (also known as Single-Image Stereogram), a
% Random-dot autostereogram (SIRDS) is created.
% (Source: http://en.wikipedia.org/wiki/Random_dot_stereogram)
% 
% Please, feel free to contact me and suggest modifications.
% 
% ----------------------------------------------------------
% (c) 2007  Iari-Gabriel Marino, Ph.D.
% University of Parma
% Physics Department
% Viale G.P. Usberti, 7/a
% 43100 Parma - Italy
% e-mail: iarigabriel.marino@fis.unipr.it
% web: http://www.fis.unipr.it/home/marino/
% Tel. +39 (0) 521 906212
% Fax +39 (0) 521 905223
% ----------------------------------------------------------
% 
% Example:
% A=peaks(300);
% A=A-mean(mean(A));
% A=10*A/max(max(A));
% A=round(A);
% stereogram(A)

if nargin==1
    view_type = 'parallel-eyes'; % can be 'crossed-eyes'
elseif nargin==2
    view_type = varargin{1};
end


A=double(A);
A=round(A);

RDM = round(rand(size(A))); % Random Dot Matrix

% Initial left and right images
SX = RDM;
DX = RDM;

% For each region of A, a random dot pattern
% is shifted of an amount depending on the level
for k = min(min(A)):max(max(A))
    if k<0
        level = size(A,2)+k;
        TT = [RDM(:,level+1:end) RDM(:,1:level)];
    elseif k>0
        level = k;
        TT = [RDM(:,level+1:end) RDM(:,1:level)];
    elseif k==0
        level = 1;
        TT = RDM;
    end
    DX(A==k) = TT(A==k);
end

% Selection of the view type
% The 'ones(size(SX,1),5)' is the white line

if strcmp(view_type,'parallel-eyes')
    M = [SX ones(size(SX,1),5) DX];
elseif strcmp(view_type,'crossed-eyes')
    M = [DX ones(size(SX,1),5) SX];
end

% % Option for no white line

% if strcmp(view_type,'parallel-eyes')
%     M = [SX DX];
% elseif strcmp(view_type,'crossed-eyes')
%     M = [DX SX];
% end

im_h = imagesc(M);
axis off
% truesize is necessary to avoid automatic scaling
size_one2one(im_h)
colormap gray

set(gcf,'number','off','name','Stereogram - by I.-G. Marino')

shg

function size_one2one(im_h)
ax_h = gca;
fig_h = gcf;

iw = size(get(im_h, 'CData'), 2);
ih = size(get(im_h, 'CData'), 1);

set(ax_h, 'Units', 'pixels');
set(fig_h, 'Units', 'pixels');
set(0, 'Units', 'pixels');

figurePos = get(fig_h, 'Position');

dap = get(0,'DefaultAxesPosition');

brdr_wi = round((1 - dap(3)) * iw / dap(3));
brdr_he = round((1 - dap(4)) * ih / dap(4));
brdr_le = floor(brdr_wi/2);
brdr_bo = floor(brdr_he/2);

RDS_fig_wi = iw + brdr_wi;
RDS_fig_he = ih + brdr_he;

figurePos(1) = figurePos(1) - floor((RDS_fig_wi - figurePos(3))/2);
figurePos(2) = figurePos(2) - floor((RDS_fig_he - figurePos(4))/2);
figurePos(3) = RDS_fig_wi;
figurePos(4) = RDS_fig_he;

axesPos(1) = brdr_le + 1;
axesPos(2) = brdr_bo + 1;
axesPos(3) = iw;
axesPos(4) = ih;

set(fig_h, 'Position', figurePos)
set(ax_h, 'Position', axesPos);

drawnow;
