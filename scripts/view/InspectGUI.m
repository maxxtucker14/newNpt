function InspectGUI(varargin)
%NPTDATA/InspectGUI Plots data using a graphical interface
%   InspectGUI(OBJECT) is a function that can be used to view any data 
%   derived from the nptdata class. 
%
%   Dependencies: CreateViewObject.

basicInspectGUI	
if nargin>0
   switch char(fieldnames(varargin{1}))
   case 'spikeprob'
      InspectFiringRate(varargin{1}.spikeprob)
   case 'FRCor'
      InspectFRCor(varargin{1}.FRCor)
      InspectFRCor2(varargin{1}.FRCor)
   case 'eyeeventspike'
      InspectEyeEventSpikeHistogram(varargin{1}.eyeeventspike)
   case 'power_spectrum'
      InspectEyePowerSpectrum(varargin{1}.power_spectrum)
   case 'eccentricity'
      InspectEccentricity(varargin{1}.eccentricity)
   end
end
