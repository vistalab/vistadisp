function [status, pupil, horiz, vert, time] = getEyePos(hostName)
%
%
%

if(~exist('hostName','var') || isempty(hostName))
    hostName = 'gray';
end

numVals = 5;

numBytes = 36*60;
con = pnetTrack('tcpconnect',hostName,4000);
pnetTrack(con,'printf','s\n');
data = pnetTrack(con,'read',numBytes);
pnetTrack(con,'close');
d = sscanf(data,'%g %g %g %g %d %d\n',inf); 

if(numel(d)==6*60)
    d = reshape(d,6,60);
%     %last = mean(d(:,end-numVals+1:end),2);
%     last = d(:,1);
%     status = 1;
%     pupil = last(5);
%     horiz = last(1) - last(3);
%     vert = last(2) - last(4);
    status = 1;
    pupil = d(5,:);
    horiz = d(1,:)-d(3,:);
    vert = d(2,:)-d(4,:);
    time = d(6,:);
else
    status = 0;
    pupil = 0;
    horiz = 0;
    vert = 0;
end

return;



