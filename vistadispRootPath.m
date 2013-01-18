function rootPath=vistadispRootPath()
% Return the path to the root vistadisp directory
%
% This function must reside in the directory at the base of the vistadisp
% directory structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(vistadispRootPath,'Applications2')

rootPath=which('vistadispRootPath');

rootPath=fileparts(rootPath);

return
