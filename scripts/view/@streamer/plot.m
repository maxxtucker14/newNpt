function [vs, varargout] = plot(vs,n,varargin)
%STREAMER/PLOT Plots raw data from Data Streamer
%   OBJ = PLOT(OBJ,N) plots the raw data from the trial specified N.
%   The streamer files are assumed to be in the current directory.
%           P-Values      V-Values
%           Units      -  {'Volts'}, 'MilliVolts', 'MicroVolts',  or  'Daqunits'
%           AmpGain    -  {5000} or specify the total amplification, MCC main amp is 500X and the MCS Head Stage is 10X
%           Stacked    -  no V-Value needed, Plots the data one channel stacked using an offset, or plots the data one channel on top of another.
%           Filter     -  Filters the Raw data either "High" or "Low" Pass, no V-Value needed
%           FilterType -  Either {'High'} 500-10000 Hz or 'Low' 0.5-150 Hz
%           HighRange  -  {[500 10000]} frequency band for high pass
%           LowRange   -  {[0.5 150]} frequency band for low pass
%           ViewerGain -  Multiply the original signal by an integer eg.'2' or '10', {'0'} is the default
%           Clean      -  Removes common PCA components from each channel
%
%   Dependencies: nptReadStreamerFile, ReadUEIFile, ViewUEIRawData.

Args = struct('showTitle',1,'chunkSize',[],'linkedZoom',0,...
    'AmpGain',5000,'Units','Volts','Stacked',0,'Filter',0,...
    'FilterType','High','HighRange',[500 10000],'LowRange',[0.5 150],...
    'Clean',0,'ViewerGain',0);
Args = getOptArgs(varargin,Args,'flags',{'showTitle','linkedZoom',...
    'Stacked','Filter','Clean'});

if isempty(Args.chunkSize)
    chunkSize = vs.chunkSize;
else
    chunkSize = Args.chunkSize;
end

gcf;
clist = get(gca,'ColorOrder');
clistsize = size(clist,1);

% set zoom to on
%zoom on

channel = vs.channel;
sessionname = vs.sessionname;

%check to see if sesioname.bin is a file
%if so then cat data.
%just pass in n scalar
%then default binsize is defined here
%or can be passed in.
cwd = pwd;
cd(char(get(vs,'SessionDirs')))
% set the default ylabel
ylab = 'MilliVolts';

if vs.numChunks
    [num_channels,sampling_rate,scan_order]=nptReadStreamerFileHeader([sessionname '.bin']);
    dtype = DaqType([sessionname '.bin']);
    if strcmp(dtype,'UEI')
        d = ReadUEIFile('FileName',[sessionname '.bin'],'Header');
        samplingRate = d.samplingRate;
        numChannels = d.numChannels;
        scanOrder = d.scanOrder;
        points = [chunkSize*samplingRate*(n-1)+1   chunkSize*samplingRate*n];
        %d = ReadUEIFile('FileName',[sessionname '.bin'],'Channels',channel,'Samples',points,'Units',Args.Units);
        d = ReadUEIFile('FileName',[sessionname '.bin'],'Samples',points,'Units',Args.Units);
        if Args.Filter
            if strcmpi(Args.FilterType,'High')
                data = nptHighPassFilter(d.rawdata,samplingRate,Args.HighRange(1),Args.HighRange(2));
            elseif strcmpi(Args.FilterType,'Low')
                points = points/samplingRate;
                [data,samplingRate]=nptLowPassFilter(d.rawdata,samplingRate,Args.LowRange(1),Args.LowRange(2));
                points = points*samplingRate;
            end
        else
            data = d.rawdata;
        end
        if strcmpi(Args.Units,'daqunits')
            % No need to change to Voltage Values
            ylab = 'DAQ Units';
        else
            data = data/Args.AmpGain;
            if strcmpi(Args.Units,'MilliVolts')
                ylab = 'MilliVolts';
            elseif strcmpi(Args.Units,'MicroVolts')
                ylab = 'MicroVolts';
            elseif strcmpi(Args.Units,'Volts')
                ylab = 'Volts';
            end
        end
        datalength = size(data,2);
        timestep = 1/samplingRate*1000; %convert to milliseconds
        timev = points(1)/samplingRate*1000:timestep:points(2)/samplingRate*1000;
        %%%%%%%% The end of the Hack section for the UEI data %%%%%%%
    elseif strcmp(dtype,'Streamer')
        points = [chunkSize*sampling_rate*(n-1)+1   chunkSize*sampling_rate*n];
        [data,numChannels,samplingRate,scanOrder,datalength] = nptReadStreamerFileChunk([sessionname '.bin'],points);
        timestep = 1/samplingRate*1000; %convert to milliseconds
        timev = points(1)/samplingRate*1000:timestep:points(2)/samplingRate*1000;
    else
        error('unknown file type')
    end
