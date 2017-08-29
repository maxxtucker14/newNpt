function data = getSurrISI(obj,varargin)

Args = struct('NumSurrFiles',10,'SurrName','framesg','SurrSFX','.bin', ...
	'NumSurrPerFile',100,'SurrDiffName','surrISI.mat','NoLoad',0);
Args.flags = {'NoLoad'};
Args = getOptArgs(varargin,Args);

if(ispresent(Args.SurrDiffName,'file'))
	if(Args.NoLoad)	
		data = [];
	else
		load(Args.SurrDiffName);
	end
else
	% compute surrogate isi data
	% create memory for surrogate data
	dsdata = cell(1,Args.NumSurrFiles*Args.NumSurrPerFile);
	setidx = 1;
	for sidx = 1:Args.NumSurrFiles
		sdata = readSurrogateBin([Args.SurrName num2str(sidx) Args.SurrSFX]);
		for tidx = 1:Args.NumSurrPerFile
			fprintf('Computing surrogate %d\n',setidx);
			% convert cell array to matrix
			tmp = diff(cell2array(sdata{tidx}));
			dsdata{setidx} = reshape(tmp(~isnan(tmp)),[],1);
			setidx = setidx + 1;
		end
	end
	% add data to dsdata from surrogates
	dsdata = {obj.data.isi dsdata{:}};
	% convert cell array to matrix
	data = cell2array(dsdata);
	% save data
	save(Args.SurrDiffName,'data');
end
