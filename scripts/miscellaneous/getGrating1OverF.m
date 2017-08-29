function r = getGrating1OverF(beta,duration,varargin)
%getGrating1OverF Get Lee-type 1/f grating movements
%   R = getGrating1OverF(BETA,DURATION,VARARGIN) returns a list of 
%   phase (or palette) indices that produces grating movements that
%   that are 1/f^BETA in the amplitude spectrum. DURATION specifies 
%   the desired duration of the stimulus in seconds.
%
%   These are the optional input arguments:
%      'FrameRate' - frame rate of the stimulus in Hz (default is 25).
%      'MinTF' - Minimum temporal frequency of the sequence in 
%                   cycles/second (default is 1).
%      'FileName' - name of output file (default is '').
%      'ShowPlot' - plots the phase sequence and amplitude spectrum.
%      'ShowGrating' - animates a grating using the phase sequence.
%      'ShowAll' - equivalent to using both 'ShowPlot' and 'ShowGrating'.
%      
%   r = getGrating1OverF(BETA,DURATION,'framerate',25,'filename','',...
%           'minphase',1,'showplot','showgrating','gratingsize',100,...
%           'gratingsf',10,'framepause',0.1)

Args = struct('FrameRate',25, ... % 6 refreshes per frame at 150 Hz refresh
			  'MinTF',1, ...
			  'FileName','', ...
			  'ShowPlot',0, ...
			  'ShowGrating',0);
			  
Args = getOptArgs(varargin,Args,'flags',{'ShowPlot','ShowGrating'},...
					'aliases',{'ShowAll',{'ShowPlot','ShowGrating'}});

% get number of points to generate
% make sure npts2 is an integer and npts is an even number
npts2 = ceil(duration * Args.FrameRate/2); 
npts = npts2 * 2;

% generate 1/f^beta
f = 1:npts2;
% scale frequencues so that the amplitude of the 1st freq is 128
fexp = f.^(-beta);
% get random phase between -pi and pi
fphase = 2*pi*(rand(1,npts2)-0.5);
% generate amplitude vector and phase vector
% set DC to get mean of 0 and drop last point of flipped fexp and fphase to 
% make sure mag and phase are npts in length
endpt = npts2 - 1;
mag = [0 fexp fliplr(fexp(1:endpt))];
% make sure DC is positive and take negative of fliplr(fphase) to make 
% sure if it is the complex conjugate of the positive frequencies
phase = [0 fphase -fliplr(fphase(1:endpt))];
sig = real(ifft( mag.*exp(i*phase) ));
% set standard deviation to 1
s = (sig-mean(sig)./std(sig));

nphases = round(Args.FrameRate/Args.MinTF);
lastphase = nphases - 1;
minPhase = 360/nphases;
% normalize to number of phases
smin = min(s);
% range of r should be [0 lastphase]
r1 = round((s-smin)/(max(s)-smin)*lastphase);
% shift range so that r starts at 0
r2 = r1-r1(1);
% set r to r2 and then change negative values to equivalent positive values
r = r2;
% range should now be [-r1(1) lastphase-r1(1)] so add nphases to all the 
% negative values so range goes back to [0 lastphases]
rind = find(r<0);
r3 = r(rind)+nphases;
% substitute the negative values with corrected positive values
r(rind) = r3;

if(~isempty(Args.FileName))
	fid = fopen(Args.FileName,'wt');
	fprintf(fid,'# generated %s by %s using:\n',date,mfilename);
	fprintf(fid,'# beta: %d, duration: %f seconds, frame rate: %d Hz\n',...
					beta,duration,Args.FrameRate);
	fprintf(fid,'# first number corresponds to number of phases, followed by 0-indexed phase indices.\n');
	fprintf(fid,'%d\n',nphases);
	fprintf(fid,'%d\n',r);
	fclose(fid);
end

if(Args.ShowPlot)
    clf
	% plot time series
	subplot(2,1,1)
	% convert phase indices to degrees
	r2deg = r2 * minPhase;
	framen = 1:npts;
	[ax,h1,h2] = plotyy(framen,r2deg,[1 npts],[0 0]);
	% set the negative y value to some multiple of 60
	rmin = floor(min(r2deg)/60)*60;
	rmax = ceil(max(r2deg)/60)*60;
	axis(ax(1),[1 npts rmin rmax])
	axis(ax(2),[1 npts rmin rmax])
	yticks = rmin:60:rmax;
	yind = find(yticks<0);
	ylabels = yticks;
	ylabels(yind) = ylabels(yind) + 360;
	set(ax(1),'YTick',yticks);
	set(ax(2),'YTick',yticks,'YTickLabel',num2str(ylabels'));
	set(h1,'Marker','o')
	xlabel('Frame Number');
	ylabel('Temporal Phase');
	% take absolute value of the differences so only the change in phase matters
	dr = abs(diff(r));
	% conversion factor from phase degrees to cycles per second is
	% cycles/frame->minPhase/360 * Args.FrameRate<-frames/second
	% which is 360/(nphases*360) * Args.Framerate which then simplifies to:
	cps = Args.FrameRate/nphases;
	% get maximum and minimum temporal frequency
	drmin = min(dr)*cps;
	drmax = max(dr)*cps;
	title(['Temporal Frequency Min: ' num2str(drmin,'%.2f') ' Max: ' num2str(drmax,'%.2f') ' cycles/second']);
	
	% plot amplitude spectrum
	subplot(2,1,2)
    % fft r1 instead of r since the negative values in r were converted to
    % the equivalent positive phases
	rf = fft(r1);
	% code from PlotFFT
	fftx=rf(1:(npts2+1));
	mx = abs(fftx) * 2 / npts;
	mx([1 end],:) = mx([1 end],:)/2;
	x = (0:npts2)*Args.FrameRate/npts;
	plot(x,mx,'o-');
	hold on
	x2 = x(2:end);
	y = x2.^(-beta);
	plot(x2,y*mx(2)/y(1),'r-')
	xlabel('Frequency (Hz)')
	ylabel('Amplitude')
	title('Amplitude Spectra')
	hold off
end

if(Args.ShowGrating)
	% create grating
	figure
	% add 1 to r since it is 0-indexed
	gl = showGratingSeq(nphases,r+1,varargin{:});
	figure
	% take fft of each column which contains time series of gray levels
	glf = fft(gl);
	% code from PlotFFT
	fftx = glf(1:(npts2+1),:);
	mx = abs(fftx) * 2 / npts;
	mx([1 end],:) = mx([1 end],:)/2;
	x = (0:npts2)*Args.FrameRate/npts;
	plot(x,mx,'o-')
	hold on
	x2 = x(2:end);
	y = x2.^(-beta);
	plot(x2,y*mean(mx(2,:))/y(1),'k-')
	xlabel('Frequency (Hz)')
	ylabel('Amplitude')
	title('Amplitude Spectra of graylevels')
	hold off
end
