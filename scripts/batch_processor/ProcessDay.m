function ProcessDay(varargin)
%ProcessDay		Process a day's data.
%   ProcessDay checks the local directory for data to process. It
%   does the following:
%      a) Checks the local directory for the presence of files named
%   either skip.txt or processedday.txt. If either are present, the
%   function will exit, unless the argument 'redo' is present.
%      b) Renames files with uppercase characters to lowercase (only
%   valid for Unix systems).
%      c) Checks if all the data files are stored in session
%   directories. If not, it creates session directories, and moves
%   moves the files for each session into the appropriate directory.
%      d) Changes directory to each session directory and calls
%   ProcessSession.  First, changes data to trial format if needed.
%      e) Calls ProcessEyeSessions to convert eye signals to screen 
%   coordinates using data from eye calibration sessions. 
%      f) Moves processed files in each session directory into the
%   appropriate subdirectories (uses unix commands on most platforms and 
%   cygwin on Windows machines, if it is installed, but falls back on
%   much slower Matlab functions if cygwin is not installed). These 
%   include:
%         eyefilt    Eye-positionn signals at 1 kHz resolution.
%         eye        Eye-position signals in screen coordinates.
%         lfp        Low-pass filtered signals from broadband signals.
%         highpass   High-pass filtered signals from broadband signals.
%         sort       Extracted spike times and waveforms from unit 
%                    signals.
%      g) If sort folder was created, run AutomaticSpikeSorting programs
%      h) Creates processedday.txt in the local directory.
%
%   ProcessDay(ARG1,ARG2,...) takes the following optional arguments,
%   which are also passed to ProcessSession:
%      'redo'        If this is the only argument, the function 
%                    performs all operations even if processedday.txt 
%                    is present.
%      'eye'         Performs calculations on the eye signals.
%   The following optional arguments are only used by this function:
%      'sessions'	 Processes selected sessions instead of all 
%                    sessions found in the local directory. This 
%                    argument must be followed by a cell array 
%                    containing a list of session names, 
%                    e.g. {'08','09'}.
%      'eyesessions' Copies dxy files used to calibrate the eye 
%                    signals from another directory. This argument 
%                    must be followed by a cell array of directory 
%                    paths (relative to current directory),
%                    e.g. {'../062102/05','../062102/06'}. These 
%                    directories should ideally contain only dxy 
%                    files.
%      'cpdescriptor'Specifies path to descriptor file that will be copied
%                    and renamed appropriately, e.g. 
%                    '../050510/session01/clark05051001_descriptor.txt'
%      'nomove'      Skips step f) above. Useful if more reliable 
%                    utilities are going to be used to move files
%                    on Windows machines.
%      'cygwinpath'  Specifies path to bash shell in cygwin (defaults to
%                    'c:\cygwin\bin\bash').
%      'remotekk'    Flag to use ogier to run KlustaKwik.
%
%	Dependencies: nptPWD, nptDir, nptFileParts, ProcessSession, 
%		ProcessEyeSessions.

%%%%%%%%%%%%%%program outline%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	create session folders and move files into them
%	loop over sessions

%		cd into session
%		ProcessSession
%		cd out to date
%	end
%	ProcessSessionExperimental	
%	create marker file to show that that date has been processed 
%	create additional folders(eye,lfp,sort,…) and move files to them
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% default values for variables
eyeSessions = {};
selectedsessions = 0;
slist = {};
cygwin = 0;
eyecalDirName = 'eyecal';
cpdescriptor = '';
cygwinpath = 'c:\cygwin\bin\bash.exe';
usecygwin = 1;
remotekk = 0;

if ~isempty(varargin) 
   % there are arguments so set eyeflag and redo to 0 first
   redo=0;
   eyeflag=0;
   nomove = 0;
   
   num_args = nargin;
   
   i = 1;
   while(i <= num_args)
		if(ischar(varargin{i}))
			switch varargin{i}
			case('redo')
				redo = 1;
			case('redoValue')
				redo = varargin{i+1};
				i=i+1;
			case('eye')
				eyeflag = 1;
			case('eyeValue')
				eyeflag = varargin{i+1};
				i=i+1;
			case('nomove')
				nomove = 1;
				% remove argument from list
				[varargin,num_args] = removeargs(varargin,i,1);
				i = i - 1;
			case('nomoveValue')
				nomove = varargin{i+1};
				[varargin,num_args] = removeargs(varargin,i,2);
				i = i - 1;
			case('eyeSessions')
				eyeSessions = varargin{i+1};
				% need to remove arguments since ProcessSession
				% won't be able to parse it
				[varargin,num_args] = removeargs(varargin,i,2);
				i = i - 1;
			case('sessions')
				slist = varargin{i+1};
				if iscell(slist)
					selectedsessions = 1;
				end
				% need to remove arguments since ProcessSession
				% won't be able to parse it
				[varargin,num_args] = removeargs(varargin,i,2);
				i = i - 1;
			case('cygwinpath')
				cygwinpath = varargin{i+1};
				[varargin,num_args] = removeargs(varargin,i,2);
				i = i - 1;
			case('cpdescriptor')
				cpdescriptor = varargin{i+1};
				[varargin,num_args] = removeargs(varargin,i,2);
				i = i - 1;
			case('remotekk')
				remotekk = 1;
				[varargin,num_args] = removeargs(varargin,i,1);
				i = i - 1;
			end
		end
		i = i + 1;
   end
   
   % check if redo was the only argument, in which case we need 
   % to redo everything
   if redo==1 & num_args==1
      eyeflag = 1;
   end
