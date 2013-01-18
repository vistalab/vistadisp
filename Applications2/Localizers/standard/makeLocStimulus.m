function [stimulus, onebackSeq] = makeLocStimulus(params)
% makeRetinotopyStimulus - make various retinotopy stimuli
% Matlab code to generate various retinotopy stimuli
% Generates one full cycle, as well as the sequence for the entire scan.
%
% 99.09.15 RFD: I fixed the sequence generation algorithm so that
%   timing is now frame-accurate.  The algorithm now keeps track
%   of timing error that accumulates due to rounding to the nearest
%   frame and corrects for that error when it gets to be more than 
%   half a frame.  
%   The algorithm also randomely reverses the drift direction, rather
%   than reversing every half-an image duration.
% 2005.06.15 SOD: changed for OSX - stimulus presentation will now be 
%                 time-based rather than frame based. Because of bugs
%                 with framerate estimations.


% load matrix or make it
if ~isempty(params.loadMatrix),
    % we should really put some checks that the matrix loaded is
    % appropriate etc.
    load(params.loadMatrix);
    disp(sprintf('[%s]:loading images from %s.',mfilename,params.loadMatrix));
%    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));
else,

    blankIm    = params.prescanDuration  *params.temporal.frequency;
    offBlockIm = params.duration.offBlock*params.temporal.frequency;
    onBlockIm  = params.duration.onBlock *params.temporal.frequency;
       
    switch params.experiment
   
        case 'faces vs objects (no faces) vs scrambled vs fixation',
            sequence = [zeros(blankIm,1)];
            index    = [1 2 3];
            for n=1:params.ncycles,
                sequence = [sequence; ...
                    ones(onBlockIm,1)*index(1); zeros(offBlockIm,1);...
                    ones(onBlockIm,1)*index(2); zeros(offBlockIm,1);...
                    ones(onBlockIm,1)*index(3); zeros(offBlockIm,1)];
                % rotate sequence index
                index = index([2 3 1]);
            end;
       
        case 'words vs lines vs fixation',
            sequence = [zeros(blankIm,1)];
            index    = [1 2];
            for n=1:params.ncycles,
                sequence = [sequence; ...
                    ones(onBlockIm,1)*index(1); zeros(offBlockIm,1);...
                    ones(onBlockIm,1)*index(2); zeros(offBlockIm,1)];
                % only 2 so don't rotate
                %index = index([1 2]);
            end;
            
        case {'faces vs fixation','objects vs fixation','scrambled faces vs fixation'}
            sequence = [zeros(blankIm,1)];
            index    = 1;
            for n=1:params.ncycles,
                sequence = [sequence; ...
                    repmat([1;0],round(onBlockIm/2),1)*index(1); zeros(offBlockIm,1)];
            end;

        case {'faces vs fixation with 1-back','objects vs fixation with 1-back'}
            sequence = [zeros(blankIm,1)];
            index    = 1;
            for n=1:params.ncycles,
                sequence = [sequence; ...
                    repmat([1;0],round(onBlockIm/2),1)*index(1); zeros(offBlockIm,1)];
            end;
            
            % I'm assuming the rest will only have two categories. We may
            % need to be more specific later on...
        otherwise,
            sequence = [ones(blankIm,1)*2; repmat([ones(onBlockIm,1); ones(onBlockIm,1)*2],params.ncycles,1)];
    end;
    
    % load images into a three dimensional struct which we have committed
    % too... sigh
    switch params.experiment
        case 'words vs lines vs fixation',
            % separator between images 
            im.sep = 25;
            im.size = [75 225]; 
            images = zeros(im.size(1),2*im.size(2)+im.sep,length(find(sequence>0)),'uint8');
            im.dir{1} = '/Users/wandell_lab/matlab/VISTADISP/Applications2/Localizers/BMP/words/';
            im.dir{2} = '/Users/wandell_lab/matlab/VISTADISP/Applications2/Localizers/BMP/lines/';
            im.count{1} = 1;
            im.count{2} = 1;
            [im.seq{1}.left im.seq{1}.right] = textread(fullfile(im.dir{1},'rhymeExp_pairs.txt'),'%s%s');
            im.seqtotal = sequence(find(sequence>0));
            for n=1:length(im.seqtotal),
                 id = im.seqtotal(n);
                 tmp = imread(fullfile(im.dir{id},im.seq{id}.left{im.count{id}}),'BMP');
                 images(:,1:im.size(2),n) = tmp; 
                 tmp = imread(fullfile(im.dir{id},im.seq{id}.right{im.count{id}}),'BMP');
                 images(:,im.size(2)+im.sep+1:2*im.size(2)+im.sep,n) = tmp;
                 im.count{id} = im.count{id} + 1;
            end;

                     
        otherwise,    
            % find image ids in sequence (two loops because we overwrite the
            % variable otherwise..)
            for n=1:length(params.categoryImages),
                nImagesId{n} = find(sequence==n);
            end;

            % replace with individual image ids and load images
            tmpimages = [];
            start     = 0;
            for n=1:length(params.categoryImages),
                sequence(nImagesId{n}) = [1:length(nImagesId{n})] + start;
                start = start + length(nImagesId{n});
                % load or make images
                switch params.categoryImages{n}
                    case 'scrambleprevious',
                        % scamble them on the fly and reshuffle them
                        % block scramble since that seems to be the standard in
                        % this field...
                        tmpscrambled = imscramble(tmpimages(randperm(length(tmpimages))),10);
                        % make sure we have enough
                        while length(tmpscrambled) < length(nImagesId{n}),
                            tmpscrambled = [tmpscrambled imscramble(tmpimages(randperm(length(tmpimages))),10)];
                        end;
                        tmpimages = [tmpimages tmpscrambled(1:length(nImagesId{n}))];
                    case 'scrambled faces',
                        tmpimages = [tmpimages imscramble(loadCategoryImages(length(nImagesId{n}),'faces'),10)];
                        
                    otherwise,
                        % load them from the data base
                        tmpimages = [tmpimages loadCategoryImages(length(nImagesId{n}),params.categoryImages{n})];
                end;
            end;    
            % images are cell struct but display expects 3d matrix...
            % better left as cell...
            % also not all images are 120x120... sigh
            % furthermore this makes the stimulus size...
            % i.e. FIX ME
            sz = 120;
            images = zeros(sz,sz,length(tmpimages),'uint8');
            mask = makecircle(sz);
            for n=1:length(tmpimages),
                img = double(tmpimages{n});
                if size(img,1)~=sz | size(img,2)~=sz,
                    img = imresize(img,[sz sz],'bilinear');
                end;
                img = ((img-mean(img(:))).*mask)+128;
                img(img>255)=255;
                img(img<0)  =0;
                images(:,:,n) = uint8(img);
            end;
    end;    
            
    % insert 1-back's
    switch params.experiment,
        case {'faces vs fixation with 1-back','objects vs fixation with 1-back'}
            % random sequence
            nn = ceil(params.temporal.frequency*4); % on average every 4 seconds [max response time = 3 seconds]
            tmp = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
            tmp = tmp(:)+1;
            tmp = tmp(1:length(sequence));
            % force binary
            tmp(tmp>2)=2;
            tmp(tmp<1)=1;


            % change the previous display to current one, so we cannot
            % change first display in each block:
            allowedToChange = [0;0;abs(diff(sign(sequence),2))]>1;
            
            % oneback sequence
            onebackSeq = [abs(diff(tmp,2)); 0;0].*sequence.*allowedToChange;
            
            % now actually change the sequence
            ii = find(onebackSeq>0);
            sequence(ii) = sequence(ii-2);
        otherwise,
            onebackSeq =[];
    end
    
    
    % fixation
    fii = find(sequence==0);
    if ~isempty(fii),
        n = size(images,3);
        images(:,:,n+1) = params.display.backColorIndex;
        sequence(fii)   = n+1; 
    end;
end;


% fixation dot sequence
nn = params.temporal.frequency*4; % on average every 4 seconds [max response time = 3 seconds]
fixSeq = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
fixSeq = fixSeq(:)+1;
fixSeq = fixSeq(1:length(sequence));
% force binary
fixSeq(fixSeq>2)=2; 
fixSeq(fixSeq<1)=1;


% make stimulus structure for output
timing   = [0:length(sequence)-1]'.*1./params.temporal.frequency;
timing(2:2:end)   = timing(2:2:end)+0.25;

cmap     = params.display.gammaTable;
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

