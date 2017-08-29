function r = separate(obj,varargin)
%@ispikes/separate Separates cells contained in ispikes object
%   R = separate(OBJ,'CellNames',CELL_NAMES) separates cells contained 
%   in the ispikes object, OBJ. R will be a cell array of ispikes 
%   object if there are multiple clusters in OBJ. If there is only 1 
%   cell in OBJ, OBJ will be returned in R.
%
%   CELL_NAMES is a cell array of names for the cells after they have 
%   been separated.  CELL_NAMES must be the same length as the number 
%   of clusters in the object. If CELL_NAMES is empty, the ClusterNames
%   file for the group will be used.
%
%   If the 'save' flag is specified then new directories of the cell 
%   names are created at the same level as the pwd and each new ispike
%   is moved to its' respective directory.  
%      e.g. separate(OBJ,{'01s','02s','01m'},'save')

Args = struct('SaveLevels',0,'RedoLevels',0,'NoReplacePrompt',0, ...
	'CellNames','');
Args = getOptArgs(varargin,Args, ...
    'flags',{'NoReplacePrompt'}, ...
    'shortcuts',{'redo',{'RedoLevels',1};'save',{'SaveLevels',1}}, ...
    'subtract',{'RedoLevels','SaveLevels'});

% check if CellNames is empty
if(isempty(Args.CellNames))
	% try to get cellnames from ClusterNames file
	clusterFilename = ['ClusterNamesg' obj.data.groupname '.txt'];
	if(ispresent(clusterFilename,'file'))
		Args.CellNames = textread(clusterFilename,'%s');
	else
		error('Unable to obtain cell names!');
	end
end
% get number of clusters in object
nclusters = size(obj.data.trial(1).cluster,2);
% make sure there are enough names in CellNames for all clusters
if(~isempty(Args.CellNames))
    % get length CellNames
    cnl = length(Args.CellNames);
    if(cnl~=nclusters)
        error(sprintf('Object contains %d clusters and only %d names specified!\n', ...
            nclusters,cnl));
    end
end
if(nclusters>1)
    % create return cell array of objects
    % return array has to be cell array otherwise objects won't be returned
    % properly
    for i = 1:nclusters
        r{i} = obj;
        r{i}.data.numClusters = 1;
        r{i}.data.cellname = Args.CellNames{i};
    end
    
    % loop over number of trials and remove other clusters from r(i)
    for i = 1:obj.data.numTrials
        for j = 1:nclusters
            r{j}.data.trial(i).cluster = obj.data.trial(i).cluster(j);
        end
    end
else
    r{1} = obj;
    r{1}.data.cellname = Args.CellNames{1};
end

if Args.SaveLevels 
    %Create Directories and Move files.
    pdir = pwd;
    % get group directory name
    gdname = ['..' filesep 'group' r{1}.data.groupname];
    % try creating group directory
    [success,message,messageid] = mkdir(gdname);
    if(success)
        cd(gdname);
        % success is 1 even if directory exists so we can continue
        % check if there are any cluster directories present
        clist = nptDir('cluster*');
        clnum = size(clist,1);
        % if there are existing files
        if(clnum>0)
            % prompt the user if these files should be replaced
            if(~Args.NoReplacePrompt)
                button = questdlg('What do you want to do with existing cluster directories...', ...
                    'Cluster directories exist', ...
                    'Replace ispikes.mat','Delete directories', ...
                    'Cancel','Replace ispikes.mat');
                switch(button),
                	case 'Replace',
                		fprintf('Replacing ispikes.mat files...\n');
                	case 'Delete directories',
						% delete directories recursively
						fprintf('Deleting cluster directories...\n');
						for i = 1:clnum
							[s,m] = rmdir(clist(i).name,'s');
							if(s==0)
								cd(pdir)
								error('Error deleting existing files!')
							end
						end
                	case 'Cancel'
						fprintf('ispikes objects not saved!\n');
						cd(pdir)
						return
                end % switch
            end
        end                
        % get number of cells
        cnum = length(r);
        for ii = 1:cnum
            sp = r{ii};
            % get cluster name
            cdname = ['cluster' sp.data.cellname];
            % try creating cell directory
            [success,message,messageid] = mkdir(cdname);
            if(success)
                cd(cdname)
                save('ispikes.mat','sp')
                cd ..
            else
                fprintf('Error saving ispikes objects: %s\n',message);
                cd(pdir);
                % display(message)
            end
        end
        cd(pdir);
    else
        fprintf('Error saving ispikes objects: %s\n',message);
    end
end
