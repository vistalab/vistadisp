function stim = facebehav_loadImages(stim);
% Load the images specified in a face behavior script.
%
%   stim = facebehav_loadImages(stim);
%
% stim should either be a path to a script (see facebehav_makescript), or a
% struct loaded from the script.
%
% ras, 06/23/2009.
if notDefined('stim')
    error('Need stim struct, or script path.')
end

if ischar(stim), stim  = facebehav_readscript(stim);    end

fprintf('[%s]: Loading images.', mfilename);

% set the 'seq' field by finding where each image lies
stim.imgNum = countImages(stim);


% for stim.imgNum > 0, these are actual image files, load 'em
for n = 1:max(stim.imgNum)
	I = find(stim.imgNum==n);

	[p f ext] = fileparts( stim.image{I(1)} ); % ignores trailing spaces
	img = imread( fullfile(p, f), 'png' );
	stim.images{n} = img;
	
	stim.imgNum(I) = n;
	stim.imgpath{n} = fullfile(p, [f ext]);
	
	fprintf('.');
	if n==20 | mod(n, 100)==0
		fprintf('\n');
	end
end

%% for stim.imgNum < 0, set up a blank image as the last image and point to
%% that:
sz = size(stim.images{1});
stim.images{end+1} = repmat(uint8(stim.bgColor), [sz(1:2)]);
stim.imgNum(stim.imgNum < 0) = length(stim.images); % point to blank image

stim.imgpath{end+1} = 'blank';

%% make fields with names readable by the other stimulus code
stim.seqtiming = stim.onset;
stim.fixSeq = ones( size(stim.imgNum) );

% also add an entry to set the color map at the beginning of the sequence
stim.imgNum = [-1 stim.imgNum];
stim.seqtiming = [0 stim.seqtiming];
stim.fixSeq = [1 stim.fixSeq];
stim.cond = [0 stim.cond];
stim.faceSize = [0 stim.faceSize];
stim.faceEcc = [0 stim.faceEcc];
stim.faceAngle = [0 stim.faceAngle];
stim.isMatch = [-1 stim.isMatch];
stim.trialNum = [0 stim.trialNum];
stim.onset = [0 stim.onset];
stim.image = [{'set color map'} stim.image];

fprintf('done.\n');

return
