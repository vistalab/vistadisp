function stim = cornsweetAddCurvature(params, stim)

h = params.screenHeight;

c = round(params.curvatureAmp * h);

edgeShift = c - round(abs(sin((1:h) *pi/h))*c);
for row = 1:h;
    stim.realEdge(row,:) = shift(stim.realEdge(row,:), edgeShift(row));
    stim.cocEdge(row,:)  = shift(stim.cocEdge(row,:),  edgeShift(row));
    stim.mixture(row,:)  = shift(stim.mixture(row,:),  edgeShift(row));
end

end