function MClustConvertWrapper
%function MClustConvertWrapper
%wrapper function to convert file formats.  
%Two changes are being made
%1.  change the times in the waveforms.bin file from uint32 to uint64.  
%2.  change the MClust feature files to use .1 msec precision
%
%this wrapper performs both changes.
%the pwd is the sort directory.
dirlist=nptdir('*waveforms.bin');

for i=1:length(dirlist)
    Waveform32to64(dirlist(i).name);        %1.  change waveforms files
end


if ~isempty(nptdir('fd'))
    cd('fd')
    ConvertMClustFeatureFiles
end



