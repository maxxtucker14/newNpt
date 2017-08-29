function [ndata,nCols] = nptReshapeData(odata,nChannels)
%nptReshapeData Reshape data to the desired number of channels
%   [DATA,COLS] = nptReadStreamerFile(ORIG_DATA,NUMBER_OF_CHANNELS) 
%   reshapes ORIG_DATA into NUMBER_OF_CHANNELS and returns it in DATA. 
%   This function assumes that ORIG_DATA has been padded with zeros so
%   it drops points from ORIG_DATA to get an even matrix with rows
%   equal to NUMBER_OF_CHANNELS. The number of cols in DATA is also
%   returned in COLS.
%
%   Dependencies: None.

% get total number of data points in odata
os = size(odata);
oPts = os(1) * os(2);
data = reshape(odata,1,oPts);

% throw out extra points that is going to make the matrix uneven
nPts = floor(oPts / nChannels)*nChannels;
nCols = nPts / nChannels;
ndata = reshape(data(1:nPts),nChannels,nCols);
