function [MyCoh,Coh,f] = ComplCoh(varargin)

% Complex Coherence function estimate.
%
%   [Cxy,CCxy,f] = ComplCoh(X,Y,NFFT,Fs,WINDOW,NOVERLAP) estimates the coherence of X and Y
%   using Welch's averaged periodogram method.  Coherence is a function
%   of frequency with values between 0 and 1 that indicate how well the
%   input X corresponds to the output Y at each frequency.  X and Y are 
%   divided into overlapping sections, each of which is detrended, then 
%   windowed by the WINDOW parameter, then zero-padded to length NFFT.  
%   The magnitude squared of the length NFFT DFTs of the sections of X and 
%   the sections of Y are averaged to form Pxx and Pyy, the Power Spectral
%   Densities of X and Y respectively. The products of the length NFFT DFTs
%   of the sections of X and Y are averaged to form Pxy, the Cross Spectral
%   Density of X and Y. The coherence Cxy is given by
%       Cxy = (abs(Pxy).^2)./(Pxx.*Pyy)
%   Cxy has length NFFT/2+1 for NFFT even, (NFFT+1)/2 for NFFT odd, or NFFT
%   if X or Y is complex. If you specify a scalar for WINDOW, a Hanning 
%   window of that length is used.  Fs is the sampling frequency which does
%   not effect the cross spectrum estimate but is used for scaling of plots.
%
% 
%  Coh is the classical coherence ala Matlab, but wich complex arguments.
%  MyCoh is a better localized estimate of the coherence, also including the phase.
%  
% Last Modif 07.06.02 C.Kayser

error(nargchk(2,7,nargin))
x = varargin{1};
y = varargin{2};
[msg,nfft,Fs,window,noverlap,p,dflag]=psdchk(varargin(3:end),x,y);
 error(msg)
    
% compute PSD and CSD
window = window(:);
n = length(x);		% Number of data points
nwind = length(window); % length of window
if n < nwind    % zero-pad x , y if length is less than the window length
    x(nwind)=0;
    y(nwind)=0;  
    n=nwind;
end
x = x(:);		% Make sure x is a column vector
y = y(:);		% Make sure y is a column vector
k = fix((n-noverlap)/(nwind-noverlap));	% Number of windows
					% (k = fix(n/nwind) for noverlap=0)
index = 1:nwind;

Pxy = zeros(nfft,1);
Pxx = zeros(nfft,1);
Pyy = zeros(nfft,1);
MyXY = zeros(nfft,1);
for i=1:k
    if strcmp(dflag,'none')
        xw = window.*x(index);
        yw = window.*y(index);
    elseif strcmp(dflag,'linear')
        xw = window.*detrend(x(index));
        yw = window.*detrend(y(index));
    else
        xw = window.*detrend(x(index),0);
        yw = window.*detrend(y(index),0);
    end
    index = index + (nwind - noverlap);
    Xx = fft(xw,nfft);
    Yy = fft(yw,nfft);
    Xx2 = abs(Xx);  
    Yy2 = abs(Yy);  
	Xy2 = Yy.*conj(Xx);
	Pxx = Pxx + Xx2.^2;
	Pyy = Pyy + Yy2.^2;
	Pxy = Pxy + Xy2;
	MyXY = MyXY + Xy2./((Xx2).*(Yy2));
end

% Select first half
if ~any(any(imag([x y])~=0)),   % if x and y are not complex
    if rem(nfft,2),    % nfft odd
        select = [1:(nfft+1)/2];
    else
        select = [1:nfft/2+1];   % include DC AND Nyquist
    end
	MyXY = MyXY(select);
	Pxx = Pxx(select);
	Pyy = Pyy(select);  
	Pxy = Pxy(select);
else
    select = 1:nfft;
end

freq_vector = (select - 1)'*Fs/nfft;
f = freq_vector;
i = sqrt(-1);
Coh = exp(i*angle(Pxy)).*(abs(Pxy).^2)./(Pxx.*Pyy);
MyCoh = (MyXY./max(abs(MyXY(:))))*max(abs(Coh));

% set up output parameters
if (nargout == 3),
  
elseif (nargout == 1),

elseif (nargout == 0),   % do a plot
   newplot;
   plot(freq_vector,Coh), grid on
   xlabel('Frequency'), ylabel('Coherence Function Estimate');
end


% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

function [msg,nfft,Fs,window,noverlap,p,dflag] = psdchk(P,x,y)
%PSDCHK Helper function for PSD, CSD, COHERE, and TFE.
%   [msg,nfft,Fs,window,noverlap,p,dflag]=PSDCHK(P,x,y) takes the cell 
%   array P and uses each element as an input argument.  Assumes P has 
%   between 0 and 7 elements which are the arguments to psd, csd, cohere
%   or tfe after the x (psd) or x and y (csd, cohere, tfe) arguments.
%   y is optional; if given, it is checked to match the size of x.
%   x must be a numeric vector.
%   Outputs:
%     msg - error message, [] if no error
%     nfft - fft length
%     Fs - sampling frequency
%     window - window vector
%     noverlap - overlap of sections, in samples
%     p - confidence interval, [] if none desired
%     dflag - detrending flag, 'linear' 'mean' or 'none'

