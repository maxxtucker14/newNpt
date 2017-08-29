function r = nptDefaultMarkers(varargin)
%nptDefaultMarkers Returns marker order used for plotting.
%   R = nptDefaultMarkers returns the default marker order used by the
%   builtin plot function (i.e. '.ox+*sdv^<>ph'). 
%
%   R = nptDefaultMarkers('MarkerOrder',ORDER) uses the markers in ORDER
%   instead of the default.

Args = struct('MarkerOrder','');
Args = getOptArgs(varargin,Args);

if(isempty(Args.MarkerOrder))
    r = '.ox+*sdv^<>ph';
else
    r = Args.MarkerOrder;
end
