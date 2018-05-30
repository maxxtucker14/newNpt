function swr = nptSwr(varargin)
% detects swr in a given data
%
% returns matrix swr (index)
% 1st column: SPW event
% 2nd column: start of the ripple
% 3rd column: end of the ripple

switch nargin
    case 1
        data = varargin{1};
%         sd_lb = 1;      % # of sd from mean to mark the start and end of ripple
%         sd_ub = 3;      % # of sd from mean for ripple detection threshold
        rmsFlag = 0;    % determine whether to compute rms
    
%     case 2
%         data = varargin{1};
%         sd_lb = 1;
%         sd_ub = varargin{2};    % created incase we wanted it to be 4
%         rmsFlag = 0; 
%     
%     case 4                      % note there is no case 3
%         data = varargin{1};
%         sd_lb = 1;
%         sd_ub = varargin{2};
%         rmsFlag = varargin{3};
%         Fs = varargin{4};
%         window = 0.02;          % window length (s)
%         overlap = 0.005;        % overlap (s)
%         zeropad = 1;            % zero pad for last window
    
    otherwise
		error('Wrong number of input arguments')
end

% calculates rms of the data
if rmsFlag
    data = nptRms(data,window*Fs,overlap*Fs,zeropad);
end

%% swr detection
m = mean(data);
sd = std(data);

sd1 = data >= (m + sd); % finds if data are above 1sd from mean

% Beginning and end of ripple
ib = strfind([0 sd1], [0 1]); % finds all potential starting points of ripple
ie = strfind([sd1 0], [1 0]); % finds all potential ending points of ripple

swr = zeros(length(ib),3); % predefines maximum matrix size. The extra rows are removed later
iswr = 1; % keeps track of row of matrix filled

% SPW event
for i = 1:length(ib)
    if any(data(ib(i):ie(i)) >= (m + 3*sd)) % finds if any points are above 3sd from mean
        [vm, im] = max(data(ib(i):ie(i)));
        swr(iswr,1) = ib(i)+im-1;
        swr(iswr,2) = ib(i);
        swr(iswr,3) = ie(i)+1;
        iswr = iswr + 1;
    end
end

swr = swr(any(swr,2),:); %remove extra rows with 0s (might be more efficient to remove all rows from iswr)

end