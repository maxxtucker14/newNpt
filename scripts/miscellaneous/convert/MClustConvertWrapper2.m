function MClustConvertWrapper2
%function MClustConvertWrapper2
%wrapper function to convert files 
%groups after 1 have the wrong duration
%Two changes are being made
%1.  change the times in the waveforms.bin file 
%2.  change the MClust feature files 
%
%this wrapper performs both changes.
%the pwd is the sort directory.



dirlist = nptdir('*.hdr');
for i=1
    [max_duration, min_duration, trials, waves, rawfile, fs, channels, means, thresholds] = nptReadSorterHdr(dirlist(i).name);
end

dirlist = nptdir('*waveforms.bin');
for i = 2:length(dirlist)
    ConvertWaveforms2(dirlist(i).name,max_duration);        
end


if ~isempty(nptdir('fd'))
    cd('fd')
     delete('*.fd')
     fprintf('deleting old feature files...\n')
     cd ..
     p=which('RunClustBatch');
     [p,n,e]=fileparts(p);
     RunClustBatch([p filesep 'Batch_KKwik.txt'],'Do_AutoClust','No')
end


%delete all ispikes
delete('*_ispike.mat')
fprintf('deleting ispike files...\n')



