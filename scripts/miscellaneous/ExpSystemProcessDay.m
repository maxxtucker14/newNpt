function ExpSystemProcessDay(day,sesSkip,varargin)
%ExpSystemProcessDay Process experimental system data for one day
%   ExpSystemProcessDay(DAY,SES_SKIP) calls nptCheckExpSystem for each 
%   session in DAY and saves the data in a MAT file with data appended
%   to the session name, i.e. disco08130201data.mat.
%
%   SES_SKIP is the session to skip, which is useful when you have
%   an eye calibration session that you want to skip.
%      e.g. ExpSystemProcessDay('disco081302','01')
%      e.g. ExpSystemProcessDay('test081302','')
%
%   ExpSystemProcessDay(DAY,SES_SKIP,TRIALS,FG_CHANNELS,SYNC_CHANNEL,
%      MIN_SYNC,TRIG_CHANNEL,TRIG_LENGTH,THRESHOLD,SAMPLE_RATE)
%   passes the optional arguments to nptCheckExpSystem
%
%   Dependencies: nptCheckExpSystem.

dlist = nptDir;
dsize = size(dlist,1);
for i=1:dsize
   sesNum = dlist(i).name;
   if isdir(sesNum)
      if ~strcmp(sesNum,sesSkip)
         cd(sesNum);
         session = [day sesNum];
         fprintf('Processing %s...\n',session);
         [results,dmins,mmins] = nptCheckExpSystem(session,varargin{:});
         save([session 'data'],'results','dmins','mmins');
         cd ..
      end
   end
end