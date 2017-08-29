function [waveforms,times]=nptExtructor(data,v_mean,v_threshold,sampling_rate,varargin)
%nptExtructor	Extracts spike times and waveforms
%	[WAVEFORMS,TIMES] = nptExtructor(DATA,V_MEAN,V_THRESHOLD,
%	SAMPLING_RATE)	expects DATA to be a row of data points if the data 
%	was recorded using electrodes and 4 rows of data points if the data 
%	was recorded using tetrodes. V_MEAN +/- V_THRESHOLD are the cut-offs 
%	for the spike extraction, typically 4 times the standard deviation
%	after the outlying data points have been clipped out. SAMPLING_RATE
%	is the sampling rate in number of data points per second. WAVEFORMS
%	is a matrix containing all the spike waveforms stored in rows. Each
%	waveform contains 10 points before the peak and 21 points after the 
%	peak, for a total of 32 points for each waveform. TIMES is a matrix
%	containing all the spike times stored in rows. The time of each spike 
%	is stored in microseconds.  The extraction algorithm extracts spikes 
%	starting from the largest negative peaks until it reaches 
%	mean-V_THRESHOLD. The extraction then starts again from the largest
%	positive peak until it reaches mean+V_THRESHOLD. When a spike is 
%	found, the 32 points that make up the waveform are no longer eligible 
%	to be peaks in any subsequent search, although the points may be part
%	of other waveforms.
%
%	Dependencies: None.

Args = struct('PositiveOnly',0,'NegativePositive',0);
Args.flags = {'PositiveOnly','NegativePositive'};
Args = getOptArgs(varargin,Args);

%%%%%%%%%%%%%%%%  initializations  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s_before=3;	%samples before threshold
s_after=3;	%samples after threshold
% total samples is 10 + 1 + 21 = 32
s_before2=10;
s_after2=21;

% Extructor --- This is JP's algorithm.
% Only the data for one group is feed in at a time.

% s_ld-> num of data points
% s_hd->num of channels
[s_hd, s_ld]=size(data);

% make each point in data2 either -2,-1,0,1 or 2. It is -2 if <both 
% neighbours, -1 if <one neighbor and equal to the other, and so on.   
data2 = sign(data-[data(:,2:s_ld) zeros(s_hd,1)]) ...
    + sign(data-[zeros(s_hd,1) data(:,1:s_ld-1)]); 
% in this matrix, 1's indicate maxima and -1's minima.		
% SCY - we are going to keep 1's and -1's since they might possibly
% indicate a plateau peak
this_data2=sparse(sign(data2)); 
% SCY - redundant, just use data instead of this_data
% this_data=data;
% clear data;

% BG-s_h and s_l are the same as s_hd and s_ld because we are processing 
% all groups at once
% SCY - redundant, just use s_hd and s_ld from above
% [s_h,s_l]=size(data);		

