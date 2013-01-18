function sformatted = stringFormat(s)
% Converts s to a standard string format for rgcParameters set/get calls
%
%    sformatted = stringFormat(s)
%
% The string is sent to lower case and spaces are removed.
%
% ex:
%     stringFormat('Spatial sampling Rate')

if ~ischar(s), error('s has to be a string'); end

% Lower case
sformatted = lower(s);

% Remove spaces
sformatted = strrep(sformatted,' ','');

return;


