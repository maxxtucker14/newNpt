function ind=groupfind(L)
%GROUPFIND   Find upper and lower indices of nonzero groups
%            with vectorized and simple code.
%   I = GROUPFIND(X) returns an N-by-2 matrix where N is the
%   number of groups, the first column gives the index where
%   each group starts, and the second column gives the index
%   where each group ends.  A group is a stretch of consecutive
%   nonzero values.
%
%   % EXAMPLE:  Find & annotate all valleys of a wave
%    time=0:0.01:6;
%    breaths=sin(2*pi*(0.666.*time+rand));
%    plot(time,breaths,':'),hold on
%    ind=groupfind(breaths<0);
%    text(mean(time(ind)'),-1.1.*ones(1,size(ind,1)),'Valley')
%    ylim([-1.5 1.5])


% By Mickey Stahl 3/11/02
% Aspiring Developer

% I had originally written the following few lines
% to do this task, but Duane Hanselman has improved
% upon this approach.  In the interest of encouraging
% good style, I have commented out my lines and included
% his.
% 
% *** OLD CODE
%    if size(L,1)>1 & size(L,2)>1,
%        error('Input must be a vector.')
%    end
%    temp=find(L~=0);
%    dtemp=diff(temp);
%    ind(:,1)=temp([1 find(dtemp>1)+1])';
%    ind(:,2)=temp([find(dtemp>1) end])';
% ***

% the following should be much faster
% no need to restrict it to vectors
% use single number indexing so it works for any dimension input

% modified by Duane Hanselman
% Unaspiring Developer

temp=find(L(:));           % make input a column vector, then find nonzeros
idx=find(diff(temp)>1);    % call find(diff(temp)>1) just once, not twice
ind(:,2)=temp([idx; end]); % create 2nd column first to allocate all memory
ind(:,1)=temp([1; idx+1]); %  needed for output once, not twice.
