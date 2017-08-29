#!/bin/tcsh -f
# usage: tolower.tcsh [dir]
if( $1 != "") then
	cd $1
endif
	
foreach i (*[A-Z]*)
	set nfile = `echo $i | tr A-Z a-z`
	echo "Renaming ${i} to ${nfile}"
	mv ${i} temp
	mv temp ${nfile}
end
