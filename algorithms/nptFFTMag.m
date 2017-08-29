function [MX,f] = nptFFTMag(x, Fs)
%nptFFTMag Computes FFT of signal
%   [MX,F] = nptFFTMag(X,FS) returns the magnitude, MX, of the FFT 
%   of the signal X with sampling frequency FS. If X is a matrix, 
%   the FFT is applied to each column and returned. The frequency 
%   vector, F, is also returned for easy plotting.
%   This function was derived from Technical Note 1702. For more 
%   information, please see the following URL:
%   http://www.mathworks.com/support/tech-notes/1700/1702.html

% make sure x is column vector if one of the dimensions is 1
x = vecc(x);
% get number of rows in x
xrows = size(x,1);
Fn = Fs/2;                  % Nyquist frequency
NFFT = 2.^(ceil(log(xrows)/log(2)));
% Take fft, padding with zeros, length(FFTX)==NFFT
FFTX = fft(x,NFFT);
NumUniquePts = ceil((NFFT+1)/2);
% fft is symmetric, throw away second half
FFTX = FFTX(1:NumUniquePts,:);
MX = abs(FFTX);            % Take magnitude of X

% get size of MX
% mxr = size(MX,1);
% Multiply by 2 to take into account the fact that we
% threw out second half of FFTX above
% get next to last index 
% nextLasti = mxr - 1;
% MX(2:nextLasti,:) = MX(2:nextLasti,:)*2;

% Scale the FFT so that it is not a function of the 
% length of x.
MX = MX/xrows;
f = (0:NumUniquePts-1)*2*Fn/NFFT;
