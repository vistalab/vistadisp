function data = etCheckEyes(duration)

[status, pupil, horiz, vert, time] = getEyePos();

timeCutoff      = duration; % seconds
presentTime     = time(60);
timeStart       = presentTime-(timeCutoff*1000); % convert cutoff to ms, subtract
keepTimes       = find(time>=timeStart);
horiz           = horiz(keepTimes); vert = vert(keepTimes); time = time(keepTimes); pupil = pupil(keepTimes);

data.horiz      = horiz;
data.vert       = vert;
data.time       = time;
data.pupil      = pupil;