else
   % no arguments so just do everything
   redo = 0;
   eyeflag = 1;
   nomove = 0;
end

% is there a marker file for this day?
marker = nptDir('skip.txt');
% check for processedday.txt unless redo is 1
if redo==0
   marker=[marker nptDir('processedday.txt')];
end

if isempty(marker)
   sessions=[];
   currentDir=nptPWD;

	% check if we are on a Windows machine   
	pccheck = ispc;

	% check if cygwin exists if we are on a Windows machine
	if(pccheck)
		if(isempty(nptDir(cygwinpath)))
			fprintf('No cygwin detected...\n');
			usecygwin = 0;
		end
	end
	
	% check to see if there is a folder called Eyes and if so move the
	% files out of the directory. Only necessary for old psychophysical
	% data which has the old data hierarchy.
	moveError = 0;
	% use ispresent instead of isdir to avoid case sensitivity
	if(ispresent('eyes','dir','CaseInsensitive'))
		fprintf('Converting data hierarchy...\n');
		if(~pccheck)
			[s,w] = system('mv Eyes/* .');
			if s==0
				[s,w] = system('rmdir Eyes');
			else
				moveError = 1;
		 	end
		else
			error('No functions set up to change data hierarchies on Windows machines!')
		end
	end
   
   % if we are on a platform that uses filenames that are case
   % sensitive, run command to fix the filenames
   % platform = computer;
   %if ~(strcmp(platform,'PCWIN') | strcmp(platform,'MAC2'))
   if(~pccheck)
      a = which('tolower.tcsh');
      % call tolower script and suppress stderr output
      [s,w] = system(a);
      % eval(sprintf('!%s >& /dev/null',a))
   end
   
   % call function to see if we need to move raw files
   % status = MoveRawSessionFiles;
   
   if moveError == 1
      ContoursMoveEyesFiles;
      [s,w] = system('rmdir Eyes');
   end

	if(~isempty(cpdescriptor))
		% check if we need to copy descriptor files from some other session   
		% get path to cpdescriptor
		tname = which('cpdescriptor.sh');
		if(pccheck)
			if(usecygwin)
				doscommand = [cygwinpath ' -i ' tname ' ' cpdescriptor];
				dos(doscommand);
			else
				error('Please install Cygwin to copy descriptor files on Windows machines!')
            end
		else
			[s,w] = system([tname ' ' cpdescriptor]);
		end
	end
	
   % check if there are directories named site*
   siteDirs = nptDir('site*');
   % get number of sites
   numSites = size(siteDirs,1);   
   % if numSites is 0, we are working on old style directory structure 
   if(numSites==0)
	   % get sessions ** need to make sure there are no other files in the root directory
	   sessions = nptDir;
	   sesSize = size(sessions,1);
	   i = 1;
	   while (i<=sesSize)
		  % check to make sure it is of the right format
		  if sessions(i).isdir
			 if ~((selectedsessions == 1) & (sum(strcmp(sessions(i).name,slist))==0))
				session_num = sessions(i).name;
				fprintf(['\tProcessing Session ' session_num '\n']);
				cd (session_num)
				
	%             %check to run CreateCatTrials
	%             if isempty(nptDir('*.0*')) & ~isempty(nptDir([session_num '.bin']))
	%                Single2Trials([session_num '.bin'],session_num);
	%             end
				
				ProcessSession(varargin{:})
				cd ..
			 end
			 i = i + 1;
		  else
			 % remove item from sessions list if it is not a directory so we 
			 % don't have to check for this again later on
			 sessions = [sessions(1:i-1); sessions(i+1:end)];
			 sesSize = sesSize - 1;
		  end
	   end
	   
	   % check if there are any eye calibration sessions for this day
	   % and if not, see if we need to copy them from somewhere
	   if ~isempty(eyeSessions)
		  eyeCalib = 0;
		  for i = 1:sesSize
			 cd(sessions(i).name)
			 if ~isempty(nptDir('*_dxy.bin'))
				eyeCalib = 1;
				cd ..
				break;
			 end
			 cd ..
		  end
		  if eyeCalib == 0
			 fprintf('Copying dxy file...\n');
			 eSize = size(eyeSessions,2);
			 lastSession = str2num(sessions(sesSize).name);
			 for i = 1:eSize
				eNum = lastSession + i;
				fprintf('Copying dxy file from %s to %02i\n',eyeSessions{i},eNum);
				% [s,w] = system(sprintf('cp -r %s %02i',eyeSessions{i},eNum));
				[s,w] = system(sprintf('mkdir %02i; cp %s/*_dxy.bin %02i',eNum,eyeSessions{i},eNum));
				if s == 1
				   fprintf('Warning: dxy copy failed!\n');
				   break;
				end
			 end
		  end
	   end
	   
	   if eyeflag==1
		  ProcessEyeSessions(varargin{:})
	   end

		if nomove==0
			fprintf('\tMoving processed files to processed folders ... \n');
			%create marker file to show this day has been processed
			% call function to move processed files
			% if(strcmp(platform,'PCWIN') & ~cygwin)
			if(pccheck && ~usecygwin)
				tic;
				status = MoveProcessedFiles(sessions,sesSize);
				toc
			else
				% get path to script
				mname = which('moveprocessedfiles.sh');
				if(~pccheck)
					syscmd = mname;			
				else
					syscmd = [cygwinpath ' -i ' mname];
				end
				tic
				[status,w] = system(syscmd);
				toc
				% display w so we can see what happened
				fprintf('%s\n',w);
			end
			if(status)
				fprintf('Warning: Processed files not moved properly!\n');
			end
		end
	   
		fid=fopen('processedday.txt','wt');
		fclose(fid);
   
	else
		% we are working on new style directory structure so use new code
		% check if there is an eyecal directory (cat sessions won't have one)
		% in addition to the site directories
        if(isdir(eyecalDirName))
			% add the eyecal directory
			numSites = numSites + 1;
            siteDirs(numSites).name = eyecalDirName;
		end
		
		% loop over sites
		for siteIndex = 1:numSites
			cd(siteDirs(siteIndex).name);
			% get sessions
			sessions = nptDir;
			sesSize = size(sessions,1);
			for sesIndex = 1:sesSize
				if(sessions(sesIndex).isdir)
					if ~((selectedsessions == 1) ... 
					  & (sum(strcmp(sessions(sesIndex).name,slist))==0))
						session_num = sessions(sesIndex).name;
						fprintf('\tProcessing %s/%s\n', ...
							siteDirs(siteIndex).name,session_num);
						cd (session_num)
						ProcessSession(varargin{:})
						cd ..
					end
				end
			end
            
            cd ..
		end
	   
		if eyeflag==1
			ProcessEyeSessions(varargin{:})
		end

		if nomove==0
			fprintf('\tMoving processed files to processed folders ... \n');
			% call function to move processed files
			% if(strcmp(platform,'PCWIN') & ~cygwin)
			if(pccheck && ~usecygwin)
				tic;
				for siteIndex = 1:numSites
					cd(siteDirs(siteIndex).name);
					status = MoveProcessedFiles(sessions,sesSize);
					cd ..
				end
				toc
			else
				% get path to script
				mname = which('moveprocessedfiles.sh');
				if(~pccheck)
					syscmd = mname;			
				else
					syscmd = [cygwinpath ' -i ' mname];
				end
				tic
				% initialize status to 0 since system returns 0 if
				% there were no errors
				status = 0;
				for siteIndex = 1:numSites
					cd(siteDirs(siteIndex).name);
					[status1,w] = system(syscmd);
					% display w so we can see what happened
					fprintf('%s\n',w);
					% add status1 to status so if there is an
					% error, status will be non-zero
					status = status + status1;
                    cd ..
				end
				toc
			end
			if(status)
				fprintf('Warning: Processed files not moved properly!\n');
			end
		end
		
		if(remotekk)
			% get path to script
			rname = which('remotekke.sh');
			if(~pccheck)
				syscmd = rname;			
			else
				syscmd = [cygwinpath ' -i ' rname];
			end
			[status1,w] = system(syscmd);
			% display w so we can see what happened
			fprintf('%s\n',w);
		end
	   
		fid=fopen('processedday.txt','wt');
		fclose(fid);
	end   
end % if marker file exists
