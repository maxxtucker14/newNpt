function r = getGratingReversals(a,b,p,duration,varargin)
%getGratingReversals Get Buracas-like direction reversals
%   R = getGratingReversals(A,B,P,DURATION,VARARGIN) returns a list of
%   phase (or palette) indices that produces grating movements ala 
%   Buracas et al. Direction reversals from the anti-preferred to the
%   preferred direction are followed by A refreshes in the preferred
%   direction, which are followed by B refreshes in the anti-preferred
%   direction, after which the direction switches to the preferred
%   direction with probability P at each refresh. DURATION specifies 
%   the duration of the stimulus in seconds that the algorithm will
%   attempt to approximate.
%
%   These are the optional input arguments:
%      'FrameRate' - frame rate of the stimulus in Hz (default is 25).
%      'FileName' - name of file to use to output the sequence of 
%                   refreshes (default is '');
%      'ShowPlot' - plots the phase sequence and amplitude spectrum.
%      'ShowGrating' - animates a grating using the phase sequence.
%      'ShowAll' - equivalent to using both 'ShowPlot' and 'ShowGrating'.
%      'GratingTF' - defines the desired temporal frequency of the
%                    grating in cycles/second (default is 1).
%
%   r = getGratingReversals(a,b,p,duration,'framerate',25,'filename,'',...
%           'showplot','showgrating','gratingsize',100,'gratingsf',10,...
%           'gratingtf',1,'framepause',0.1);

Args = struct('FrameRate',25,...
			  'FileName','',...
			  'ShowPlot',0, ...
			  'ShowGrating',0, ...
			  'GratingTF',1);

Args = getOptArgs(varargin,Args,'flags',{'ShowPlot','ShowGrating'},...
					'aliases',{'ShowAll',{'ShowPlot','ShowGrating'}});

% get total number of frames in duration
nrefs = duration*Args.FrameRate;

% get random numbers
probs = rand(1,nrefs);

% find values smaller than p
pind = find(probs<p);

% find frames between pind
pframes = [pind(1) diff(pind)];
pfl = size(pframes,2);

% create vector of a frames
avec = repmat(a,1,pfl);

% list of refreshes can be returned by reshaping pframes and avec into
% a column vector since reshape grabs values columnwise
seq = reshape([avec; (pframes-1+b)],[],1);

% find cummulative sum to trim sequence to duration
cseq = cumsum(seq);
% find first index that exceeds specified duration
csi = find(cseq>nrefs);
% return vector before csi
rl = csi(1) - 1;
% r1 used for plotting below
r1 = seq(1:rl);
% create memory for r
rlength = cseq(rl) + 1;
r = zeros(rlength,1);
% set the first palette index to 0 since indices are for Presenter and
% thus are zero-indexed
r(1) = 0;

% get number of phases, subtract 1 since palette index are 0-indexed
nphases = round(Args.FrameRate/Args.GratingTF);
lastphase = nphases - 1;
% set up palette sequence
pseq = (0:lastphase)';
palettedir = -1;
% first index already set to 0 so start with second index
rind = 2;
for ci = 1:length(r1)
	for ri = 1:r1(ci)
		pseq = circshift(pseq,palettedir);
		% indices are zero based
		r(rind) = pseq(1);
		rind = rind + 1;
	end
	palettedir = -palettedir;
end

if(~isempty(Args.FileName))
	fid = fopen(Args.FileName,'wt');
	fprintf(fid,'# generated %s by %s using:\n',date,mfilename);
	fprintf(fid,'# a: %d, b: %d, p: %f, duration: %f seconds, frame rate: %d Hz\n',...
					a,b,p,duration,Args.FrameRate);
	fprintf(fid,'# first number corresponds to number of phases, followed by 0-indexed phase indices.\n');
	fprintf(fid,'%d\n',nphases);
	fprintf(fid,'%d\n',r);
	fclose(fid);
end

if(Args.ShowPlot)
	% generate vectors of 1's and 0's that are half of rl and then
	% reshape to get a vector of alternating 1's and 0's
	rl2 = ceil(rl/2);
	vec10 = [ones(1,rl2); zeros(1,rl2)];
	vec = reshape(vec10,[],1);
	% if rl is even add 1 at the end
	if(rem(rl,2)==0)
		% add another 1 at the end of vec
		vec = [vec; 1];
	end
	% plot sequence
	clf
	subplot(2,1,1)
	stairs([1; cseq(1:rl)],vec);
	ylim([-0.05 1.05]);
	xlabel('Frame Number');
	set(gca,'YTick',0:1,'YTickLabel',['Anti-pref';'Preferred']);
	title(['a = ' num2str(a) ', b = ' num2str(b) ', p = ' num2str(p,'%.2f')])
	
	% plot phase sequence
	subplot(2,1,2)
    % convert phases to degrees    
    phasedeg = r*360/nphases;
    plot(phasedeg,'o-')
	ylim([0 360])
	set(gca,'YTick',0:60:360);
	xlabel('Frame Number');
	ylabel('Temporal Phase');
end

if(Args.ShowGrating)
	% create grating
	figure
	% add 1 to r and nphases since both are 0-indexed
	gl = showGratingSeq(nphases,r+1,varargin{:});
	figure
	% take fft of each column which contains time series of gray levels
	if(rem(rlength,2))
		rlength = rlength - 1;
	end
	glf = fft(gl(1:rlength,:));
	npts2 = rlength/2;
	% code from PlotFFT
	fftx = glf(1:(npts2+1),:);
	mx = abs(fftx) * 2 / rlength;
	mx([1 end],:) = mx([1 end],:)/2;
	x = (0:npts2)*Args.FrameRate/rlength;
	plot(x,mx,'o-')
	xlabel('Frequency (Hz)')
	ylabel('Amplitude')
	title('Amplitude Spectra of graylevels')
	hold off
end
