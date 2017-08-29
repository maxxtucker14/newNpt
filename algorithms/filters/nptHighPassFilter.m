function data=nptHighPassFilter(varargin)
%nptHighPassFilter Apply high pass filter to data
%   HP = nptHighPassFilter(DATA) filters DATA with a 
%   fourth order buttterworth filter with the default cutoff 
%   frequencies 500 Hz and 10 kHz. The filtered data is returned 
%   in HP. The sampling rate is assumed to be 30 kHz.
%
%   HP = nptHighPassFilter(DATA,SAMPLING_RATE) filters DATA 
%   recorded at SAMPLING_RATE between 500 Hz and 10 kHz.
%
%   HP = nptHighPassFilter(DATA,LOW_FREQ_LIMIT,HIGH_FREQ_LIMIT) 
%   filters DATA recorded at 30 kHz between LOW_FREQ_LIMIT 
%   and HIGH_FREQ_LIMIT in Hz.
%
%   HP = nptHighPassFilter(DATA,SAMPLING_RATE,LOW_FREQ_LIMIT,
%   HIGH_FREQ_LIMIT) filters DATA recorded at SAMPLING_RATE 
%   between LOW_FREQ_LIMIT and HIGH_FREQ_LIMIT in Hz.
%
%   e.g. hp = nptHighPassFilter(data) filters data recorded at
%   30 kHz from 500 Hz and 10 kHz.
%
%   e.g. hp = nptHighPassFilter(data,25000) filters data 
%   recorded at 25 kHz from 500 Hz and 10 kHz.
%
%   e.g. hp = nptHighPassFilter(data,750,15000) filters data 
%   recorded at 30 kHz from 750 Hz and 15 kHz.
%
%   e.g. hp = nptHighPassFilter(data,25000,750,15000) filters 
%   data recorded at 25 kHz from 750 Hz and 15 kHz.
%
%   Dependencies: RESAMPLE, BUTTER, FILTFILT.

switch nargin
	case 1
		inputdata = varargin{1};
		sampling_rate=30000;
		%filter signals between 500 and 10 kHz  (see filter_design.m for design specs)
		Fn=sampling_rate/2;		%!!!Use nyquist freq
		low=500/Fn;	
		high=10000/Fn;
		
	case 2
		inputdata = varargin{1};
		sampling_rate=varargin{2};
		%filter signals between 500 and 10 kHz  (see filter_design.m for design specs)
		Fn=sampling_rate/2;		%!!!Use nyquist freq
		low=500/Fn;	
		high=10000/Fn;
	
	case 3
		inputdata = varargin{1};
		sampling_rate=30000;
		%filter signals between LOW_FREQ_LIMIT and HIGH_FREQ_LIMIT  (see filter_design.m for design specs)
		Fn=sampling_rate/2;		%!!!Use nyquist freq
		low=varargin{2}/Fn;	
		high=varargin{3}/Fn;
		
	case 4
		inputdata = varargin{1};
		sampling_rate=varargin{2};
		%filter signals between LOW_FREQ_LIMIT and HIGH_FREQ_LIMIT  (see filter_design.m for design specs)
		Fn=sampling_rate/2;		%!!!Use nyquist freq
		low=varargin{3}/Fn;	
		high=varargin{4}/Fn;

	otherwise
		error('Wrong number of input arguments')
end

% create high-pass data
% filter signals between 500 Hz and 10 kHz
[b,a] = butter(4,[low high]);
%b=[0.1988 0 -0.7952 0 1.1928 0 -0.7952 0 0.1988];
%a=[1 -2.4641 1.5275 -0.0918 0.6937 -0.7247 -0.0647 0.0838 0.0408];
% need to transpose since filtfilt operates on columns
filtereddata = filtfilt(b,a,transpose(inputdata));
% transpose back since extractor expects data in rows
data = transpose(filtereddata);