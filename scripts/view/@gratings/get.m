function [r,varargout] = get(obj,varargin)

Args = struct('ScreenHeight',0,'ScreenWidth',0);
Args = getOptArgs(varargin,Args,'flags',{'ScreenHeight','ScreenWidth'});

r =[];
if(Args.ScreenHeight)
	r = obj.data.ScreenHeight;
elseif(Args.ScreenWidth)
	r = obj.data.ScreenWidth;
else
	r = get(obj.mapfields,varargin{:});
end
