function stim = cornsweet1Dto2D(params, stim)

stim.realEdge = ones(params.screenHeight,1) * stim.y ;
stim.cocEdge  = ones(params.screenHeight,1) * stim.yFiltered;
stim.mixture  = ones(params.screenHeight,1) * stim.yMixture;

end