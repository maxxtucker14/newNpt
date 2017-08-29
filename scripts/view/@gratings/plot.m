function obj = plot(obj,varargin)
%@grarings/plot Plot function for GRATINGS class
%   OBJ = plot(OBJ) plots the size and position of the gratings that
%   were presented in the experiment.

Args = struct('NoFields',0);
Args = getOptArgs(varargin,Args,'flags',{'NoFields'});

if(~Args.NoFields)
	% plot the receptive fields
	plot(obj.mapfields);
	hold on
end

% plot gratings
% get diameter of gratings
diam = obj.data.ObjectDiameter;
% get radius
radius = diam/2;
rectangle('Position',[obj.data.XGridCenter-radius, ...
	obj.data.YGridCenter-radius,diam,diam],'Curvature',1);

% just in case NoFields was used, set axis axpect ratio to equal
axis equal
