function [params] = cocSetTimingParams(params)

params.framePeriod          = params.tr*params.interleaves;
params.duration.onBlock     = params.period;
params.duration.offBlock    = 0;
params.ncycles              = params.numCycles;
params.duration.scan        = params.ncycles*params.duration.onBlock.*2;
params.framePeriod          = params.tr;


return