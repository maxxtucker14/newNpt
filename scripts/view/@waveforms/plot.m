function vw = plot(vw,n,varargin)
%WAVEFORMS/PLOT Plots a waveform
%   OBJ = PLOT(OBJ,N) plots the waveforms specified by N.
%   OBJ = PLOT(OBJ,N,'Separate') plots the waveforms separated by channel.
%   OBJ = PLOT(OBJ,N,'Separate','Increment',VALUE) plots the waveform 
%   separated by VALUE (default is 0.1).
%
%   Dependencies: None.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
    'Increment',0.1,'Separate',0);
Args.flags = {'LabelsOff','Separate'};
[Args,varargin2] = getOptArgs(varargin,Args);

% check if we need to get the data 
if(isempty(vw.data.wave))
    % change to appropriate directory
    cd(vw.nptdata.SessionDirs{1})
    % read the appropriate waveform
    [t,wf] = ReadWaveformsFile(vw.data.datname,n,2);
    % take the transpose so it will be easier to plot
    wf2 = squeeze(wf)';
    [pts,num_channels] = size(wf2);
    if(Args.Separate)
        % check max and min for waveforms
        wf3 = wf2(:);
        m1 = min(wf3);
        m2 = max(wf3);
        % separate the waveforms for different channels
        plot(wf2+repmat(( 0:(num_channels-1) )*(m2-m1)*Args.Increment,pts,1))
    else
        plot(wf2);
    end
    s = sprintf('Waveform %i of %i Time: %f ms\n',n,get(vw,'Number'),t/1000);
    title(s)
else
    gcf;
    clist = get(gca,'ColorOrder');
    clistsize = size(clist,1);

    %find number of channels
    num_channels = size(vw.data.wave,2);
    hold off
    if n
        for i=1:num_channels
            plot(squeeze(vw.data.wave(n,i,:)),'Color',clist(mod(i-1,clistsize)+1,:))
            hold on
        end
        s = sprintf('Waveform %i of %i Time: %f ms\n',n,get(vw,'Number'),vw.data.time(n)/1000);
    else
        plot(0,0)
        s=sprintf('No waveforms in this trial');
    end
    title(s)
end

% draw line at trigger point
% ax1 = axis;
% line([11 11],[ax1(3) ax1(4)])
set(gca,'XMinorGrid','on')
