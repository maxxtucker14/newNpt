function [extracted_data,duration]=ExtractorWrapper(data,neurongroup_info,sampling_rate,tmean,threshold,groups,varargin)
%ExtractorWrapper	Computes mean and stdev used during spike extraction
%	[EXTRACTED,DURATION,THRESHOLD]=ExtractorWrapper(DATA,
%	DESCRIPTOR,GROUP_INFO,SAMPLING_RATE,MEAN,STDEV,GROUPS,EXTRACT_SIGMA) 
%   The threshold based on the mean, stdev and extract_sigma 
%   is calculated.  nptExtructor is then called with these 
%	variables. DESCRIPTOR is the data structure 
%	returned by ReadDescriptor which contains descriptions of the data. 
%	GROUP_INFO is the data structure returned by GroupSignals which
%	describes how groups of data are organized. The trial duration 
%	is returned in DURATION. 
%   The extracted data is returned in the following structure:
%		EXTRACTED(group).waveforms	- a matrix containing all the spike 
%			waveforms stored in rows
%		EXTRACTED(group).times - a matrix containing all the spike 
%			times stored in rows
%
%	Dependencies: nptExtructor

% Calculate 4-sigma thresholds for each channel
fprintf(['     Extracting spikes ...   '])

if nargin<6
    groups=1:size(neurongroup_info,2);
end
% Loops over group number  
fprintf([' Group ' num2str(groups)])
for ii=groups
    %group=neurongroup_info(ii).group;
    groupdata=[];
    %...we only want to give data for one group at a time
    groupdata=[data(neurongroup_info(ii).channels,:)];	
        
    % Call npt_Extructor
    [extracted_data(ii).waveforms , extracted_data(ii).times ]=nptExtructor(groupdata,tmean(ii,:),threshold(ii,:),sampling_rate,varargin{:});
    %waveforms is now a matrix containing all of the waveforms for all the channels
    %each waveform set is on a different row.
end

%get trial duration(same for all groups) 
duration=size(groupdata,2)/sampling_rate; % duration of the spike files, in seconds
