% Neural Physiology Toolbox 
% Toolbox used to process data from Neural Physiology Expirements
% Version 1.1 July 2001.
%
% There are two types of files: algorithms and scripts
% ALGORITHMS are passed data, manipulate the data and then return the data.
% SCRIPTS handle data organization, file manipulation, looping, displaying data, etc...
%
% The files are arranged in subfolders according to the purpose of the file.
%
% See ChangeLog file for latest modifications. 
% Type "help <command-name>" for documentation on individual commands.
% -----------------------------------------------------------------
%
%ALGORITHMS
% 	Extraction
%				ExtractorWrapper
%				nptExtructor
% 	Eye
%				nptGenerateSessionEyeMovements
%				nptEyeCalibAnalysis
%				nptEyeCoil2Screen
%				nptEyeDurationHistograms
%				nptEyePositionRangeHistogram
%				nptEyePowerSpectrum
%				nptEyeVelocityHistogram
%				nptPSTH
%				pixel2degree 
% 	Filters
%				filterdesign
%				nptGaussianConv
%				nptHighPassFilter
%				nptLowPassFilter
%
%SCRIPTS
% 	BatchProcessor
%				BatchPreprocessor
%				ChannelIndex
%				GroupSignals
%				ProcessDay
%				ProcessEyeSessions
%				ProcessSession
%				SetUpDir
%	Miscellaneous
%				nptDir
%				nptFileParts
%				nptPWD
%				num2strpad
%	ReadFiles
%				nptReadDataFile
%				nptReadDatfile
%				nptReadSorterHdr
%				nptReadStreamerFile
%				read_init_info
%				ReadDescriptor
%				ReadStimulusFile
%	View
%				InspectDatFile
%				InspectSpikes
%				InspectSpikesOnEyes
%				nptDisplayStillImage
%				nptDisplayMovie
%				create_points
%	WriteFiles
%				nptWriteDat
%				nptWriteDataFile
%				nptWriteSorterHdr
%				nptWriteStreamerFile
%
%GenerateSessionSpikeTrains
%
%
%
%
% Type "help <command-name>" for documentation on individual commands.




