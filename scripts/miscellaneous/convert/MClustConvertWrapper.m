function MClustConvertWrapper
%function MClustConvertWrapper
%wrapper function to convert file formats.  
%Two changes are being made
%1.  change the times in the waveforms.bin file 
%2.  change the MClust feature files 
%
%this wrapper performs both changes.
%the pwd is the session directory.

cd('sort')

dirlist = nptdir('*.hdr');
for i=1:length(dirlist)
    %hdrname = [num2strpad(i,4) '.hdr'];
    [max_duration, min_duration, trials, waves, rawfile, fs, channels, means, thresholds] = nptReadSorterHdr(dirlist(i).name);
    d = max_duration*(trials-1)+ min_duration;
    f.trial(1).means = mean(means,2) ;
    f.trial(1).thresholds = mean(thresholds,2) ;

    %need to change the duration in the sorter header
    [path,name,ext] = nptFileParts(dirlist(i).name);
    nptWriteSorterHdr(name,fs,d,0,1,waves,rawfile,channels,f);
end

dirlist = nptdir('*waveforms.bin');
for i=1:length(dirlist)
    ConvertWaveforms(dirlist(i).name,max_duration);        
end


if ~isempty(nptdir('fd'))
    cd('fd')
%    ConvertMClustFeatureFiles(max_duration)
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

cd ..
%delete all trial files
fprintf('deleting fake trial files...\n')
delete('*.0*')


