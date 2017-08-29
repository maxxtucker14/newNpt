function CheckPresenterSignalSequence(filename)
%CheckPresenterSignalSequence Check sequence of debug messages from Presenter
%   CheckPresenterSignalSequence(FILENAME) checks the messages in
%   FILENAME to make sure all the messages were received and sent
%   in sequence.
%
%   Dependencies: None.

signals = {'STIM_SHOW_FIX','STIM_SHOW_STIM','STIM_HIDE_FIX',...
			'STIM_HIDE_MATCH','STIM_NEXT'};
sigSize = size(signals,2);

fid = fopen(filename,'rt');

signalCounter = 0;
currentSignal = signalCounter + 1;

% read a line
a = fgetl(fid);
lnum = 1;

while(a~=-1)
	% type should either be sent or received
	type = sscanf(a,'%*s %*s %*s %*s %s %*s');
	% signal should be one of signals or STIM_STOP
	signal = sscanf(a,'%*s %*s %*s %*s %*s %s');
	% if line does not match pattern, we will just go to the next line
	if strcmp(type,'Sent')
		fprintf('Warning: Line %d - %s was sent before it was received!\n',lnum,signal);
	elseif strcmp(type,'Received')
		if strcmp(signal,signals{currentSignal}) | strcmp(signal,'STIM_STOP')
			% save the previous signal
			signal1 = signal;
			% check to make sure the following line is echoing the same signal
			a = fgetl(fid);
            lnum = lnum + 1;
			type = sscanf(a,'%*s %*s %*s %*s %s %*s');
			signal = sscanf(a,'%*s %*s %*s %*s %*s %s');
			if ~(strcmp(type,'Sent') & strcmp(signal,signal1))
				fprintf('Warning: Line %d - %s was not echoed!\n',lnum,signal1);
			else
				signalCounter = rem(signalCounter + 1,sigSize);
                currentSignal = signalCounter + 1;
			end
		else
			fprintf('Warning: Line %d - %s was received out of order!\n',lnum,signal);
		end
	end
	a = fgetl(fid);
    lnum = lnum + 1;
end
