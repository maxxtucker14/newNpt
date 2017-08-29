function [r,status] = ReadIniGrating(filename)
%ReadIniGrating Reads grating information from INI files
%   [R,STATUS] = ReadIniGrating(FILENAME) opens FILENAME and reads 
%   grating stimulus information.

section = 'TReverseCorrGUIForm';

readSet = {section,'','Reverse Corr Type','',''; ...
			section,'','Number of Columns','i',''; ...
			section,'','Number of Rows','i',''; ...
			section,'','Number of Orientations','i',''; ...
			section,'','Directions per Orientation','i',''; ...
			section,'','Base Orientation Angle','i',''; ...
			section,'','Random Order Index','i',''; ...
			section,'','Number of Blocks','i',''; ...
			section,'','Object Type','',''; ...
			section,'','Object Diameter','i',''; ...
			section,'','Spatial Frequency','i',''; ...
			section,'','Velocity','i',''; ...
			section,'','ISI','i',''; ...
			section,'','Spontaneous Activity','i',''; ...
			section,'','Spontaneous Refreshes','i',''; ...
			section,'','X Grid Center','i',''; ...
			section,'','Y Grid Center','i',''; ...
			section,'','X Grid Size','i',''; ...
			section,'','Y Grid Size','i',''; ...
			section,'','Refreshes Per Frame','i',''; ...
			section,'','Background Luminance','i',''};

% set default return arguments
r = {};
status = 1;

if nargin == 0
  fprintf('Must provide filename!\n');
  return
end

% first read session info
[r0,status] = ReadIniSession(filename);

if(status)
	% there was a problem so just exit
	return
end

% now read grating info
[val,s] = inifile(filename,'read',readSet);

% check to make sure there were no problems. status should be 0 if
% there were no problems
status = ~isempty(find(~cellfun('isempty',s)));

% continue only if status is 0
if(~status)
	% check to make sure this is a grating session
	if(strcmp(val{1},'Sparse Noise') && strcmp(val{9},'Grating'))	
		% concatenate both r0 and r1 structures
		% get the fieldnames
		f0 = fieldnames(r0);
		% get rid of spaces in the field names for grating
		fnames = strrep({readSet{:,3}},' ','');
		% convert structures to cell arrays
		c0 = struct2cell(r0);
		% combine both cell arrays and create new structure
		r = cell2struct({c0{:} val{:}},{f0{:} fnames{:}},2);
	else
		% return error since this is not a grating session
		status = 1;
		return
	end
end
