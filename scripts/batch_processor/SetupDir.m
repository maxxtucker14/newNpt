function SetupDir(currentDir)

sessions=[];

% check to see if we need to move files
   inidirlist=dir('*.ini');
   inisize = size(inidirlist,1);
   for i=1:inisize	%loop over sessions
      [path,ininame]=fileparts(inidirlist(i).name);
      inamelength = length(ininame);
      session_num=ininame(inamelength-1:inamelength);
      sessions=[sessions session_num];
      % check to make sure it is a number since receptive files are also .INI 
      % but they will have '_rfs' at the end of the prefix
      if(~isempty(str2num(session_num)))	
         status = mkdir(session_num);	%create session folder
         
         sessiondirlist=dir([ininame '*']);
         fprintf('\n\nMoving raw datafiles to session folder ');	
         for j=1:size(sessiondirlist,1)	
            fprintf('.');
            %move all files from this session to the session folder
            status=copyfile(sessiondirlist(j).name,[currentDir filesep session_num filesep sessiondirlist(j).name]);
            if status==1
               delete(sessiondirlist(j).name);
            end
         end
      end
   end	   	   
