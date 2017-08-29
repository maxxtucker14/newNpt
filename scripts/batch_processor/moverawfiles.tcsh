#!/bin/tcsh -f
# usage: moverawfiles dayname numberSessions
# 	e.g. moverawfiles annie052102 10

set day = $argv[1]
echo $day

@ sessions = $argv[2]
@ count = 1
while ( $count <= $sessions )
	set nsession = `printf %02i\\n $count`
	echo $nsession
	mkdir $nsession
	set session = ${day}${nsession}
	mv ${session}* $nsession
	# echo mv $session $nsession
	@ count++
end
