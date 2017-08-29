function PlotFFT(x, Fs);
%   PlotFFT(X,FS) plots the magnitude of the FFT of the signal x 
%   with sampling frequency FS. If X is a matrix, the FFT is applied
%   to each column and the mean and standard deviation of the 
%   magnitude across columns are plotted.
%   This function was derived from Technical Note 1702. For more 
%   information, please see the following URL:
%   http://www.mathworks.com/support/tech-notes/v5/1700/1702.shtml

% make sure x is column vector if one of the dimensions is 1
x = vecc(x);
Fn=Fs/2;                  % Nyquist frequency
NFFT=2.^(ceil(log(length(x))/log(2)));
% Take fft, padding with zeros, length(FFTX)==NFFT
FFTX=fft(x,NFFT);
NumUniquePts = ceil((NFFT+1)/2);
% fft is symmetric, throw away second half
FFTX=FFTX(1:NumUniquePts,:);
MX=abs(FFTX);            % Take magnitude of X
% get size of MX
[mxr,mxc] = size(MX);
% Multiply by 2 to take into account the fact that we
% threw out second half of FFTX above
MX(2:(end-1),:) = MX(2:(end-1),:)*2;
% MX=MX*2;
% MX(1,:)=MX(1,:)/2;   % Account for endpoint uniqueness
% MX(mxr,:)=MX(mxr,:)/2;
% Scale the FFT so that it is not a function of the 
% length of x.
MX=MX/size(x,1);
f=(0:NumUniquePts-1)*2*Fn/NFFT;
% take the tranpose so we can use mean and std easily
MXT = MX';
% get the mean magnitude across rows of MX
% this way if there is only 1 data set, the mean will be the same as data
mxMean = mean(MXT,1);
plot(f,mxMean);
% if there were more than 1 time series, plot the standard deviation
if(mxc>1)
    mxStd = std(MXT);
    hold on
    plot(f,mxMean+mxStd,'c')
    plot(f,mxMean-mxStd,'c')
    hold off
end
