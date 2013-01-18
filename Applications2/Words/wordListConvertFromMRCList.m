% Script to convert list from MRC Psycholinguistic Database to a text file
%
% First go to http://www.psy.uwa.edu.au/MRCDataBase/uwa_mrc.htm
% to get your list
%
% Now it's all in uppercase.  Paste into Excel spreadsheet (space delimited
% if you have other columns).  May want to paste into a text file before
% Excel, or you may want to get textscan (see below) to work with the
% format you get in the text file (thereby bypassing Excel).
%
% Save out as a text file.

fid = fopen('wordlist_comboOfMichal&MRC.txt');
cols = textscan(fid,'%s%f');  % adjust for the columns you have (this is for a string and a number)
fclose(fid);
%cols{1} gives you the words
words = lower(cols{1}); % turn into lowercase

% Now write back out into a text file
fid = fopen('wordlist_new.txt','wt');

for x=1:length(words), fprintf(fid,'%s\n',words{x}); end
fclose(fid);