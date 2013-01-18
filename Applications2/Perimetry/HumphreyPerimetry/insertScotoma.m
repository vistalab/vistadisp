function stimulus = insertScotoma(stimulus,params,scotoma_params);
% insertScotoma - make artificial scotoma in these stimuli
%
% stim=insertScotoma(stim,params,scotoma_params);
%
% 2007/01 SOD: wrote it.

if nargin < 3,
    help(mfilename);
    return;
end;

for n=1:numel(stimulus.images),
    stim    = stimulus.images{n};
    scotoma = makeArtificialScotoma(size(stim,1),params.radius.*2,scotoma_params);
    newfix  = makeArtificialScotoma(size(stim,1),params.radius.*2,[scotoma_params(1:2) .25])==0;
    for ii=1:size(stim,3),
        tmp = (double(stim(:,:,ii))-128).*scotoma+128;
        tmp(newfix) = 0;
        stim(:,:,ii) = uint8(tmp);
    end;
    stimulus.images{n} = stim;
end;

return;

        