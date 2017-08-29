function ec = getDXYData
%getDXYData Searches for and loads DXY eye calibration files
%   EC = getDXYData searches the sub-directories present in the 
%   local directory for DXY files created from eye calibration 
%   sessions. If a file named 'skip.txt' is present in the 
%   sub-directory, the DXY file in that sub-directory will be 
%   skipped. The EC structure consists of the following fields:
%      EC.NumberofDXYfiles
%      EC.ScreenHeight
%      EC.ScreenWidth
%      EC.GridRows
%      EC.GridCols
%      EC.Xsize
%      EC.Ysize
%      EC.CenterX
%      EC.CenterY
%      EC.NumBlocks
%      EC.NumberOfTrials
%      EC.meanVHmatrix
%      EC.avgVH
%      EC.eyecoilcoords
%
%   ec = getEyeCal;

% set default value for variable
changedDir = 0;
ec.NumberofDXYfiles=0;
eyecalDirName = 'eyecal';

% check for presence of eyecal directory which indicates we are working
% with new directory structure
if(isdir(eyecalDirName))
	% change directory since all eye cal sessions should be in this
	% directory
	cd(eyecalDirName)
	changedDir = 1;
end
dirlist = nptDir;
for i=1:size(dirlist,1)	%loop through sessions
	if dirlist(i).isdir
		cd (dirlist(i).name)
		%is there a marker file for this session?      
		marker = nptDir('skip.txt');
		if isempty(marker)
			dxy_list=nptDir('*_dxy.bin');
			if ~isempty(dxy_list)
				fprintf('\t\tUsing DXY File %s\n', dxy_list(1).name);
				ec.NumberofDXYfiles = ec.NumberofDXYfiles + 1;
				fid=fopen(dxy_list(1).name,'r','ieee-le');
				% read in variables
				ec.ScreenHeight(ec.NumberofDXYfiles) ...
					= fread(fid, 1, 'int32');
				ec.ScreenWidth(ec.NumberofDXYfiles) ...
					= fread(fid, 1, 'int32');
				ec.GridRows(ec.NumberofDXYfiles) = ...
					fread(fid, 1, 'int32');
				ec.GridCols(ec.NumberofDXYfiles) = ...
					fread(fid, 1, 'int32');
				ec.Xsize(ec.NumberofDXYfiles) = ...
					fread(fid, 1, 'int32');
				ec.Ysize(ec.NumberofDXYfiles) = ...
					fread(fid, 1, 'int32');
				ec.CenterX(ec.NumberofDXYfiles) = ...
					fread(fid, 1, 'int32');
				ec.CenterY(ec.NumberofDXYfiles) = ...
					fread(fid, 1, 'int32');
				ec.NumBlocks(ec.NumberofDXYfiles) = ...
					fread(fid, 1, 'int32');
				ec.NumberOfPoints(ec.NumberofDXYfiles) = ...
					ec.GridRows(ec.NumberofDXYfiles) ...
						* ec.GridCols(ec.NumberofDXYfiles);
				ec.NumberOfTrials(ec.NumberofDXYfiles) = ...
					ec.NumberOfPoints(ec.NumberofDXYfiles) ...
					* ec.NumBlocks(ec.NumberofDXYfiles);
				% meanVH is the average voltage of the last fixation 
				% for each trial.  This was used to create avgVH in 
				% ProcessSession
				% but it is not used anymore.
				ec.meanVHmatrix(ec.NumberofDXYfiles,1:2, ...
					1:ec.NumberOfTrials(ec.NumberofDXYfiles)) ...
						= fread(fid, ...
							[2,ec.NumberOfTrials(ec.NumberofDXYfiles)],...
								'double');
				%avgVh is the average voltage for each grid point.
				ec.avgVH(ec.NumberofDXYfiles,1:2, ...
					1:ec.NumberOfPoints(ec.NumberofDXYfiles)) ...
						= fread(fid, ...
							[2,ec.NumberOfPoints(ec.NumberofDXYfiles)],...
								'double');
				fclose(fid);
			end
		end % end if isempty(marker)
		cd ..
	end
end

if ec.NumberofDXYfiles==1
	ec.eyecoilcoords = squeeze(ec.avgVH);
   
elseif ec.NumberofDXYfiles==0
	fprintf('No dxy file present can not process eyedata\n');
   
%average all dxy files if they have the same parameters
% This operation first scans across all elements of
% each screen parameter, e.g. ScreenHeight(ec.NumberofDXYfiles)
% and calculates the differences between neighbors ('diff').
% 'find' then returns the index of all of the differences
% that were non-zero.  'isempty' returns a 1 if the results
% of 'find' were an empty set, indicating no differences.
elseif  ( isempty(find( diff(ec.ScreenHeight) )) & ... 
      isempty(find( diff(ec.ScreenWidth) )) & ... 
      isempty(find( diff(ec.GridRows)    )) & ... 
      isempty(find( diff(ec.GridCols)    )) & ... 
      isempty(find( diff(ec.Xsize)   		)) & ... 
      isempty(find( diff(ec.Ysize)		   )) & ... 
      isempty(find( diff(ec.CenterX)     )) & ... 
      isempty(find( diff(ec.CenterY)     )) )
   
	ec.eyecoilcoords = squeeze(mean(ec.avgVH));
   
else
	fprintf('Warning!: Screen parameters in DXY files DO NOT match.\n\t\tUsing only the first DXY file: %s\n\n', dxy_list(1).name);
	% get average eyecoil coordinates from first DXY file's averages
	ec.eyecoilcoords = squeeze(ec.avgVH(1,:,:));
end

if(changedDir)
	% if we changed directory, move back to original directory,
	% which should be just the parent directory.
	cd ..
end
