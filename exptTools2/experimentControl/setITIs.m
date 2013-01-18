function ITIs = setITIs(how,numITIs,meanITI,minITI,maxITI)
%
% This function will return a list of ITIs of length numITIs.  The list is
% chosen based on "how", which right now can be:
%
%       'textfile' -- read ITIs from a text file
%       'poisson' -- create from discrete poisson distribution
%       'rand' -- create using rand function (flat distribution)
%
%   ITIs = setITIs(how,numITIs,[meanITI],[minITI],[maxITI])
%
% MeanITI is meaningful for the poisson distribution.  (It is equal to
% lambda.)
%
% MaxITI and MinITI are more meaningful for the random flat distribution.
% You can also use a max and min ITI with the poisson distribution, but you
% should note that using these parameters will alter your distribution from
% a poisson and will likely also change your mean ITI.
%

switch how    
    case 'textfile'
        ITIfile = mrvSelectFile('r','txt','Select file with vertical list of ITIs',pwd);
        fid = fopen(ITIfile);
        cols = textscan(fid,'%f');
        fclose(fid);
        ITIs=cols{1};
        
    case 'poisson'
        lambda = meanITI;  % poisson has equal mean and variance, which is equal to lambda
        ITIs = poissrnd(lambda,1,numITIs);
        done = 0;
        
        % replace numbers below min and above max until they are within
        % range -- note that this could majorly skew the distribution
        if notDefined('minITI'), minITI=min(ITIs); end  % if no min or max, just be done
        if notDefined('maxITI'), maxITI=max(ITIs); end
        while done==0
            toosmall = find(ITIs<minITI);
            toobig = find(ITIs>maxITI);
            ITIs(toosmall) = ITIs(toosmall) + poissrnd(lambda);
            ITIs(toobig) = ITIs(toobig) - poissrnd(lambda);
            if isempty(toosmall) && isempty(toobig)
                done = 1;
            end
        end
        
    case 'rand'
        ITIs = rand(1,numITIs)*(maxITI-minITI)+minITI;  % random numbers between minITI and maxITI
        
        
end