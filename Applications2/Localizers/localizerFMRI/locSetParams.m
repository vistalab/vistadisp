function params = locSetParams(varargin)
% Set parameters for localizer fMRI localizer scan. Input argumenta should
% come in pairs ('fieldname', val)
%
% params = locSetParams(varargin)
%
% ***** Parameters that can be set*************************************
% Stimulus (params.stim.X)
%   baseDir             str; category dirs are relative to this.
%                           default = fullfile(vistastimRootPath,localizers);
%   circularAperture    boolean; if true, images are cropped so to be shown
%                           through a circular aperture. the diamter of the 
%                           aperture is the minimum edge length of the
%                           rectangular images.
%                           default = false
%   blankcolor          gray value [0 255]. [can it be an rgb triplet?]
%                           default = 128;
%   blockLength         scalar (seconds). [should we allow for a vector?]
%                           default = 12;
%   stimLength          scalar (seconds). time each image is displayed.
%                           default = 0.4
%   ISItime             scalar (seconds). duration of blank screen between stimuli.
%                           default = 0.1;
%   fixLength           scalar or vector (seconds). if a vector, must be
%                       length numBlocks + 1.
%                           default = 12;
%   blockDirectory      cell array of paths to stimuli
%                           default = []
%   conditionNames      cell array of names of block types
%                           default = []
%   blockOrder          vector of indices to block types, not including
%                       fixation. For example [1 2 3 3 2 1].
%
% Scan (params.scan.X)
%   instructions        str; 
%                           default = 'Please press button when fixation dot changes color.';
%   subjInitials        str.
%                           if blank, user gets queried with dialog.
%   countdownsecs       scalar
%                           default = 0;
%   dispName            str. should correspond to one of getDisplaysList
%                           default = 'cni_lcd'
%
% ***** Derived parameters *************************************
%   params.stim.stimsPerBlock
%   params.stim.numBlocks
%   params.logfile
%   params.scan.runPriority
%   params.scan.startScan
%
% JW, 1/2012


%% Default parameters
params = locDefaultParams;

%% User inputted parameters
if ~isempty(varargin)
    
    for ii = 1:2:length(varargin)
        fieldName = stringFormat(varargin{ii});

        switch fieldName
            % ******* Stimuli *********************
            case {'circularaperture' 'aperture' 'circaperture' 'circmask' 'mask' 'circle'}
                params.stim.circularAperture = varargin{ii+1};
            case {'blankcolor' 'bgcolor' 'backgroundcolor' 'backcolor'}
                params.stim.blankColor       = varargin{ii+1};
            case {'stimlength' 'stimdur' 'stimtime' 'stimssecs'}
                params.stim.stimLength       = varargin{ii+1};
            case {'isilength' 'isidur' 'isitime' 'isisecs'}
                params.stim.ISItime          = varargin{ii+1};
            case {'fixlength' 'fixdur' 'fixtime' 'fixsecs' 'fixs' 'fixseconds'}
                params.stim.fixLength        = varargin{ii+1};
            case {'blocklength' 'blockdur' 'blocktime' 'blocksecs' 'blocks' 'blockseconds'}
                params.stim.blockLength      = varargin{ii+1};
            case {'basedir' 'basedirectory' 'rootdirectory' 'rootdir'}
                params.stim.baseDir          = varargin{ii+1};
            case {'blockdirectory' 'blockdir' 'stimulusdirectory' 'stimdir' 'stimdirs' 'conddirs' 'conditiondirs'}
                params.stim.blockDirs        = varargin{ii+1};
            case {'conditionnames' 'condnames' 'conditions' 'stimtypes'}
                params.stim.condNames        = varargin{ii+1};
            case {'blockorder' 'blocksequence' 'conditionorder' 'conditionsequence'}
                params.stim.blockOrder       = varargin{ii+1};
                
                % ******* Scan *********************
            case {'instructions'}
                params.scan.instructions         = varargin{ii+1};
            case {'subjinitials' 'subjectinitials' 'subject' 'initials' 'subjid' 'subjectid'}
                params.scan.subjInitials         = varargin{ii+1};
            case {'countdownsecs' 'countdown' 'countdowntime' 'countdowns'}
                params.scan.countdownsecs        = varargin{ii+1};
            case {'triggertype' 'trigger' 'scantrigger'}
                params.scan.triggerType          = varargin{ii+1};
            case {'disp' 'display' 'displayname' 'cal' 'calibration' 'screencal' 'screencalibration'}
                params.scan.dispName             = varargin{ii+1};
            case {'modality'}
                params.modality                  = varargin{ii+1}; 

                % ******
            otherwise
                error('Unknown input variable %s', varargin{ii})
        end
    end
end
%% Parameter check
% stims per block must be an integer
stimsPerBlock = params.stim.blockLength / ...
    (params.stim.stimLength+params.stim.ISItime);

if abs(round(stimsPerBlock) - stimsPerBlock) > 1000 * eps
    sprintf('%s', 'Your stimuli do not divide evenly into your block length.  Please change the parameters.')
    return
end

% subject initials
if ~checkfields(params, 'scan', 'subjInitials')
    params.scan.subjInitials = input('Subject Initials:  ','s');
end


%% Derived parameters
params.stim.stimsPerBlock = round(stimsPerBlock);
params.stim.numBlocks     = numel(params.stim.blockOrder);
if isscalar(params.stim.fixLength),
    params.stim.fixLength = repmat(params.stim.fixLength, 1, ...
        params.stim.numBlocks + 1);
end

% This is the file you will save all variables to
params.logFile = fullfile(params.stim.baseDir,'data',...
    [params.scan.subjInitials '_' datestr(now,'dd.mm.yyyy.HH.MM') '_' ...
    'savedVariables.mat']);

% Something PTB-related. Does it mean anything in the modern version of
% PTB?
params.scan.runPriority  = 9;

% What is this for? 
params.scan.startScan    = 0;

%%
return

