function subjectParams  = GaborGetSubjectParams
% subjectParams    = GaborGetSubjectParams;
%   get subject name & comments
%   set file name and path for saving expt data

subjectParams.name = 'demo';
subjectParams.comment = 'none';
dlgPrompt = {'Enter the subject name: ','Enter a comment: '};
dlgTitle = 'Subject Name';

resp = inputdlg(dlgPrompt,dlgTitle,1,{subjectParams.name,subjectParams.comment});

subjectParams.name          = resp{1};
subjectParams.comment       = resp{2};
subjectParams.dataSumName   = [subjectParams.name  'sum'];

return
