function oldGamma = setGamma(sn, gt)
%
% setGamma([screenNumber], [gt])
%

AssertOpenGL;
if(~exist('gt','var') | isempty(gt) | size(gt,1)~=256 | size(gt,2)~=3)
    % Set a linear gamma
    gt = repmat(linspace(0,1,256)',1,3);
end
if(~exist('sn','var') | isempty(sn))
    sn = max(Screen('Screens'));
end
oldGamma = Screen('LoadNormalizedGammaTable', sn, gt);
end