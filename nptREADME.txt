NeuroPhysiology Toolbox (NPT)

This toolbox consists of some functions that are commonly used in the analysis 
of neurophysiological signals.


Platform Independence
These functions were written to take the place of Matlab functions which are 
not platform independent:

nptDIR - removes the '.', and '..' entries from the dir listing if no arguments 
			are passed to the function. This only affects UNIX and PC platforms.
nptPWD - removes the file separator char from the end of the path when PWD is 
			run on the Mac to make it equivalent to UNIX and PC platforms.
nptFILEPARTS - removes the file separator char from the end of the path argument
			when run on the Mac to make it equivalent to UNIX and PC platforms.

Case-sensitivity in filenames
To handle case-sensitivity of filenames on UNIX platforms, filenames are
converted to lower-case by the script tolower.tcsh so make sure that script
is in the UNIX path. 

Installation
Copy the npt directory to a directory on your hard drive.
Add the npt directory on your hard drive to MATLAB's path.
Run the function nptAddPath in MATLAB.
Save the path in MATLAB.

Tips on writing MATLAB code
Do not use strread. The function strread does not exist in versions of Matlab
earlier than 6. Use sscanf instead.

Avoid using num2str. This function does not work in Octave. Use sprintf instead.
It works the same and is more general. 

Use rem instead of mod. The mod function does not exist in Octave. There is only 
a slight difference between the two functions.

Avoid indexing using 'end'. Indexing using 'end' does not work in Octave.

Avoid using char. The char function does not work in Octave. Use sprintf instead. 

