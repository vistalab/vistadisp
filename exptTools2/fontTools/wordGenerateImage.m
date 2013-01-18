function [img params] = wordGenerateImage(display,letters,wordInput,varargin)
% img = wordGenerateImage(display,letters,wordInput,varargin)
%
% Purpose
% Given a properly formatted series of letter images, this function will
% properly scale and arrange them at the desired spacing for output as an
% image.
%
% Input
%   display - Generated with loadDisplayParams (info specific to the
%             monitor you're using)
%   letters - 2xn cell array composed of n matrices in row 1, each
%             containing a letter image corresponding to one of the n letter strings
%             contained in row 2 (letter images of the format 0 =
%             background, 1 = body of letter)
%   wordInput - String with desired word to render
%   varargin - Series of options as follows...
%       'Spacing' - Spacing between letters
%                   [DEFAULT: 1.16]
%       'SpacingMetric' - Spacing metric ('pixels', 'degrees', 'xWidth' - multiple of the width of the letter x)
%                         [DEFAULT: 'xWidth']
%       'xHeight' - Height of the letter x in the font
%                   [DEFAULT: No change to the size of the font]
%       'xHeightMetric' - Metric for specifying the height of the letter x
%                         ('pixels, 'degrees')
%                         [DEFAULT: 'degrees']
%       'Method' - Related to resizing process; See imresize function
%                  [DEFAULT: 'nearest']
%       'AntiAliasing' - Related to resizing process; See imresize function
%                        [DEFAULT: false]
%       'Dither' - Related to resizing process; See imresize function
%                  [DEFAULT: true]
%       'Colormap' - Related to resizing process; See imresize function
%                    [DEFAULT: 'original']
%       'Recenter' - Added in to see if this affected anything - centroid
%                    of the letter is computed and its image within the box recentered.
%                    Doesn't seem to make much of a difference.
%                    [DEFAULT: false]
%       'adjustImSize' - How big of a box should the words be in?
%                        [DEFAULT: conforms to size of letter stim]
%
% Output
%   img - Image of the word (of the format 0 = background, 1 = body of word)
%   params - Structure containing relevant input and output information
%       .input - See above for explanations of inputs reported
%           .wordInput
%           .spacing
%           .spacingMetric
%           .xHeight
%           .xHeightMetric
%           .recenter
%           .imresize
%               .method
%               .antiAliasing
%               .dither
%               .colormap
%       .output
%           .numLetters - Number of letters in word
%           .xWidth - Width of x in font
%               .pix
%               .deg
%           .xHeight - Height of x in font (check against degrees input)
%               .pix
%               .deg
%           .letterImgHeight - Height of box containing letter
%               .pix
%           .letterImgWidth - Width of box containing letter
%               .pix
%           .pixelSpacing - Spacing in pixels between letters
%           .imgWidth - Width of final box containing word
%               .pix
%           .imgHeight - Height of final box containing word
%               .pix
%           .wordWidth - Width of word, furthest edge to edge
%               .pix
%               .deg
%           .wordHeight - Height of word, furthest edge to edge
%               .pix
%               .deg
%
% Subfunctions designed for this program...
%   scaleLetters
%   spaceLetters
%   placeLetters
%   centerLetter
%   adjustImSize
%
% RFB 2009 [renobowen@gmail.com]

    %% Defaults
    % Store relevant inputs in params
    params.input.wordInput = wordInput;
    % Word rendering parameters
    params.input.spacing = 1.16;
    params.input.spacingMetric = 'xWidth';
    params.input.xHeight = [];
    params.input.xHeightMetric = 'degrees';
    params.input.recenter = false;
    params.input.adjustImSize = 0;
    % Imresize Parameters
    params.input.imresize.method = 'nearest';
    params.input.imresize.antiAliasing = false;
    params.input.imresize.dither = true;
    params.input.imresize.colormap = 'original';

    %% Parse options
    for ii = 1:2:length(varargin)
        switch lower(varargin{ii})
            case 'spacing', params.input.spacing = varargin{ii+1};
            case 'spacingmetric', params.input.spacingMetric = varargin{ii+1};
            case 'xheight', params.input.xHeight = varargin{ii+1};
            case 'xheightmetric',  params.input.xHeightMetric = varargin{ii+1};
            case 'method', params.input.imresize.method = varargin{ii+1};
            case 'antialiasing', params.input.imresize.antiAliasing = varargin{ii+1};
            case 'dither', params.input.imresize.dither = varargin{ii+1};
            case 'colormap', params.input.imresize.colormap = varargin{ii+1};
            case 'recenter', params.input.recenter = varargin{ii+1};
            case 'adjustimsize', params.input.adjustImSize = varargin{ii+1};
        end
    end

    %% Scale, space, and arrange letters into new image

    [wordLetters params]    = scaleLetters(display,letters,params);
    [params]                = spaceLetters(params);
    [img params]            = placeLetters(wordLetters,params);
    [img]                   = adjustImSize(img,params);

    %% Compute height and width of word in degrees
    params.output.wordWidth.deg     = pix2angle(display,params.output.wordWidth.pix);
    params.output.wordHeight.deg    = pix2angle(display,params.output.wordHeight.pix);

end

function [wordLetters params] = scaleLetters(display,letters,params)
    % word = wordScaleLetters(display,letters,params)
    % [NOTE: Subfunction of wordGenerateImage.m]
    %
    % Purpose
    %   Scale size of letters if necessary prior to insertion within new image.
    %
    % Input - See wordGenerateImage.m
    %   display
    %   letters
    %   params
    %
    % Output
    %   wordLetters - Images of the particular letters you need to render the
    %                 word, scaled if necessary.
    %   params - See wordGenerateImage.m
    %
    % RFB 2009 [renobowen@gmail.com]

    %% Determine scaling factors necessary to make letters of a given x-height
    % Locate letter 'x' in letters array
    [xRow xCol] = find(strcmp('x',letters));

    % Determine number of letters in wordInput
    params.output.numLetters = length(params.input.wordInput);

    if ~isempty(params.input.xHeight) % Custom x-height specified
        % Determine default x-height of letter as it comes in the array
        defaultXHeightPix = find(sum(letters{1,xCol},2),1,'last') - find(sum(letters{1,xCol},2),1,'first');
            % This computation involves summing across the columns of the image,
            % giving you one column containing the counts of pixels in each row of
            % the x image.  The last row containing a value represents the bottom
            % of the image, and the first the top.  Subtracting the two gives you
            % the height of the letter 'x'.

        % Compute ratio of x-height to height of letter image (preserve this)
        xHeightRatio = defaultXHeightPix/size(letters{1,xCol},1);

        switch lower(params.input.xHeightMetric)
            case 'degrees'
                % Target x-height in pixels, converted from degrees of visual angle
                targetXHeightPix = angle2pix(display,params.input.xHeight);
            case 'pixels'
                % Target x-height in pixels, as given directly by the user
                targetXHeightPix = params.input.xHeight;
        end

        % Target box size is scaled based on the ratio to be preserved
        targetBoxSize = targetXHeightPix/xHeightRatio;

        % Figure out how many pixels we need to add (or subtract) when resizing
        increaseByPix = targetBoxSize - size(letters{1,xCol},1);

        %% Generate a variable containing the sequence of scaled letters
        % Preallocate space in cell array for letters
        wordLetters = cell(1,params.output.numLetters);

        % Loop over letter positions, pulling out each letter and scaling the size
        for letterPosition = 1:params.output.numLetters
          [row col] = find(strcmp(params.input.wordInput(letterPosition),letters));
          if params.input.recenter
              [letters{1,col} centers] = centerLetter(letters{1,col});
              params.output.centering{1} = centers; % First entry is centroid, second entry is half width
          end
          wordLetters{letterPosition} = imresize(letters{1,col}, ...
              'OutputSize',[size(letters{1,col},1)+increaseByPix NaN], ...
              'Antialiasing',params.input.imresize.antiAliasing, ...
              'Colormap',params.input.imresize.colormap, ...
              'Dither',params.input.imresize.dither, ...
              'Method',params.input.imresize.method);
        end

        % Pull out an x for computations about final font size
        xFinal = imresize(letters{1,xCol}, ...
            'OutputSize',[size(letters{1,xCol},1)+increaseByPix NaN], ...
            'Antialiasing',params.input.imresize.antiAliasing, ...
            'Colormap',params.input.imresize.colormap, ...
            'Dither',params.input.imresize.dither, ...
            'Method',params.input.imresize.method);

    else % Custom x-height not specified
        %% Generate a variable containing the sequence of unscaled letters
        % Preallocate space in cell array for letters
        wordLetters = cell(1,params.output.numLetters);

        % Loop over letter positions, pulling out each letter
        for letterPosition = 1:params.output.numLetters
          [row col] = find(strcmp(params.input.wordInput(letterPosition),letters));
          if params.input.recenter
              [letters{1,col} centers] = centerLetter(letters{1,col});
              params.output.centering{1} = centers; % First entry is centroid, second entry is half width
          end
          wordLetters{letterPosition} = letters{1,col};
        end

        % Pull out an x for computations about final font size
        xFinal = letters{1,xCol};
    end

    %% Parameters about the font following our computations
    % Pixel size of x in final font size
    params.output.xWidth.pix        = find(sum(xFinal,1),1,'last') - find(sum(xFinal,1),1,'first');
    params.output.xHeight.pix       = find(sum(xFinal,2),1,'last') - find(sum(xFinal,2),1,'first');
        % Explanation of these computations available under 'defaultXHeightPix'
    % Degree size of x in final font size
    params.output.xWidth.deg        = pix2angle(display,params.output.xWidth.pix);
    params.output.xHeight.deg       = pix2angle(display,params.output.xHeight.pix);
    % Store size of actual letter box (this should be the same for every
    % letter, as well - useful for later computations
    params.output.letterImgHeight.pix     = size(xFinal,1);
    params.output.letterImgWidth.pix      = size(xFinal,2);

end

function params = spaceLetters(params)
    % params = spaceLetters(params)
    % [NOTE: Subfunction of wordGenerateImage.m]
    %
    % Purpose
    %   Determine spacing for letter images.
    %
    % Input - See wordGenerateImage.m
    %   params
    %
    % Output - See wordGenerateImage.m
    %   params
    %
    % RFB 2009 [renobowen@gmail.com]

    switch lower(params.input.spacingMetric)
        case 'degrees'
            % If the metric is degrees, make the conversion
            params.output.pixelSpacing = angle2pix(display,params.input.spacing);
        case 'xwidth'
            % If the metric is x-width, spacing is a multiplier
            params.output.pixelSpacing = params.output.xWidth.pix*params.input.spacing;
        case 'pixels'
            % If the metric is pixels, no computation is needed
            params.output.pixelSpacing = params.input.spacing;
    end

end

function [img params] = placeLetters(wordLetters,params)
    % img = placeLetters(wordLetters,params)
    % [NOTE: Subfunction of wordGenerateImage.m]
    %
    % Purpose
    %   Insert letter images into new image at predetermined spacing.
    %
    % Input - See wordGenerateImage.m
    %   wordLetters - See wordScaleLetters.m
    %   params
    %
    % Output - See wordGenerateImage.m
    %   img
    %   params
    %
    % RFB 2009 [renobowen@gmail.com]


    % Determine width of new image to be generated based on this box size
    params.output.imgWidth.pix = round(params.output.pixelSpacing*(params.output.numLetters-1)+params.output.letterImgWidth.pix);

    % Height of new image based on this box size
    params.output.imgHeight.pix = params.output.letterImgHeight.pix;

    % Determine letter positions within the box
    letterHorizPosStart   = round(1+params.output.pixelSpacing*(0:params.output.numLetters-1)); 
    letterHorizPosEnd     = letterHorizPosStart+params.output.letterImgWidth.pix-1;
    letterVertPosStart    = 1+zeros(1,params.output.numLetters);
    letterVertPosEnd      = letterVertPosStart+params.output.letterImgHeight.pix-1;

    % Generate blank template to fill in all of the letters
    img = zeros(params.output.imgHeight.pix,params.output.imgWidth.pix);

    % Loop over all of the letter positions and fill in contours
    for letterPosition = 1:params.output.numLetters
      temp = img(letterVertPosStart(letterPosition):letterVertPosEnd(letterPosition),   ...
        letterHorizPosStart(letterPosition):letterHorizPosEnd(letterPosition));
      temp(temp==0) = wordLetters{letterPosition}(temp==0);
      img(letterVertPosStart(letterPosition):letterVertPosEnd(letterPosition),          ...
        letterHorizPosStart(letterPosition):letterHorizPosEnd(letterPosition)) = temp;
    end

    % Compute height and width of word in pixels
    params.output.wordWidth.pix     = find(sum(img,1),1,'last') - find(sum(img,1),1,'first');
    params.output.wordHeight.pix    = find(sum(img,2),1,'last') - find(sum(img,2),1,'first');
    
end

function [letter centers] = centerLetter(letter)
    % [letter centers] = centerLetter(letter)
    % [NOTE: Subfunction of wordGenerateImage.m]
    %
    % Purpose
    %   Center a letter within a text box based upon its centroid.
    %
    % Input - See wordGenerateImage.m
    %   letter - A single letter image.
    %
    % Output - See wordGenerateImage.m
    %   letter - Recentered single letter image.
    %   centers - Contains centroid center position, and position of half the
    %             image (specifically for checking to ensure the procedure was largely
    %             successful).
    %
    % RFB 2009 [renobowen@gmail.com]

    s = regionprops(letter,'Centroid');
    horizCenter = s.Centroid(1);
    boxWidth = size(letter,2);
    correction = round(horizCenter - (boxWidth/2));
    newLetter = zeros(size(letter));
    if sign(correction)==1
        newLetter(:,1:(boxWidth-correction)) = letter(:,(correction+1):boxWidth);
    elseif sign(correction)==-1
        correction = correction*(-1);
        newLetter(:,(correction+1):boxWidth) = letter(:,1:(boxWidth-correction));
    end
    s = regionprops(newLetter,'Centroid');
    centers = round([s.Centroid(1) boxWidth/2]);
    
end

function [newImage] = adjustImSize(img,params)
    % [newImage] = adjustImSize(img,params)
    % [NOTE: Subfunction of wordGenerateImage.m]
    %
    % Purpose
    %   Adjust size of image containing letters.
    %
    % Input - See wordGenerateImage.m
    %   img
    %   params
    %
    % Output - See wordGenerateImage.m
    %   newImage - Image resized to specifications of params.stimSizePix
    %
    % RFB 2009 [renobowen@gmail.com]
    
    newImage = img;
    if params.input.adjustImSize~=0
        try
            newImage = zeros(params.input.adjustImSize);
            r = CenterRect([1 1 size(img)],[1 1 params.input.adjustImSize]); 
            newImage(r(1):r(3),r(2):r(4)) = img; 
        catch
            display('Cannot fit word image into specified imSize - pick a larger set of parameters!');
            rethrow(lasterror);
        end
    end

end