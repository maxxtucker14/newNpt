function nptPlotFFT(x, Fs);
%   nptPlotFFT(X,FS) plots the magnitude of the FFT of the signal x 
%   with sampling frequency FS. If X is a matrix, the FFT is applied
%   to each column and the mean and standard deviation of the 
%   magnitude across columns are plotted.
%   This function was derived from Technical Note 1702. For more 
%   information, please see the following URL:
%   http://www.mathworks.com/support/tech-notes/1700/1702.html

[MX,f] = nptFFTMag(x,Fs);
% get size of MX
mxc = size(MX,2);
% take the tranpose so we can use mean and std easily
MXT = MX';
% get the mean magnitude across columns of MX
mxMean = mean(MXT);
plot(f,mxMean);
% if there were more than 1 time series, plot the standard deviation
if(mxc>1)
    mxStd = std(MXT);
    hold on
    plot(f,mxMean+mxStd,'c')
    plot(f,mxMean-mxStd,'c')
    hold off
end
