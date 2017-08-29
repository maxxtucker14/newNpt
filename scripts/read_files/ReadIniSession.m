function [r,status] = ReadIniSession(f)
%ReadIniSession Reads session information from INI files
%   [R,STATUS] = ReadIniSession(FILENAME) opens FILENAME and reads 
%   Presenter version, date, and screen dimensions from a file 
%   pointer, FID. STATUS is 0 if there were no errors and 1 
%   otherwise.

section = 'SESSION INFO';

readSet = {section,'','Presenter Version','',''; ...
			section,'','Date','',''; ...
			section,'','Time','',''; ...
			section,'','Screen Width','i',0; ...
			section,'','Screen Height','i',0};

% set default return arguments
r = {};
status = 1;

if nargin == 0
  fprintf('Must provide filename!\n');
  return
end

% get values from ini files
[val,s] = inifile(f,'read',readSet);

% check to make sure there were no problems. status should be 0 if
% there were no problems
status = ~isempty(find(~cellfun('isempty',s)));

if(~status)
	% get rid of spaces in the field names and add session name
	fnames = strrep({readSet{:,3}},' ','');
	% add fieldname sessionname 
	fieldnames = {'sessionname' fnames{:}};
	% strip suffix of filename
	[p,n] = nptFileParts(f);
	% prefix val with the sessionname
	values = {n val{:}};
	% convert cell array to structure
	r = cell2struct(values,fieldnames,2);
end
