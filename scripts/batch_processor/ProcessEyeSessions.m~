function ProcessEyeSessions(varargin)
%ProcessEyeSessions		Converts eye signals into screen coordinates
%   ProcessEyeSessions is called by ProcessDay after all ProcessSessions
%   have been run. This function changes all eye data (including 
%   calibration sessions)to screen coordinates ('eye.bin'),
%   using all dxy files for that date.
%
%   These are the optional arguments for this function:
%      'redo'      Performs operations even if processedeyes.txt is 
%                  present.
%      'reusefilt' Uses files in eyefilt directory when no eyefilt
%                  files are found in the session directory.  
%
%	Dependencies: nptDir, ReadDescriptor, nptReadStreamerFile,
%		nptEyecoil2Screen, nptWriteDataFile.

% set default values for optional arguments
redo = 0;
reuse = 0;
eyecalDirName = 'eyecal';

if ~isempty(varargin) 
	num_args = nargin;
	
	for i=1:num_args
		if(ischar(varargin{i}))
			switch varargin{i}
			case('redo')
				redo=1;
			case('redoValue')
				redo= varargin{i+1};
			case('reusefilt')
				reuse = 1;
			end
		end
	end
end

fprintf('\t\tProcessing eye data ...\n');

% getDXYData works with the new directory structure if present so we
% don't have to call a different function
ec = getDXYData;

% check if there is a eyecal directory present
if(isdir(eyecalDirName))
	% an eyecal directory is present so that probably means we are
	% working with the new directory structure
	% get site directories
	siteDirs = nptDir('site*');
	% get number of site directories and then add 1 for the eyecal
	% directory
	numSites = size(siteDirs,1) + 1;
	% add the eyecal directory to siteDirs
    siteDirs(numSites).name = eyecalDirName;
    useSites = 1;
else
	% set the number of sites to 1 and and siteDirs to current directory
	% in order for the code below to work with both types of directory
	% structure
	siteDirs.name = pwd;
	numSites = 1;
	useSites = 0;
end

% only go into loop if there are DXY files
if ec.NumberofDXYfiles>0
	for siteIndex = 1:numSites
        if(useSites)
    		cd(siteDirs(siteIndex).name);
        end
		dirlist = nptDir;
		for sesi=1:size(dirlist,1)	%loop through all sessions
			if dirlist(sesi).isdir
				cd (dirlist(sesi).name)
				%is there a marker file for this session?      
				marker = nptDir('skip.txt');
				% check for processedsession.txt unless redo is 1
				if redo==0
					marker=[marker nptDir('processedeyes.txt')];
				end
				if isempty(marker)
					%%%%%%	Get Descriptor Info	%%%%%
					descriptor = nptDir('*_descriptor.txt');
					% if there is no descriptor file, just skip over this 
					% session since it might be a session with a 
					% substitute dxy file
					if ~isempty(descriptor)
						descriptor_info = ReadDescriptor(descriptor(1).name);
						eyefiltdirlist=nptDir('*_eyefilt.*');	
						eSize = size(eyefiltdirlist,1);
						if (eSize == 0) & (reuse == 1)
							eyefiltdirlist = nptDir('eyefilt/*_eyefilt.*');
							eSize = size(eyefiltdirlist,1);
							prefix = ['eyefilt' filesep];
						else
							prefix = '';
						end		
						for i = 1:eSize			%loop on trials
							[path filename ext]=...
								fileparts(eyefiltdirlist(i).name);
							% trialfilename=[filename ext(2:length(ext))]; 
							trialname = ext(2:length(ext));
							%eyefiltfilename = [filename trialname];
							[eyefilt,num_channels,sampling_rate,datatype,...
								points]=nptReadDataFile([prefix ...
											eyefiltdirlist(i).name]);
							screencoords = nptEyecoil2Screen(eyefilt,...
								ec.eyecoilcoords,ec.GridCols,ec.GridRows,...
								ec.CenterY,ec.CenterX,ec.Xsize,ec.Ysize);
							nptWriteDataFile([filename(1:length(filename)-4)...
								'.' trialname],sampling_rate,screencoords);
							fprintf('\t\tdatafile: %s  channels: %i\n',...
								[filename(1:length(filename)-4)...
									'.' trialname],2);
						end % loop on trials
			 
						%create marker file to show this session has been processed
						fid=fopen('processedeyes.txt','wt');
						fclose(fid);
					end % if ~isempty(descriptor)
				end % if isempty(marker)
				cd ..
			end % if dirlist(sesi).isdir
		end % loop through all sessions
        if(useSites)
        	cd ..
        end
	end % for siteIndex = 1:numSites
	fprintf('Done!\n');
end % if ec.NumberofDXYfiles>0
