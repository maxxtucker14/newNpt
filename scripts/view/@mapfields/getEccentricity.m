function [ecc,n] = getEccentricity(obj,varargin)
%mapfields/getEccentricity Returns eccentricity of fields from fixation
%   [ECC,N] = getEccentricity(OBJ) returns the eccentricity of all 
%   fields relative to the fixation in pixels, as well as the field
%   number (in OBJ) in N.
%
%   [ECC,N] = getEccentricity(OBJ,N) returns the eccentricity of field
%   number N.
%
%   [ECC,N] = getEccentricity(OBJ,'Mark',M) returns only the 
%   eccentricity of fields marked with M (e.g. M=1 real receptive 
%   fields, M=2 dummy receptive fields).

Args = struct('UseDegrees',0);
Args = getOptArgs(varargin,Args,'flags',{'UseDegrees'}, ...
	'remove',{'UseDegrees'});

% get relevant fields
fields = get(obj,varargin{:},'Indices');

% remove any fixation fields
fixfields = find(obj.data.type(fields));
fields = setdiff(fields,fields(fixfields));

% get center of fields
[centerx,centery] = get(obj,'CenterXY','Field',fields);
% get corresponding fixation location
[fcx,fcy] = get(obj,'FixCenterXY','Field',fields);
% get eccentricities
if(Args.UseDegrees)
	% get conversion factors from pixels to degrees
	[xdeg,ydeg] = get(obj,'PixelsPerDegree');
	eccx = (centerx-fcx)/xdeg;
	eccy = (centery-fcy)/ydeg;
	ecc = sqrt(eccx.^2 + eccy.^2);
else
	ecc = sqrt((centerx-fcx).^2 + (centery-fcy).^2);
end
n = fields;