% v_demean=mean(data');
v_demean=v_mean';				

if(Args.PositiveOnly)
    % positive triggering only
    v_plusmean_plusthres=ceil(v_demean+v_threshold');
    m_helpplus=v_plusmean_plusthres*ones(1,s_ld);
    this_dataplus=data-m_helpplus;
    this_data_above=sparse(this_dataplus.*(this_dataplus>0));
    this_data_above=this_data_above.*(this_data2>0); 
    if (s_hd~=1)
        this_data_above=max(this_data_above);	
    end
    this_data_above(1:s_before2)=0;
    this_data_above(s_ld-s_after2+1:s_ld)=0;
    this_data_above=sparse(this_data_above);
    v_peaks=[];
    [s_ceiling,s_findpeaks]=max(this_data_above);
    while (s_ceiling>0)
        if (~isempty(s_findpeaks))
            v_peaks=[v_peaks s_findpeaks]; 
            this_data_above(s_findpeaks-s_before:s_findpeaks+s_after)=0; 
        end
        [s_ceiling,s_findpeaks]=max(this_data_above);
    end;
    
elseif(Args.NegativePositive) % positive and negative triggering
    % negative triggering part
    v_plusmean_minusthres=floor(v_demean-v_threshold');                
    m_helpminus=v_plusmean_minusthres*ones(1,s_ld);
    this_dataminus=data-m_helpminus; 
    this_data_below=sparse(this_dataminus.*(this_dataminus<0)); 
    this_data_below=this_data_below.*(this_data2<0); 
    if (s_hd~=1)
        this_data_below=min(this_data_below);
    end
    this_data_below(:,1:s_before2)=0;
    this_data_below(:,s_ld-s_after2+1:s_ld)=0;
    this_data_below=sparse(this_data_below);
    v_peaks=[];
    [s_floor,s_findpeaks]=min(this_data_below); 
    while (s_floor<0)
        if (~isempty(s_findpeaks))
            v_peaks=[v_peaks s_findpeaks]; 
            this_data_above(s_findpeaks-s_before:s_findpeaks+s_after)=0;                         
            this_data_below(s_findpeaks-s_before:s_findpeaks+s_after)=0; 
        end;
        [s_floor,s_findpeaks]=min(this_data_below); 
    end;
    
    % positive triggering part             
    v_plusmean_plusthres=ceil(v_demean+v_threshold');
    m_helpplus=v_plusmean_plusthres*ones(1,s_ld);                 
    this_dataplus=data-m_helpplus; 
    this_data_above=sparse(this_dataplus.*(this_dataplus>0)); 
    this_data_above=this_data_above.*(this_data2>0);                
    if (s_hd~=1)
        this_data_above=max(this_data_above);	
    end
    this_data_above(1:s_before2)=0;	
    this_data_above(s_ld-s_after2+1:s_ld)=0; 
    this_data_above=sparse(this_data_above);
    [s_ceiling,s_findpeaks]=max(this_data_above);
    while (s_ceiling>0)
        if (~isempty(s_findpeaks))
            v_peaks=[v_peaks s_findpeaks]; 
            this_data_above(s_findpeaks-s_before:s_findpeaks+s_after)=0; 
            this_data_below(s_findpeaks-s_before:s_findpeaks+s_after)=0; 
        end
        [s_ceiling,s_findpeaks]=max(this_data_above);
    end;
else % Negative triggering ONLY
    % 	v_plusmean_plusthres=ceil(v_demean+v_threshold');	%BG- upper threshold
    % SCY - we have to floor to make sure we are safely beyond threshold
    v_plusmean_minusthres=floor(v_demean-v_threshold');	%BG- lower threshold
    
    % 	% make sure that v_threshold is horizontal
    % 	m_helpplus=v_plusmean_plusthres*ones(1,s_ld); 
    % make sure that v_threshold is horizontal
    m_helpminus=v_plusmean_minusthres*ones(1,s_ld); 
    
    % PROCESSING THE UNIT DATA
    % OK. I just try this one. I wish to extract the spikes in a funky way. 
    % Instead of going the traditional way, which consists in going from early 
    % latencies to late latencies and to pick the spikes as you meet them,
    % I plan on picking them "from above", which means that I will slowly lower 
    % a threshold (the ceiling) and every time a spike touches the ceiling, I 
    % just remove it and place a refractory period around it.
    % The idea is that this way, I'm sure to pick all the big spikes first 
    % and I'm sure to not forget them. While in the traditional way, they may 
    % get masked by a small spike, that immediately precedes them
    % because of the refractory period.
    %
    % The script is a little bit twisted because I want to make it run as 
    % fast as I can. So I try to avoid loops as much as I can.	
    % It starts, for this purpose, with a reformatting of the data, and the 
    % creation of a couple of tools I will use thereafter.	
    % I start with the positive threshold.
    % the first thing is to remove the individual threshold for each channel, 
    % so that they now have a common threshold which is zero.
    
    % substract the mean and substract the threshold. now, all the positive 
    % thresholds are set to zero.
    % 	this_dataplus=data-m_helpplus; 
    % substract the mean and add the threshold. now, all the negative 
    % thresholds are set to zero.
    % SCY - we really want to add to the data but since m_helpminus is 
    % negative we have to subtract
    this_dataminus=data-m_helpminus; 
    
    % simplify the data: find peaks or valleys that are above or below thresholds
    % this_data_above contains only the data values above threshold (rest is 0)
    % 	this_data_above=sparse(this_dataplus.*(this_dataplus>0)); 
    % 	% this_data_above contains only the data values above threshold (rest is 0) 
    % 	% that are local maxima
    % 	this_data_above=this_data_above.*(this_data2>0); 
    % same thing for this_data_below
    this_data_below=sparse(this_dataminus.*(this_dataminus<0)); 
    this_data_below=this_data_below.*(this_data2<0); 
    
    % 	% BG- so now this_data (above & below) only contains the points that are 
    % 	% local maximum or minimums
    % 	% above or below the thresholds respectively from the original data.  All 
    % 	% the rest are zeros.
    % 	
    % 	% BG- finds max for each column - so finds max point from all channels at 
    % 	% each time.
    % 	% BG- if using electrodes(s_hd==1) then the max is the value.
    % 	if (s_hd~=1)
    % 		this_data_above=max(this_data_above);	
    % 	end
    % 	% BG- just renamed v_maxdata
    % 	% SCY - redundant
    % 	% v_selection_plus=[v_maxdata];		
    % 	% BG- sets max to zero at the very beginning and end of dataset.
    % 	this_data_above(1:s_before+1)=0;	
    % 	% this is to avoid seeking spikes at the very beginning of the chunk and 
    % 	% the very end.
    % 	this_data_above(s_ld-s_after:s_ld)=0; 
    % 	% I know we may miss 1 or 2 spikes that way, if we are extremely unlucky. 
    % 	% but I take the risk, it's one every couple of seconds in the absolute 
    % 	% worst case.
    % 	% SCY - redundant
    % 	% v_selection_plus=v_selection_plus.*(v_selection_plus>0);	
    % 	% v_selection_plus is matrix of maximum peaks from all channels and all 
    % 	% zeros if there is not a maximum there
    % 	this_data_above=sparse(this_data_above);	
    % 	% BG- maxdata is now the largest peak of the data
    % 	% s_maxdata=max(v_selection_plus);	
    
    % I do exactly the same preparation for the negative thresholds.
    if (s_hd~=1)
        this_data_below=min(this_data_below);
    end
    
    % SCY - redundant
    % v_selection_minus=[v_mindata];
    this_data_below(:,1:s_before2)=0;   %BG only first ten
    % this is to avoid seeking spikes at the very beginning of the chunk and 
    % the very end.
    this_data_below(:,s_ld-s_after2+1:s_ld)=0; %BG only last 21
    % v_selection_minus=v_selection_minus.*(v_selection_minus<0);
    this_data_below=sparse(this_data_below);
    % most minimum value of entire data set
    % s_mindata=min(v_selection_minus);		
    
    v_peaks=[];	%this will be the matrix containing the indices of the waveforms.
    
    % Anyway, I follow the same algo to LIFT THE FLOOR, instead of lowering 
    % the ceiling.
    % NOTE HERE: data are supposed to be integer, and they are.
    % BG- findpeaks is the index of the first valley that touchs the floor 
    [s_floor,s_findpeaks]=min(this_data_below); 
    while (s_floor<0)
        if (~isempty(s_findpeaks))
            % the first peak we found that touches the ceiling
            v_peaks=[v_peaks s_findpeaks]; 
            % we make sure we won't select any other peak close to this one.
            %			this_data_above(s_findpeaks-s_before:s_findpeaks+s_after)=0; 
            % we make sure we won't select any other peak too close to this one.
            this_data_below(s_findpeaks-s_before:s_findpeaks+s_after)=0; 
        end; % if (~isempty(s_findpeaks))
        % BG- find the floor for the next minimum valley
        [s_floor,s_findpeaks]=min(this_data_below); 
    end; % while (s_floor<0)
    % We're done. The 0 touched the floor.
    % BG- so vpeaks is a matrix of the indices of the waveforms found by lifting 
    % the floor
    
    % 	% we now do exactly the same for the positive values. but because we have 
    % 	% already selected all these spikes using the floor, there are a lot of 
    % 	% forbidden zones where I can no find other spikes these forbidden zones 
    % 	% correspond to refractory regions of spikes that have already been 
    % 	% selected.	
    % 	% Now we start LOWERING THE CEILING
    % 	% NOTE HERE: data are supposed to be integer, and they are.
    % 	[s_ceiling,s_findpeaks]=max(this_data_above);
    % 	while (s_ceiling>0)
    % 		if (~isempty(s_findpeaks))
    % 			v_peaks=[v_peaks s_findpeaks]; 
    % 			% we make sure we won't select any other peak close to this one.
    % 			this_data_above(s_findpeaks-s_before:s_findpeaks+s_after)=0; 
    %         end % if (~isempty(s_findpeaks))
    % 		[s_ceiling,s_findpeaks]=max(this_data_above);
    % 	end; % while (s_ceiling>0)
    % 	% We're done. The ceiling touched the floor.
end

v_peaks=sort(v_peaks); % BG- because some were found from the top also
num_peaks=size(v_peaks,2);   % this is how many waveforms were found  

waveforms=[];
times=[];

for s_p=1:num_peaks
    % that's the actual point number, starting at the beginning of the bin 
    % file.
    s_latency_pts=v_peaks(s_p); 
    % time is in 100th of milliseconds in the sorter.
    s_latency_ms=floor(1000000*s_latency_pts/sampling_rate); 
    % BG- calculating times for all the spikes
    % BG- no divide by 4 % We divide by 4 in accordance with bn4pedro. 
    
    m_help=data(:,v_peaks(s_p)-s_before2:v_peaks(s_p)+s_after2); 
    % BG- m_help is the extracted waveform
    % concatonate all channels of that waveform into a single row.
    if s_hd~=1
        v_help=reshape(m_help',1,size(m_help,1)*size(m_help,2)); 
    else
        v_help=m_help;
    end
    
    times=[times; s_latency_ms];
    % waveforms is now a matrix containing all of the waveforms for all 
    % the channels
    % each waveform set is on a different row.
    % when writing the .dat file a 0&3 must be written between each set 
    % of waveforms!!
    waveforms=[waveforms; v_help];	
end
