function status = MoveProcessedFiles(sessions,sesSize)

% set default status to 0
status = 0;

currentDir=nptPWD;
%create additional folders to move processed data into
for i=1:sesSize	%loop over sessions
	session_num=sessions(i).name;
	cd (session_num)      %go into session dir
	
	%eyefilt files
	dirlist=dir('*_eyefilt.*');
	if ~isempty(dirlist )
		status=mkdir('eyefilt');
		for j = 1:size(dirlist,1) 
			file_name = dirlist(j).name;
			status = movefile(file_name,[currentDir filesep session_num filesep 'eyefilt' filesep file_name]);
            status=~status; %status is 1 for success and 0 for failure in R2006b.
		end
	end
	
	%eye files
	dirlist=dir('*_eye.*');
	if ~isempty(dirlist )
		status=mkdir('eye');
		for j = 1:size(dirlist,1) 
			file_name = dirlist(j).name;
			status = movefile(file_name,[currentDir filesep session_num filesep 'eye' filesep file_name]);
            status=~status; %status is 1 for success and 0 for failure in R2006b.
		end
	end
	
	%lfp files
	dirlist=dir('*_lfp.*');
	if ~isempty(dirlist)
		status=mkdir('lfp');
		for j = 1:size(dirlist,1) 
			file_name = dirlist(j).name;
			status = movefile(file_name,[currentDir filesep session_num filesep 'lfp' filesep file_name]);
            status=~status; %status is 1 for success and 0 for failure in R2006b.
		end
	end
	
	%highpass files
	dirlist=dir('*_highpass.*');
	if ~isempty(dirlist)
		status=mkdir('highpass');
		for j = 1:size(dirlist,1) 
			file_name = dirlist(j).name;
			status = movefile(file_name,[currentDir filesep session_num filesep 'highpass' filesep file_name]);
            status=~status; %status is 1 for success and 0 for failure in R2006b.
		end
	end
	
	%dat files
	dirlist=[dir('*.dat') ; dir('*waveforms.bin') ; dir('*.hdr') ; dir('*.cfg')];
	if ~isempty(dirlist)
		status=mkdir('sort');
		for j = 1:size(dirlist,1) 
				file_name = dirlist(j).name;
				status = movefile(file_name,[currentDir filesep session_num filesep 'sort' filesep file_name]);
                status=~status; %status is 1 for success and 0 for failure in R2006b.
		end
	end
	
	%FD folder
	if isdir('FD')
		cd('sort')
		if isdir('FD')  %remove old FD 
			cd('FD')
			delete('*')
			cd ..
        else
            status=mkdir('FD');
            status=~status; %status is 1 for success and 0 for failure in R2006b.
		end
		cd ..
		cd('FD')
		dirlist = nptDir('*');
		for j = 1:size(dirlist,1) 
			file_name = dirlist(j).name;
			[status,message,messageid] = movefile(file_name,[currentDir filesep session_num filesep 'sort' filesep 'FD' filesep file_name]);
            status=~status; %status is 1 for success and 0 for failure in R2006b.
		end
		cd ..
        rmdir('FD')
	end    
	
	cd (currentDir);
end %loop over sessions
