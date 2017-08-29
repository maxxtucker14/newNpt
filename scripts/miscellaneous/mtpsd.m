function [pxx,freq]=mtpsd(TS1,NW,K,pad,fs,window,winstep);

% Multitaper spectrum and coherence estimate
% function [pxx,freq]=mtpsd(TS1,NW,K,pad,fs,window,winstep);
% TS1: input time series
% NW = time bandwidth parameter (e.g. 3 or 4)
% K = number of data tapers kept, usually 2*NW -1 (e.g. 5 or 7 for above)
% pad = padding for individual window. Usually, choose power
% of two greater than but closest to size of moving window.
% window = length of moving window
% winstep = number of of timeframes between successive windows
% spec1,: spectrum of ts1 (averaged over windows)


TS1=TS1(:)';
len=length(TS1);
if len<window, window=len;, end
[E V]=dpss(window,NW,'calc');
N=length(TS1);
nwin=max([1 floor((N-window)/winstep)]);
sp1=zeros(nwin, pad);

for ind=1:nwin, %for each window in TS1
	TSM=TS1((ind-1)*winstep+[1:window])';
%    I1=find(TSM);  % I1 will be row vector with indices where spikes occur
%    count1=length(I1); % Number of spikes
%    T=length(TSM);
%    lambda1=count1/T; 
%    fft_0=sum(E(:,1:K)); % Fourier transform of the data tapers at 0 frequency (column vector)
%	 J1=(fft(TSM(:,ones(1,K)).*(E(:,1:K)),pad)-lambda1*fft_0(ones(1,pad),:))';
	J1=fft(TSM(:,ones(1,K)).*(E(:,1:K)),pad)';

	sp1(ind,:)=mean(J1.*conj(J1));
end %for each window in TS1

pxx=abs(mean(sp1,1));


% Select first half
if ~any(any(imag(TS1)~=0)),   % if x is not complex
   if rem(pad,2),    % pad odd
        select = [1:(pad+1)/2];
    else
        select = [1:pad/2+1];   % include DC AND Nyquist
    end
    pxx = pxx(select);
    freq = (select - 1)'*fs/pad;
else
    select = 1:pad;
    pxx = pxx(select);
    freq = (select - 1)'*fs/pad;
    
%	  pxx = fliplr(pxx);
    
end

%plotting the power spectra
if (nargout == 0),   % do a plot
   figure
   titlestring = 'MTM PSD Estimate';
   psdplot(pxx,freq,'Hz','db',titlestring);

%   plot(freq,10*log10(abs(pxx))), grid on
%   xlabel('Frequency'), ylabel('Power Spectrum Magnitude (dB)');
end
