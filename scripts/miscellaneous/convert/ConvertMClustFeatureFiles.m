function ConvertMClustFeatureFiles(duration)
%need to open all the .fd files and divide the FEatureTimestamps field by
%100 to create .1 msec precision.  May need to change the .t files as well.
%assumed to be in the correct direcory


samplingRate=30000;
if duration==17
    binsize=500000;
else
    error('wrong duration');
end
duration = duration*10^6;% change duration to micro-seconds for use with time in waveforms data



dirlist = dir('*.FD');
for i=1:length(dirlist)
    t=load(dirlist(i).name,'-mat');
    
    t.FeatureTimestamps = t.FeatureTimestamps*100;      %convert
    t.FeatureTimestamps = ConvertTimes(t.FeatureTimestamps,duration,binsize,samplingRate);      %convert
    t.FeatureTimestamps = round(t.FeatureTimestamps/100);      %convert

    
    
    
    FeatureIndex = t.FeatureIndex;
    FeatureTimestamps = t.FeatureTimestamps;
    FeatureData = t.FeatureData;
    FeaturesToUse = t.FeaturesToUse;
    ChannelValidity = t.ChannelValidity;
    FeatureNames = t.FeatureNames;
    FeaturePar = t.FeaturePar;
    FD_av = t.FD_av;
    FD_sd = t.FD_sd;
    TT_file_name = t.TT_file_name;
        
    save(dirlist(i).name, 'FeatureIndex','FeatureTimestamps','FeatureData', 'FeaturesToUse', 'ChannelValidity', 'FeatureNames', ... 
    'FeaturePar','FD_av','FD_sd', 'TT_file_name', '-mat');
    disp([  ' Converted ' dirlist(i).name ]);
end