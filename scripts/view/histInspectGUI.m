function histInspectGUI(varargin)
%NPTDATA/InspectGUI Plots data using a graphical interface
%   InspectGUI(OBJECT) is a function that can be used to view any data 
%   derived from the nptdata class. 
%
%   Dependencies: CreateViewObject.

HistGUI	
if nargin>0
   switch char(fieldnames(varargin{1}))
   case 'duration_histograms'
      InspectEyeDurationHistogram(varargin{1}.duration_histograms)
   case 'position_range'
      InspectPositionRangeHistogram(varargin{1}.position_range)
   case 'velocity'
      InspectEyeVelocityHistogram(varargin{1}.velocity)
   case 'ISI'
      InspectISIHistogram(varargin{1}.ISI)
   end
end
