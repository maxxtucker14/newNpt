function [m,s] = getMeanStd(e,n,varargin)
%@eye/getMeanStd Computes standard deviation of eye positions
%   [M,S] = getMeanStd(OBJ,N,VARARGIN) computes the standard deviation of
%   of eye positions from trial N. The following optional input arguments
%   are valid:
%      'DataStart' - followed by index of the first data point to be 
%                    included (default: 1).
%      'DataEnd' - followed by index of the last data point to be
%                  included (default: end).
%
%   [m,s] = getMeanStd(e,n,'DataStart',1,'DataEnd',[]);

Args = struct('DataStart',1,'DataEnd',[]);
Args = getOptArgs(varargin,Args);

% read data file
trialn = num2str(n,'%04i');
% open up the eye file for the trial
filename = [e.sessionname '_eye.' trialn];
fprintf('Reading %s\n',filename);
[data,numChannels,samplingRate,datatype,datalength] = nptReadDataFile(filename);
% set Args.DataEnd to datalength if it is not set
if(isempty(Args.DataEnd))
	Args.DataEnd = datalength;
end
[m,s] = getPositionMeanStd(data(:,Args.DataStart:Args.DataEnd)');
