function createClusterNamesFile(obj,varargin)
%ispikes/createClusterNamesFile Creates cluster names file for a group
%   createClusterNamesFile(ISPIKES) creates a cluster names file for a
%   group using existing directory structure. This function can be 
%   called using the 'nptSessionCmd' option of the batch processing
%   functions of the NPTDATA class:
%      ProcessDays(nptdata,'nptSessionCmd','createClusterNames(ispikes)')

% constants used in function
groupname = 'group';
clustername = 'cluster';
suaname = [clustername '*s'];
muaname = [clustername '*m'];
sortDirName = 'sort';
clusterNamePrefix = 'ClusterNamesg';
clusterNameSuffix = '.txt';

% get a list of the groups present
glist = nptDir([groupname '*']);
% get number of groups
gnum = size(glist,1);
% loop over groups and create the cluster names file
for i = 1:gnum
	% get ClusterNames file
	cnfilename = [sortDirName filesep clusterNamePrefix strrep(glist(i).name,groupname,'') clusterNameSuffix];
	% check if ClusterNames file is present
	if(~ispresent(cnfilename,'file'))
		% create the file
		fprintf('Creating %s...\n',cnfilename);
		fid = fopen(cnfilename,'wt');
		
		% get list of sua directories in group directory
		sualist = nptDir([glist(i).name filesep suaname]);
		% get list of mua directories in group directory
		mualist = nptDir([glist(i).name filesep muaname]);
        % remove cluster prefix from names
        snames = strrep({sualist.name},clustername,'');
        mnames = strrep({mualist.name},clustername,'');
		% write sualist first it is not empty
		if(~isempty(sualist))
			fprintf(fid,'%s\n',snames{:});
		end
		% write mualist if it is not empty
		if(~isempty(mualist))
			fprintf(fid,'%s\n',mnames{:});
		end

		% close file
		fclose(fid);
	end % if ClusterNames file is not present
end % loop over groups
