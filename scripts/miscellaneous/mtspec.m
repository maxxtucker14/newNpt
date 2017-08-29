function [A, freqvect, timevect]=mtspec(TS,NW,K,pad,window,winstep,Fs);

% Multitaper Time-Frequency Spectrum
% [A, freqvect, timevect]=mtspec(TS,NW,K,pad,window,winstep,Fs);
% TS : input time series
% NW = time bandwidth parameter (e.g. 3 or 4)
% K = number of data tapers kept, usually 2*NW -1 (e.g. 5 or 7 for above)
% pad = padding for individual window. Usually, choose power
% of two greater than but closest to size of moving window.
% window = length of moving window
% winstep = number of of timeframes between successive windows

% make TS a row vector
TS = TS(:)';
% get slepians
[E V] = dpss(window,NW,'calc');
[dum N] = size(TS);
% get number of windows in data
nwindows = floor( (N-window)/winstep ) + 1;
% get number of positive frequencies
nfreqs = pad/2 + 1;
% get indices selecting positive frequencies
indfreqs = 1:nfreqs;
% pre-allocate memory
A = zeros(nfreqs,nwindows);
for j= 1:nwindows
	TSM = detrend( TS( (j-1)*winstep+[1:window] ) )';
	J1 = fft(TSM(:,ones(1,K)).*(E(:,1:K)),pad);
    % get positive frequencies
    J2 = J1(indfreqs,:);
    % get power spectrum and then average across slepians
	A(:,j) = mean((J2.*conj(J2)),2);
end

timevect = window/(2*Fs) + (0:(nwindows-1)) * winstep/Fs;
freqvect = (0:(pad/2))*Fs/1000;

if(nargout==0)
	imagesc(timevect, freqvect, A)
	xlabel('Time (seconds)'), ylabel('Frequency (Hz)')
end