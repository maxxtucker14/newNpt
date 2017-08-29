function status = MoveRawSessionFiles()

myerror = 0;

% get session name and number of sessions
inidirlist = nptDir('*.ini','CaseInsensitive');
inisize = size(inidirlist,1);
% check to see if any of the ini files are actually rf files which have
% _rfs before the suffix
rfsdirlist = nptDir('*_rfs.ini','CaseInsensitive');
numRFfiles = size(rfsdirlist,1);
% adjust the number of sessions accordingly
numSessions = inisize - numRFfiles;

% if no sessions to move, return 1 and exit function
if numSessions < 1
	status = 1;
	return;
end

% get animal and day part of the name from session 01 since that at least
% should be present
dlist = nptDir('*01.ini','CaseInsensitive');
[path,ininame] = nptFileParts(dlist(1).name);
inamelength = length(ininame);
dayname = ininame(1:inamelength-2);

fprintf('Moving raw files...\n');

if isunix
	% call unix script to move files
	a = which('moverawfiles.tcsh');
    % for some reason, the next line does not work if you have it return
    % the output of eval to status
	% eval(sprintf('!%s %s %i',a,dayname,numSessions));
    [s,w] = system(sprintf('%s %s %i',a,dayname,numSessions));
    status = 1;
else
	currentDir = nptPWD;
	for i=1:numSessions	%loop over sessions
		sessionNumber = sprintf('%02i',i);
		status = mkdir(sessionNumber);
		if status == 0
			myerror = 1;
			break;
		else
			sessiondirlist = nptDir([dayname sessionNumber '*']);
			fprintf('\tMoving raw datafiles to session folder ');
			for j = 1:size(sessiondirlist,1)
				fprintf('.');
				%move all files from this session to the session folder
				status = copyfile(sessiondirlist(j).name,[currentDir filesep sessionNumber filesep sessiondirlist(j).name]);
				if status == 1
					delete(sessiondirlist(j).name);
				else
					myerror = 1;
					break;
				end
			end
			fprintf('\n');
		end
	end
	if myerror == 1
		status = 0;
		return
	end
end