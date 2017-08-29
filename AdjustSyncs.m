function [init_info,frame_info,varargout]=adjustsyncs(filename,init_info,seq,varargin)

%This function will load the sync file and the extrasyncs file, along with the ini file and calculate a frame vector in datapoints.

base=filename;

% AUTOMATIC PARAMETERS
num_frames=init_info.frames_displayed;
sink_per_frame=init_info.refreshes_per_frame;

% OPEN AND READS EXTRA-SYNCS FILE IF NEEDED .... prompts if can not find files.
if (~isempty(init_info.extra_syncs))
   try_file=[base '_extra_syncs.txt'];
   d=dir(try_file);
   if isempty(d) %(no extra_syncs file in obvious place)
      [syncfile, syncpath]=uigetfile('*.txt', ['select  ',base,' extra_syncs file']);
        if syncfile==0 error(' io error or cancelled by user'); end
    else syncfile=try_file; 
	end;   
   
   fid=fopen(syncfile, 'rt');
   line=fgetl(fid);
   extra_syncs=[];
   while line>0
      extra = sscanf(line, '%d')';
      if extra(2) == -1
          extra = [];
      end
      extra_syncs=[extra_syncs; extra];
      line=fgetl(fid);
  end %while line>0
   fclose(fid);
else   
   fprintf('\n no extra syncs')   
   extra_syncs=[];
end; % if (~isempty(ss_z.extra))

% OPEN AND READS SYNC FILE .... prompts if can not find files.
[syncs,dataFilename,records,meanF,stdF] = nptReadSyncsFile([base '.snc']);
% try_file = [base '.snc'];
% d=dir(try_file);
% if isempty(d) %(no extra_syncs file in obvious place)
%       [sync_table_file, syncpath]=uigetfile('*.snc', ['select  ',base]);
%       if sync_table_file==0 error(' io error or cancelled by user'); end
% else sync_table_file=try_file; 
% end;   
%    
% fid=fopen(sync_table_file, 'r');
% if fid>0 %sync_table_file exists
%    header_size=fread(fid, 1, 'long');
%    data_file_name=fread(fid, 260, 'char');
%    records=fread(fid, 1, 'long');
%    fseek(fid, header_size, 'bof');
%    syncs=fread(fid, records, 'long');
%    fclose(fid);
%    
% end %if fid>0 %sync_table_file exists

init_info.sync_datapoints = min(diff(syncs));
init_info.frame_duration = min(diff(syncs))*init_info.refreshes_per_frame;

% FROM THE SYNC-DATAPOINTS AND THE EXTRA-SYNC VECTOR< GETS THE LOOK-UP TABLE: FRAME-DATAPOINTS.

% if ei is the number of extra sinks for frame i, and if fi starts at vertcal sink i, and r=number-of-refreshes per frame, then we have:
% fn = f1 + (n-1)*r + (e1 + ... + e(n-1)) where f1 is the first frame. also ...
% fn = f1 + (n-1)*r * g(n-1)  where g=cumsum(e)

vecframe=zeros(1,num_frames);

if (isempty(extra_syncs))
   v_cumsum=zeros(1,num_frames);
else
% get f1, vecframe(1). is there a extra-sync before the first frame?
[s_test,s_val]=find(extra_syncs(:,1)==0);
if (~isempty(s_test))
   extra_syncs=extra_syncs(2:end,:);
   vecframe(1)=1+sink_per_frame+s_val;
else
   vecframe(1)=1+sink_per_frame;
	s_val=0;   
end;

% get cumsum
v_tool=sparse(1,num_frames);
v_tool(extra_syncs(:,1))=extra_syncs(:,2);
v_cumsum=cumsum(v_tool);
end; % if(isempty)

if ~exist('seq')

    vecframe(2:num_frames)=vecframe(1)+sink_per_frame*(1:num_frames-1)+v_cumsum(1:num_frames-1); %check  this
    
    
elseif seq == 1
    
    vecframe(2:num_frames)=vecframe(1)+sink_per_frame*(1:num_frames-1)+v_cumsum(1:num_frames-1); %check  this
    
elseif seq == 2
    
    isi = init_info.inter_stimulus_interval;
    
    sink_per_frame = sink_per_frame+isi; % For the Grating stimulus since there is dead time between presentations.
    
    vecframe(2:num_frames)=vecframe(1)+sink_per_frame*(1:num_frames-1)+v_cumsum(1:num_frames-1); 
        
end

% Since some sync files are not in register with the number of frames written in the ini file, I do a check and just toss some data for now.

if exist('seq') % For sparse bars & Gratings
    
    if max(vecframe)>length(syncs)
       frame_length = init_info.sync_datapoints*sink_per_frame;
       last_sync = length(syncs);
       vecframe = vecframe(find(vecframe<last_sync));
       init_info.frames_displayed = length(vecframe);
       init_info.frame_info=syncs(vecframe);
       %init_info.frame_info= frame_length:frame_length:init_info.frames_displayed*frame_length;
       frame_info = init_info.frame_info;
    else
       init_info.frame_info=syncs(vecframe);
       frame_info = init_info.frame_info;
    end
       
else

    if max(vecframe)>length(syncs)
	    init_info.frame_info=[];
        frame_info = init_info.frame_info;
    else
        if vecframe(1) == 0
            vecframe = vecframe+1;
            init_info.frame_info=syncs(vecframe);
            frame_info = init_info.frame_info;
        else
            init_info.frame_info=syncs(vecframe);
            frame_info = init_info.frame_info;
        end
    end

end %if exist(seq)




