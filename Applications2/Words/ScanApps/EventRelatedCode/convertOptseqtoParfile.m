function VistaParfilePath = convertOptseqtoParfile(optseqParfilePath)
%
% This function will read in a parfile created by optseq2, and write out a
% new parfile that is in the format used for mrVista.
%
% input parfilePath is path to optseq parfile
% output parfilePath is path to newly created mrVista parfile
%
%   VistaParfilePath = convertOptseqtoParfile(optseqParfilePath)
%
%  written by amr Feb 6, 2009
%

if notDefined('optseqParfilePath')
    optseqParfilePath = mrvSelectFile('r','par','Select parfile to convert...',pwd);
end

fid = fopen(optseqParfilePath);
cols = textscan(fid,'%f%f%f%f%s');  % onset,condNum,duration,??,label
fclose(fid);

% Par needs fields onset and cond, and can use label as well
par.onset=cols{1};
par.cond=cols{2};
par.label=cols{5};
par.stimDur=cols{3};  % vista doesn't use this, but let's get it out anyway

%% Replace "NULL" label from optseq with "Fix" label for mrVista
fixations = strfind(par.label,'NULL');
% there must be some way of getting around this for loop
for ii = 1:length(fixations)
    if ~isempty(cell2mat((fixations(ii))))  % means there's a null (stupid matlab thing to get around requires cell2mat)
        par.label{ii} = 'Fix';
    end
end

%% Write out the new parfile
[pathparts,filename] = fileparts(optseqParfilePath);
VistaParfilePath = fullfile(pathparts,[filename '_vista.par']);
writeParfile(par,VistaParfilePath);

return
        


