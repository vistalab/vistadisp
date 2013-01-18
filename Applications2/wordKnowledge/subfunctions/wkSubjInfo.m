function params = wkSubjInfo(params)

subjectName     = 'demo';
comment         = 'none';
dlgPrompt       = {'Enter the subject name: ','Comment? '};
dlgTitle        = 'Subject Info';
resp            = inputdlg(dlgPrompt,dlgTitle,1,{subjectName,comment});

if isempty(resp), return; end % No subject info?  Quit out

params.subj = resp{1}; % Store the subject's name in stimParams