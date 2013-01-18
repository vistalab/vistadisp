function [images] = scissionMultipleFrames(params, stimulus, display, showProgressFlag)
% make images for scission stimuli
% Mainfunction of "scissionMultipleFrames" is changing periodical filter
% parameter for one-short-Single-cycle (Blocklength / params.stimulus.NumOfDevision) 
% This code includes "scissionSingleCycle", which is mainpart and making image matrices.
% Of course, this is also everlsting ß version.

if isfield(params, 'showProgessFlag'),
    showProgressFlag = params.showProgess;
end


NumOfDevision        = stimulus.NumOfDevision;
duration.stimframe   = stimulus.stimframe;
NumImageSet          = NumOfDevision * stimulus.NumOfReptOneCycle;
stimulus.type        = params.type;
stimulus.NoiseType   = params.stimulus.NoiseType;
stimulus.CViolation  = params.stimulus.WithoutContrastViolation;

stimulus.DesWidth   = params.stimulus.DesWidth;
stimulus.DesGray   = params.stimulus.DesGray;
stimulus.Filtering   = params.stimulus.Filtering;

if showProgressFlag, fprintf('[%s]:Creating %d imageSet:\n',mfilename,NumImageSet); drawnow; end

%%
switch lower(params.type)    
    case {'surroundrotation','centsurroundrotation'}
        
        RotDeg = 180 / NumOfDevision;
        
        for ii = 1:NumImageSet;

            stimulus.RotDeg = ( ii - 1 ) * RotDeg;    
            im{ii}          = scissionSingleCycle(stimulus, display, showProgressFlag);
            
            if showProgressFlag, fprintf('[%s]:Done %d imageSet:\n',mfilename,ii); drawnow; end

        end

    case {'filtersizechange'}
        
        if     params.stimulus.HowLongScissionCycle == 0
       % in case of 1/4 scission cycle               
               stimulus.whichDurationLongerSvsN  = params.stimulus.whichDurationLongerSvsN;
               %this parameter doesn't matter, just for deciding which
               %change first (center or surround).                           
                              
               stimulus.HowManyTimesFiltSize     = params.stimulus.HowManyTimesFiltSize;               
        
                       for ii = 1:NumImageSet;
                           
                           if stimulus.whichDurationLongerSvsN == 0
                            tmp = 45 + ( ii - 1 ) * 90;
                            tmp = deg2rad(tmp);
                            stimulus.CfiltOn = - sin(tmp) > 0;                               
                            stimulus.SfiltOn = - cos(tmp) > 0;
                            
                            im{ii} = scissionSingleCycle(stimulus, display, showProgressFlag);    

                            if showProgressFlag, fprintf('[%s]:Done %d imageSet:\n',mfilename,ii); drawnow; end
                            
                           elseif stimulus.whichDurationLongerSvsN == 1
                            tmp = 45 + ( ii - 1 ) * 90;
                            tmp = deg2rad(tmp);
                            stimulus.CfiltOn = - cos(tmp) > 0;
                            stimulus.SfiltOn = - sin(tmp) > 0;                               
                            
                            im{ii} = scissionSingleCycle(stimulus, display, showProgressFlag);
                            
                            if showProgressFlag, fprintf('[%s]:Done %d imageSet:\n',mfilename,ii); drawnow; end
                               
                           end
                           
                       end
        
        elseif params.stimulus.HowLongScissionCycle == 1
       % in case of 1/2 scission cycle 
            
               stimulus.whichDurationLongerSvsN  = params.stimulus.whichDurationLongerSvsN;
               stimulus.HowManyTimesFiltSize     = params.stimulus.HowManyTimesFiltSize;       
               
                for ii = 1:NumImageSet;
                    
                    if     stimulus.whichDurationLongerSvsN == 0
                        tmp = 45 + ( ii - 1 ) * 90;
                        tmp = deg2rad(tmp);
                        stimulus.CfiltOn = - sin(tmp * 2) > 0;                               
                        stimulus.SfiltOn = - cos(tmp)     > 0;
                      
                        im{ii} = scissionSingleCycle(stimulus, display, showProgressFlag);    

                    if showProgressFlag, fprintf('[%s]:Done %d imageSet:\n',mfilename,ii); drawnow; end
                    
                    elseif stimulus.whichDurationLongerSvsN == 1
                        tmp = 45 + ( ii - 1 ) * 90;
                        tmp = deg2rad(tmp);
                        stimulus.CfiltOn = - cos(tmp)     > 0;
                        stimulus.SfiltOn = - sin(tmp * 2) > 0;                               
                        
                        im{ii} = scissionSingleCycle(stimulus, display, showProgressFlag);
                        
                    if showProgressFlag, fprintf('[%s]:Done %d imageSet:\n',mfilename,ii); drawnow; end   
                    
                    end
                    
                end       
              
        else error('params.stimulus.whichDurationLongerSvsN should be one or zero (scissionSetStimulusParams.m)')
            
        end
                    
    case {'annulus'}
            for ii = 1:NumImageSet/2;
                [im{ii},misc]  = scissionSingleCycle(stimulus, display, showProgressFlag);
                        if showProgressFlag, fprintf('[%s]:Done %d imageSet:\n',mfilename,ii); drawnow; end
            end
            disp('doubling...')            
            
            CenterX = misc.m/2; CenterY = misc.n/2;
            [screenx, screeny] = meshgrid(1:misc.m, 1:misc.n);
            AnnulusCenter = sqrt((screenx - CenterX).^2 + (screeny - CenterY).^2) < misc.targetRadius * (1-stimulus.DesWidth);               
            Annulus = misc.targetMask & ~AnnulusCenter;
                       
            tmp = size(im,2);
                for ii = 1:tmp
                    for ij = 1: size(im{ii},3)                        
                      im{ii+tmp}(:,:,ij) = uint8(double(im{ii}(:,:,ij)) .* (1 - Annulus) +  Annulus * stimulus.DesGray);
                    end 
                end
                
            Im = im;
                
            tmp = [[1:2:size(im,2)] [2:2:size(im,2)]];
            for ii = 1:size(im,2)
                im{tmp(ii)} = Im{ii};
            end
            
                            
    otherwise
end
%% structure to matrix (this way is pretty fool, so I have to fix...)

     ImNumOfOneCycle = (size(im{1},3));

     images = zeros(size(im{1},1), size(im{1},2), ImNumOfOneCycle * NumOfDevision, 'uint8' );

    for ii = 1:NumImageSet;

        for ij  = 1:ImNumOfOneCycle;

            tmp = (ii-1) * ImNumOfOneCycle + ij;
            images(:,:,tmp) = im{ii}(:,:,ij);

        end
    end
    
return


% If you want to add mean luminance image at the end of image matrices.
%
% minCmapVal = min([display.stimRgbRange]);
% maxCmapVal = max([display.stimRgbRange]);
% im = zeros(size(images,1), size(images,2), size(images,3) + 1, 'uint8' );
% im (:,:,end-1) = images(:,:,:);
% im             = im(:,:,end).*0+minCmapVal+ceil((maxCmapVal-minCmapVal)./2);
% images = im;