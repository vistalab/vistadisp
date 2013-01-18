function [stairParams n] = ewBalanceOrder(stairParams,subj,lap)
% Change sizes presented based on subject number and session number

ind = stairParams.ind-(stairParams.measuredSizes*(lap-1));
refMat(:,:,1) =    [1 2 3 4;
                    4 3 2 1];
refMat(:,:,2) =    [4 3 2 1;
                    1 2 3 4];
n = refMat(mod(subj.sess,2)+1,ind,(mod(subj.num,2)+1));
for i=1:size(stairParams.curStairVarsALL,1)
    stairParams.curStairVars{i,1} = stairParams.curStairVarsALL{i,1};
    stairParams.curStairVars{i,2} = stairParams.curStairVarsALL{i,2} ...
        (n:(stairParams.measuredSizes):(stairParams.nStairs));
end
stairParams.adjustableVarStart = repmat(1, 1, stairParams.measuredEcc);