else
    filename = [sessionname '.' num2str(n,'%04i')];
    fprintf('Reading %s\n',filename);
    [data,numChannels,samplingRate,scanOrder,datalength] = nptReadStreamerFile(filename);
    timestep = 1/samplingRate*1000;    %convert to milliseconds
    duration = (datalength)/samplingRate*1000;
    timev = 0:timestep:duration;
end
cd(cwd);

% Since the channels selected could have a different numbering scheme than "data" channels index, we change it.
if Args.Stacked
    plotchannel = fliplr(1:length(channel));
    if Args.Clean
        data = CleanData(data); data = data'; data = data(1:length(channel),:); %Transpose and take out PCA's for the plotting
    end
    

    mx = max(data(channel(plotchannel),:),[],2);
    mn = min(data(channel(plotchannel),:),[],2);
    r = mx-mn;
    offset = 1/(length(plotchannel)+1);
    d=data(channel,:)*offset/max(r);
    % Amplify the Signals
    if Args.ViewerGain
        d = d*Args.ViewerGain;
    end
    for i=1:length(plotchannel)
        plot(timev(1:datalength),d(i,:)+(1-i*offset),'Color',clist(mod(i-1,clistsize)+1,:))
        hold on
    end
    set(gca,'FontSize',11)
    set(gca,'YTick',[offset:offset:(offset*length(channel))])
    set(gca,'YTickLabel',channel(plotchannel))
    ylimits = [0 1];
    ylabel('Channel Number','FontSize',14)
    xlabel('Time (MilliSeconds)','FontSize',12)
 
%    offset = (max2(data(channel,:))+abs(min2(data(channel,:))))/2;
%     for i=1:length(plotchannel)
%         plot(timev(1:datalength),data(channel(plotchannel(i)),:)+((i-1)*offset),'Color',clist(mod(i-1,clistsize)+1,:))
%         yticks(i) = abs(mean(data(channel(plotchannel(i)),:))+((i-1)*offset));
%         hold on
%     end
%     set(gca,'FontSize',11)
%     set(gca,'YTick',yticks)
%     set(gca,'YTickLabel',flipud(scanOrder(channel)))
%     ylimits = [yticks(1)-(offset*2) yticks(end)+(offset*2)];
%     ylabel('Channel Number','FontSize',14)
%     xlabel('Time (MilliSeconds)','FontSize',12)
else
    plotchannel = 1:length(channel);
    if Args.Clean
        data = CleanData(data); data = data'; data = data(1:length(plotchannel),:); %Transpose and take out PCA's for the plotting
    end
    % Amplify the Signals
    if Args.ViewerGain
        data = data*Args.ViewerGain;
    end
    for i=1:length(plotchannel)
        plot(timev(1:datalength),data(channel(plotchannel(i)),:),'Color',clist(mod(i-1,clistsize)+1,:))
        hold on
    end
    ylimits = [min2(data(channel,:)) max2(data(channel,:))];
    ylabel(ylab,'FontSize',14)
    xlabel('Time (msec)','FontSize',12)
    set(gca,'FontSize',12)
    %legend(num2str(scanOrder(channel)),'Location','EastOutSide')
end

% Set the Axis Parameters
hold off
axis tight
set(gca,'XLim',[timev(1) timev(end)])
set(gca,'YLim',ylimits)
if isempty(findobj(gcf,'Tag','streamer'))
    set(gca,'Tag','streamer')
end
% set zoom to on
zoom on
varargout{1} = {'Args',Args,'xLimits',[timev(1) timev(end)]};
