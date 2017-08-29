function w = waveforms(varargin)
%WAVEFORMS Constructor function for WAVEFORMS object
%   W = WAVEFORMS(GROUPNAME) instantiates an WAVEFORMS object by reading
%   the file GROUPNAME.DAT or GROUPNAME.BIN. The object contains the 
%   following fields:
%      W.data[].wave
%      W.data[].time
%      W.numWaves
%      W.holdaxis
%   (e.g. w = waveforms('P107g0001waveforms');
%
%   W = WAVEFORMS(GROUPNAME,'Incremental') instantiates the WAVEFORMS
%   object without reading in all the data. This is useful when the data is
%   too big to be read in all at once. 
%
%   Dependencies: @nptdata/nptdata,nptReadDatFile.

% property of nptdata base class
holdAxis = 1;

switch nargin
case 0
    d.data.datname = '';
	d.data.time = [];
    d.data.wave = [];
	n = nptdata(0,holdAxis);
	w = class(d,'waveforms',n);
case 1
	if (isa(varargin{1},'waveforms'))
		w = varargin{1};
    elseif isempty(findstr(varargin{1},'waveforms'))
        datname = [varargin{1} '.dat'];
        [d.data,total] = nptReadDatFile(datname);
        d.data.datname = datname;
		n = nptdata(total,holdAxis,pwd);
		w = class(d,'waveforms',n);
	elseif ~isempty(findstr(varargin{1},'waveforms'))
        d.data.datname = [varargin{1} '.bin'];
        [d.data.time d.data.wave] = ReadWaveformsFile(d.data.datname);
		n = nptdata(length(d.data.time),holdAxis,pwd);
		w = class(d,'waveforms',n);
   
	else
		error('Wrong argument type')
    end
case 2
    if(ischar(varargin{1}) && ischar(varargin{2}) && strcmpi(varargin{2},'Incremental'))
        % get filename
        d.data.datname = [varargin{1} '.bin'];
        % read file to see how many waveforms are present
        nwaveforms = ReadWaveformsFile(d.data.datname,[],5);
        d.data.time = [];
        d.data.wave = [];
        n = nptdata(nwaveforms,holdAxis,pwd);
        w = class(d,'waveforms',n);
    else
        error('Second argument should be ''Incremental''')
    end        
otherwise
	error('Wrong number of input arguments')
end
