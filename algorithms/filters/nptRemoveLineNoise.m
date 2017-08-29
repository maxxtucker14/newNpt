function signal=nptRemoveLineNoise(signal,lineF,sampleF)
%nptRemoveLineNoise Removes line noise from a signal
%   CDATA = nptRemoveLineNoise(DATA,LINE_F,SAMPLING_F) removes
%   line noise at LINE_F frequency (in Hz) from DATA sampled
%   at SAMPLING_F frequency (in Hz).
%
%   e.g. cdata = nptRemoveLineNoise(data,60,30000)

% based on code from the lab of Francisco Varela by way of Pedro 
% Maldonado

% get points per line cycle
pplc = fix(sampleF/lineF);

slength=length(signal);

if slength<sampleF
	% figure out the maximum number of cycles we can use to estimate the 
	% line noise
	cycles = fix(slength/pplc);
else
	% otherwise use lineF which is equivalent to 1 second of data to 
	% estimate the line noise
	cycles = lineF;
end

cpoints = cycles * pplc;

if mod(cycles,2)==0
	cplus = cycles/2;
	cminus = cplus - 1;
	pplus = cplus * pplc;
	pminus = cminus * pplc;
else
	cplus = (cycles-1)/2;
	cminus = cplus;
	pplus = cplus * pplc;
	pminus = pplus;
end

% duplicate the signal to get rid of end effects but we want to make
% sure the duplicated data stays at the right phase
indices=[pplus+pplc+1:cpoints,1:slength,slength-cpoints+1:slength-(pminus+pplc)];

mat_ind_ind=repmat(1:slength,cycles,1)+pminus+repmat((-cminus:cplus)'*pplc,1,slength);
mat_ind=indices(mat_ind_ind);
mean_sig=mean(signal(mat_ind));

signal=signal-mean_sig;

