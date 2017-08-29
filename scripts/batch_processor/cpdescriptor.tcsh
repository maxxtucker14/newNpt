#!/bin/tcsh -f
# cpdescriptor "( 02 03 )" ../070703/01/disco07070301_descriptor.txt
# cpdescriptor "( ?? )" ../070703/01/disco07070301_descriptor.txt

set dname = `pwd | awk '{n = split($1, a, "/"); print tolower(a[n-1])a[n]}' -`

foreach s $1
	set sname = `echo ${s} | sed 's/session//'`
	cp $2 ${s}/$dname${sname}_descriptor.txt
end
