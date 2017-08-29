function CheckPresenterSignals(filename)

signals = {'STIM_SHOW_FIX','STIM_SHOW_STIM','STIM_HIDE_FIX','STIM_HIDE_MATCH','STIM_NEXT'};

sigsize = size(signals,2);

for i = 1:sigsize
	% use grep to search for signal in filename and return line numbers
	% where they occur
	cmdstr = sprintf('grep -n %s %s',signals{i},filename);
	[s,w] = system(cmdstr);
	% pick out line number and discard everything else
	a = sscanf(w,'%i:%*8d %*i:%*i:%*f PM [Presente] %*s %*s',inf);
	% signals should occur in pairs, one received, one sent
	asize = size(a,1);
	asize2 = asize/2;
	if rem(asize,2)
		fprintf('%s signals not paired!',signals{i});
	else
		% reshape a into a 2 column matrix, with line number for 
		% received signals in column 1
		a1 = transpose(reshape(a,2,asize2));
		% find the differences in line numbers
		a2 = diff(a1(:,1));
		% differences should be the same when there are no incompletes
		a2min = min(a2);
		a2max = max(a2);
		if (a2min ~= a2max)
			fprintf('%s signals not in sequence!',signals{1});
		end
	end
end
