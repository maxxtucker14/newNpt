
diary([pwd filesep 'diary.txt']); 
CombineSessionRule('deleteOriSession')
ProcessDay('timing','eye','cygwinmove','extraction','threshold',4,'sort_algo','KK','clustoptions',{'Do_AutoClust','yes','wintermute','yes'},'lowpass','highpass'); 
ProcessDay(nptdata,'nptSessionCmd','eyemvt(''auto'',''SacThresh'',60,''save'');'); % mtstrial(''auto'',''save'');'); 
% mts =ProcessDay(mtstrial,'NoSites','auto','save');
% InspectGUI(mts,'ObjPos','percentCR','Hist')
diary off;

% mtsday = ProcessDay(mtstrial,'auto');
% InspectGUI(mtsday,'ObjPos','percentCR')