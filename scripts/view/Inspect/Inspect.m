function Inspect(obj)
%NPTDATA/Inspect Plots data
%   Inspect(OBJECT) is a function that can be used to view any data 
%   derived from the nptdata class. 
%
%   Dependencies: CreateViewObject.

obj = CreateDataObject(obj);

if ~isempty(obj)
	Inspect(obj)
end
