function [lfps , resample_rate]=nptLowPassFilter(varargin)
%nptLowPassFilter Apply low pass filter to data
%   [LFP,RESAMPLE_RATE] = nptLowPassFilter(DATA,SAMPLING_RATE)
%   resamples DATA from SAMPLING_RATE to 1 KHz and filters the data 
%   with a fourth order buttterworth filter with the default cutoff 
%   frequencies at 1 Hz and 150 Hz. The filtered data is returned 
%   in LFP and RESAMPLE_RATE is 1000 representing 1 KHz.
%
%   [LFP,RESAMPLE_RATE] = nptLowPassFilter(DATA,SAMPLING_RATE,
%   RESAMPLE_RATE) resamples DATA from SAMPLING_RATE to 
%   RESAMPLE_RATE and uses 1 Hz and 150 Hz as the cutoff
%   frequencies.
%
%   [LFP,RESAMPLE_RATE] = nptLowPassFilter(DATA,SAMPLING_RATE,
%   LOW_FREQ_LIMIT,HIGH_FREQ_LIMIT) resamples at 1 Khz uses 
%   LOW_FREQ_LIMIT and HIGH_FREQ_LIMIT as the cutoff frequencies
%   in Hz.
%
%   [LFP,RESAMPLE_RATE] = nptLowPassFilter(DATA,SAMPLING_RATE,
%   RESAMPLE_RATE,LOW_FREQ_LIMIT,HIGH_FREQ_LIMIT) resamples DATA
%   from SAMPLING_RATE to RESAMPLE_RATE uses LOW_FREQ_LIMIT 
%   and HIGH_FREQ_LIMIT as the cutoff frequencies in Hz.
%
%   e.g. [lfp,rs] = nptLowPassFilter(data,30000) resamples data
%   to 1 KHz and filters the data from 1 Hz to 150 Hz.
%
%   e.g. [lfp,rs] = nptLowPassFilter(data,30000,10000) resamples 
%   data to 10 KHz and filters the data from 1 Hz to 150 Hz.
%
%   e.g. [lfp,rs] = nptLowPassFilter(data,30000,1,85) resamples
%   data to 1 KHz and filters the data from 1 Hz to 85 Hz.
%
%   e.g. [lfp,rs] = nptLowPassFilter(data,30000,10000,1,85) 
%   resamples data to 10 KHz and filters the data from 1 Hz to 
%   85 Hz.
%
%   Dependencies: RESAMPLE, BUTTER, FILTFILT.

display=0;

switch nargin
	case 2
		inputdata = varargin{1};
		sampling_rate = varargin{2};
		resample_rate=1000;
		%filter signals between 1 and 150 Hz  (see filter_design.m for design specs)
		Fn=resample_rate/2;		%!!!Use nyquist freq
		low=1/Fn;	
		high=150/Fn;
		
	case 3
		inputdata = varargin{1};
		sampling_rate = varargin{2};
		resample_rate=varargin{3};
		%filter signals between 1 and 150 Hz  (see filter_design.m for design specs)
		Fn=resample_rate/2;		%!!!Use nyquist freq
		low=1/Fn;	
		high=150/Fn;
	
	case 4
		inputdata = varargin{1};
		sampling_rate = varargin{2};
		resample_rate=1000;
		%filter signals between LOW_FREQ_LIMIT and HIGH_FREQ_LIMIT  (see filter_design.m for design specs)
		Fn=resample_rate/2;		%!!!Use nyquist freq
		low=varargin{3}/Fn;	
		high=varargin{4}/Fn;
		
	case 5
		inputdata = varargin{1};
		sampling_rate = varargin{2};
		resample_rate=varargin{3};
		%filter signals between LOW_FREQ_LIMIT and HIGH_FREQ_LIMIT  (see filter_design.m for design specs)
		Fn=resample_rate/2;		%!!!Use nyquist freq
		low=varargin{4}/Fn;	
		high=varargin{5}/Fn;

	otherwise
		error('Wrong number of input arguments')
end

%subsample files to 1KHz
% need to transpose inputdata since resample works on columns
lfps_data = resample(transpose(inputdata),resample_rate,sampling_rate);
if display
    figure
    plot(inputdata(1,:))
    figure
    plot(lfps_data(:,1))
end
	  
%create filter coeffiecents for butterworth filter
%need the signal processing toolbox installed to use butter function!!!!
% b=[0.0459 0 -0.1834 0 0.2751 0 -0.1834 0 0.0459];
% a=[1.0000 -4.7759 9.7965 -11.5999 8.9966 -4.7469 1.6072 -0.3083 0.0307];
order=4;
[b,a] = butter(order, [low high]);  

  
%use filtfilt so there are no phase shifts
if size(lfps_data,1)>3*2*order
    lfps = transpose(filtfilt(b,a,lfps_data));
else
    lfps = lfps_data';
end
if display
    hold on
    plot(lfps(1,:),'r')
end