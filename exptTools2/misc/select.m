function [i, ofreq] = select(ifreq)
% SELECT make a random selection from given relative frequencies
% [i, ofreq] = SELECT (ifreq)
% ifreq     a vector of relative frequencies (all must be 0 or positive)
% i         index of the selected element
% ofreq     frequencies with ifreq[i] decremented
%
% To the best of my knowledge, Charles E. Wright (cewright@uci.edu) wrote
% this function. - RFB

if any(ifreq < 0)
    display('Warning: Select requires all entries in the relative frequency vector to be >= 0');
    i=0;
    return
end
len = length(ifreq);
cs = cumsum(ifreq);
if cs(len) <= 0
    display('Warning: Select requires a positive entry in the relative frequency vector');
    i=0;
    return
end
rn = rand * cs(len);
indices = 1:len;
i = min(indices(rn <= cs));
if nargout == 2
    ifreq(i) = ifreq(i) - 1;
    ofreq = ifreq;
end
  