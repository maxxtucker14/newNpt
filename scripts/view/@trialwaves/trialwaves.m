function t = trialwaves(varargin)
%TRIALWAVES Constructor function for TRIALWAVES object
%   T = TRIALWAVES(GROUPNAME) instantiates an TRIALWAVES object by reading
%   the DAT file (GROUPNAME.DAT) and the HDR file (GROUPNAME.HDR) and 
%   seperating waveforms into trials. The object inherits from the WAVEFORMS
%   class and contains the following fields:
%      W.trials
%      W.trial[].wave[].wave
%      W.trial[].wave[].time
%      W.numWaves
%      W.holdaxis
%
%   Dependencies: @waveforms/waveforms,nptReadSorterHdr.

switch nargin
    case 0
        d.lastwave = [];
        d.trials = 0;
        w = waveforms;
        t = class(d,'trialwaves',w);
    case 1
        if (isa(varargin{1},'trialwaves'))
            t = varargin{1};
        elseif ischar(varargin{1})
            if isempty(findstr(varargin{1},'waveforms'))
                datname = [varargin{1} '.dat'];
                hdrname = [varargin{1} '.hdr'];
            else
                datname = [varargin{1} '.bin'];
                group = varargin{1}(length(varargin{1})-12:length(varargin{1})-9);
                hdrname = [group '.hdr'];
            end
            if ~isempty(nptDir(datname)) & ~isempty(nptDir(hdrname))
                % create waveforms object
                w = waveforms(varargin{1});
                % get duration which is in seconds
                duration = nptReadSorterHdr(hdrname);
                % convert duration to microseconds to match since
                %time in the waveforms object.
                duration = duration * 1000000;
                lasttrial = 1;
                numWaves = size(w.data.time,1);
                d.lastwave(1) =  numWaves;  %if only one trial exists
                for i = 1:numWaves          
                    trial = floor(w.data.time(i)/duration) + 1;
                    while trial>lasttrial 
                        d.lastwave(lasttrial) = i-1;
                        lasttrial = lasttrial + 1;
                    end
                end
                if trial>1  
                    d.lastwave = [d.lastwave numWaves];% sets lastwave of last trial
                end
                d.trials = trial;
                t = class(d,'trialwaves',w);
            else
                error(['Cannot find files ' datname ' and ' hdrname]);
            end
        else
            error('Wrong argument type')
        end
    otherwise
        error('Wrong number of input arguments')
end
