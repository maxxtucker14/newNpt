%readme
%the view folder contains files used to inspect our data.  
%It contains different class foldewrs and GUI files.
%
%the gui folder contains the different callback and .fig files
%for all the different npt guis.
%
%basicInspectGUI and InspectGUI use the InspectGUI callback
%
%There are two gui's which are used for several datatypes:
%1.)  InspectGUI is used for trial based data types.
%		Several classes have been designed to use InspectGUI.
%		Each different class has its own plot method to use InspectGUI.
%		Nptdata is a base class of all the objects which use InspectGUI and 
%     so the InspectGUI.m which defines the appearance of the GUI is
%		located in the nptdata class directory.
%		(!!there are several InspectGUI.m files-one for each specific gui and 
%		one to load non-object data types onto a gui.!!)  
%	
%2.)  basicInspectGUI is used for final results which are not trial based.
%		Seperate classes are not created for data that uses basicInspectGUI.
%		basicInspectGUI.m is located in the view directory.
%
%
%Some classes have their own specific GUI.  These classes overload the 
%InspectGUI.m file within their class folder but have their callback function 
%within the gui folder or within the gui folder of another toolbox(ie. fvt/view/gui). 
%
%
%When a new data type is created that needs to be viewed with a GUI there are two options.
%A new class can be created or the result can just be stored as a structure.  If the new data type
%will work with the trial based InspectGUI then a new class should be created.  Also if the new class,
%is an intermediate result and will be used for more analysis then it may be beneficial to create a
%seperate class to make use of the advantages of classes (ie. overloading operators, private methods,etc...).
%Otherwise it is faster to just save the result as a structure (use structures because the result and
%the origin of the data can be conviently stored together).
%
%The InspectGUI.m and CreateDataObject.m (in the view directory) are used to show data on a new GUI.
%Both of these files are hardwired with filenames or data names.  If a new viewing class is created
%then CreateDataObject.m must be appended (InspectGUI.m is overloaded if an object calls it).
%If a new datatype (structure) is created then both of the files need to be appended.
%
%
%
