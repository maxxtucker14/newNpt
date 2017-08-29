function [co,ang,fo,to] = cohgram(x,y,nfft,fs,window,noverlap,varargin)

% function [co,ang,fo,to] = cohgram(x,y,nfft,fs,window,noverlap,flag)
%
% compute time localized coherences over different trials 
% between x and y.
% input: x contains in each column the different trials
%         size(x) = timepoints * ntrials;
% out: co = the coherence map
%      fo = frequenct vector. Number of freqs = fs/2+1;
%      to = times of window centers at wich the coherence was computed.
%           in units of msec. distance of two points = window-noverlap;
%      ang = the angle map. Most values might not be siginificant. Threshold 
%            it with (co>0.3) or something!
%
%  flag is optional and can be 0 for classical matlab coherence
%          or 1 for more localized results (default).
%
% Last modif. 07.06.02 C.Kayser


ldata=size(x,1);
ncol=((ldata-window)/(window-noverlap))+1;
stepw=window-noverlap;

if length(varargin)>0
  flag = varargin{1};
  if isempty(findstr(num2str(flag),'10'))
	fprintf('flag must be 0 or 1\n');
	return;
  end
else
  flag = 1;
end

if floor(ncol)~=ncol
  ncol = floor(ncol);
  fprintf('trial length truncated to match window settings.\n');
end
co = zeros(nfft/2+1,ncol);
ang =  zeros(nfft/2+1,ncol);

for col=1:ncol
  t1=(col-1)*stepw+1;
  xwin=x(t1:t1+window-1,:);
  ywin=y(t1:t1+window-1,:);
  xwin=xwin(:);
  ywin=ywin(:);
  %[co(:,col),fo] = cohere(xwin,ywin,nfft,fs,window,0);
  
  [MyCh,ClasCh,fo] = ComplCoh(xwin,ywin,nfft,fs,window,0);
  
  if flag ==1
	[co(:,col)] = abs(MyCh);
	ang(:,col) = angle(MyCh);
  else
	[co(:,col)] = abs(ClasCh);
	ang(:,col) = angle(ClasCh);
		
  end
  
end



to=(([1:ncol]-1).*stepw)+window/2;

