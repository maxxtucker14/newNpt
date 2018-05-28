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

% sd3 = find(data > (m + 3*sd)); % finds index of data which are above 3sd from mean
sd1 = data > (m + 1*sd); % finds if data are above 1sd from mean

% % SPW event (maximum)
% spw = []; % stores the time that marks SPW event
% 
% max = 0; % dummy variable to store max in each consecutive section
% maxi = 0;
% prev = 0; % dummy variable to store prev data index for comparison
% 
% for s = 1:length(sd3)
%     i = sd3(s);
%     if prev == i - 1
%         if max < data(i)
%             max = data(i);
%             maxi = i;
%         end
%         
%     elseif prev == 0
%         
%     else
%         spw = [spw, maxi]; % change this for efficiency
%         max = data(i);
%         maxi = i;
%     end
%     
%     prev = i;
% end
% 
% % Beginning and end of ripple
% ib = strfind([0; sd1; 0]', [0 1]);
% ie = strfind([0; sd1; 0]', [1 0]);
% 
% % if ib(1)>ie(1)
% %     ib = [0 ib];
% % elseif ib(end) > ie(end)
% %     ie = [ie length(data)];
% % end
% % 
% % if length(ib) ~= length(ie)
% %     fprintf('ERROR:Check nptSwr code')
% % end
% 
% j = 1; % for iterating through spw
% swr = zeros(length(spw),3);
% 
% 
% for i = 1:length(ib)
%     if ib(i) <= spw(j) && ie(i) >= spw(j)
%         swr(j,1) = ib(i);
%         swr(j,2) = spw(j);
%         swr(j,3) = ie(i);
%         j = j+1;
%     end
% end
% 
% if j ~=length(spw)
%     fprintf('ERROR:Check nptSwr code')
% end

% Beginning and end of ripple
ib = strfind([0; sd1]', [0 1]);
ie = strfind([sd1; 0]', [1 0]);

swr = zeros(length(ib),3);
iswr = 1;

% SPW event
for i = 1:length(ib)
    if any(data(ib(i):ie(i)) > (m + 3*sd))
        [m, im] = max(data(ib(i):ie(i)));
        swr(iswr,1) = ib(i)+im-1;
        swr(iswr,2) = ib(i);
        swr(iswr,3) = ie(i);
        iswr = iswr + 1;
    end
end

swr = swr(any(swr,2),:); %remove extra rows with 0s

end