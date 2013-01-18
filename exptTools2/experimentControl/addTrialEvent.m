function trial = addTrialEvent(varargin)
% trial = addTrialEvent(display, trial, eventType, ...
%				fieldName, fieldValue, [fieldName, fieldValue...])
%
% For example, if you want to add an ISI to a trial, showing a
% blank stimulus called blankStimulus for half a second, you would call
%
%	trial = addTrialEvent(display, trial, 'ISIEvent', ...
%				'stimulus', blankStimulus, 'duration', 0.5);
%
% To initialize a trial with its first event, use [] as the second
% argument ("trial").

if nargin<4
    help(mfilename);
	error('You have to have at least four arguments (see help addTrialEvent)');
end

display     = varargin{1};
trial       = varargin{2};
eventType   = varargin{3};

material = [];				% Necessary for setfield to work correctly

if nargin < 5   % argument 4 of form: material (complete structure)

    material = varargin{4};	
	
else   % arguments 4+ were of form: fieldName, fieldValue, fieldName, fieldValue...

	argNum = 4;
	while (argNum<nargin)
		
		fieldName  = varargin{argNum};
		fieldValue = varargin{argNum+1};
		
        material.(fieldName) = fieldValue;

		argNum = argNum+2;
	end
end

eventNum = size(trial,1)+1;

trial{eventNum,1} = eventType;
trial{eventNum,2} = material;