%   Author(s): T. Krauss, 10-28-93
%   Copyright 1988-2000 The MathWorks, Inc.
%       $Revision: 1.1 $  $Date: 2006/02/09 18:46:58 $

msg = [];

if length(P) == 0 
% psd(x)
    nfft = min(length(x),256);
    window = hanning(nfft);
    noverlap = 0;
    Fs = 2;
    p = [];
    dflag = 'none';
elseif length(P) == 1
% psd(x,nfft)
% psd(x,dflag)
    if isempty(P{1}),   dflag = 'none'; nfft = min(length(x),256); 
    elseif isstr(P{1}), dflag = P{1};       nfft = min(length(x),256); 
    else              dflag = 'none'; nfft = P{1};   end
    Fs = 2;
    window = hanning(nfft);
    noverlap = 0;
    p = [];
elseif length(P) == 2
% psd(x,nfft,Fs)
% psd(x,nfft,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}),   dflag = 'none'; Fs = 2;
    elseif isstr(P{2}), dflag = P{2};       Fs = 2;
    else              dflag = 'none'; Fs = P{2}; end
    window = hanning(nfft);
    noverlap = 0;
    p = [];
elseif length(P) == 3
% psd(x,nfft,Fs,window)
% psd(x,nfft,Fs,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}), Fs = 2;     else    Fs = P{2}; end
    if isstr(P{3})
        dflag = P{3};
        window = hanning(nfft);
    else
        dflag = 'none';
        window = P{3};
        if length(window) == 1, window = hanning(window); end
        if isempty(window), window = hanning(nfft); end
    end
    noverlap = 0;
    p = [];
elseif length(P) == 4
% psd(x,nfft,Fs,window,noverlap)
% psd(x,nfft,Fs,window,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}), Fs = 2;     else    Fs = P{2}; end
    window = P{3};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isstr(P{4})
        dflag = P{4};
        noverlap = 0;
    else
        dflag = 'none';
        if isempty(P{4}), noverlap = 0; else noverlap = P{4}; end
    end
    p = [];
elseif length(P) == 5
% psd(x,nfft,Fs,window,noverlap,p)
% psd(x,nfft,Fs,window,noverlap,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}), Fs = 2;     else    Fs = P{2}; end
    window = P{3};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{4}), noverlap = 0; else noverlap = P{4}; end
    if isstr(P{5})
        dflag = P{5};
        p = [];
    else
        dflag = 'none';
        if isempty(P{5}), p = .95;    else    p = P{5}; end
    end
elseif length(P) == 6
% psd(x,nfft,Fs,window,noverlap,p,dflag)
    if isempty(P{1}), nfft = min(length(x),256); else nfft=P{1};     end
    if isempty(P{2}), Fs = 2;     else    Fs = P{2}; end
    window = P{3};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{4}), noverlap = 0; else noverlap = P{4}; end
    if isempty(P{5}), p = .95;    else    p = P{5}; end
    if isstr(P{6})
        dflag = P{6};
    else
        msg = 'DFLAG parameter must be a string.'; return
    end
end

% NOW do error checking
if (nfft<length(window)), 
    msg = 'Requires window''s length to be no greater than the FFT length.';
end
if (noverlap >= length(window)),
    msg = 'Requires NOVERLAP to be strictly less than the window length.';
end
if (nfft ~= abs(round(nfft)))|(noverlap ~= abs(round(noverlap))),
    msg = 'Requires positive integer values for NFFT and NOVERLAP.';
end
if ~isempty(p),
    if (prod(size(p))>1)|(p(1,1)>1)|(p(1,1)<0),
        msg = 'Requires confidence parameter to be a scalar between 0 and 1.';
    end
end
if min(size(x))~=1 | ~isnumeric(x) | length(size(x))>2
    msg = 'Requires vector (either row or column) input.';
end
if (nargin>2) & ( (min(size(y))~=1) | ~isnumeric(y) | length(size(y))>2 )
    msg = 'Requires vector (either row or column) input.';
end
if (nargin>2) & (length(x)~=length(y))
    msg = 'Requires X and Y be the same length.';
end

dflag = lower(dflag);
if strncmp(dflag,'none',1)
      dflag = 'none';
elseif strncmp(dflag,'linear',1)
      dflag = 'linear';
elseif strncmp(dflag,'mean',1)
      dflag = 'mean';
else
    msg = 'DFLAG must be ''linear'', ''mean'', or ''none''.';
end
