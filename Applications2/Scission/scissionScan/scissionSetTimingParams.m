function [params] = scissionSetTimingParams(params)

params.ncycles = params.numCycles;
params.duration.scan = params.ncycles * params.period;
params.framePeriod = params.tr;

return