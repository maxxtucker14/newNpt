#!/bin/tcsh -f
# usage: moveprocessedfiles

foreach nsession (*[0-9][0-9])
	# make sure it is a directory
	if (-e $nsession) then
		echo $nsession
		cd $nsession
	
		# check to see if there are any eyefilt files
		# added grep -v command to prevent stderr output from showing up
		@ nfiles = `ls -1 *_eyefilt.* |& grep -v No | wc -l`
		if ($nfiles > 0) then
			echo "  eyefilt:"
			# check if the eyefilt directory exists
			if (-e eyefilt) then
				# remove files and directories in eyefilt directory
				# to prevent confusion
				echo "    removing contents of eyefilt directory"
				rm -r eyefilt/*
			else
				echo "    creating eyefilt directory"
				mkdir eyefilt
			endif
			echo "    moving eyefilt files"
			mv *_eyefilt.* eyefilt
		endif
		
		# check to see if there are any eye files
		@ nfiles = `ls -1 *_eye.* |& grep -v No | wc -l`
		if ($nfiles > 0) then
			echo "  eye:"
			# check if the eye directory exists
			if (-e eye) then
				# remove files and directories in eye directory
				# to prevent confusion
				echo "    removing contents of eye directory"
				rm -r eye/*
			else
				echo "    creating eye directory"
				mkdir eye
			endif
			echo "    moving eye files"
			mv *_eye.* eye
		endif
	
		# check to see if there are any lfp files
		@ nfiles = `ls -1 *_lfp.* |& grep -v No | wc -l`
		if ($nfiles > 0) then
			echo "  lfp:"
			# check if the lfp directory exists
			if (-e lfp) then
				# remove files and directories in lfp directory
				# to prevent confusion
				echo "    removing contents of lfp directory"
				rm -r lfp/*
			else
				echo "    creating lfp directory"
				mkdir lfp
			endif
			echo "    moving lfp files"
			mv *_lfp.* lfp
		endif
	
		# check to see if there are any highpass files
		@ nfiles = `ls -1 *_highpass.* |& grep -v No | wc -l`
		if ($nfiles > 0) then
			echo "  highpass:"
			# check if the highpass directory exists
			if (-e highpass) then
				# remove files and directories in highpass directory
				# to prevent confusion
				echo "    removing contents of highpass directory"
				rm -r highpass/*
			else
				echo "    creating highpass directory"
				mkdir highpass
			endif
			echo "    moving highpass files"
			mv *_highpass.* highpass
		endif
	
		# check to see if there are any dat, hdr of cfg files
		@ nfiles = `ls -1 *.dat *.hdr *.cfg *waveforms.bin |& grep -v No | wc -l`
		if ($nfiles > 0) then
			echo "  sort:"
			# check if there is a sort directory
			if (-e sort) then
				# remove files and directories in sort directory
				# to prevent confusion
				echo "    removing contents of sort directory"
				rm -r sort/*
			else
				echo "    creating sort directory"
				mkdir sort
			endif
			echo "    moving sort files"
			mv *.dat *.hdr *.cfg *waveforms.bin sort
		endif
		
		# check to see if there is a FD directory
		if (-e FD) then
			echo "  FD:"
			# check if there is a sort directory
			if (-e sort) then
				# check if there is a FD directory already
				if (-e sort/FD) then
					echo "    removing contents of sort/FD directory"
					# remove FD directory
					rm -r sort/FD
				endif
			else
				echo "    creating sort directory"
				# no sort directory so create one and move FD into it
				mkdir sort
			endif
			# move FD directory to sort
			echo "    moving FD directory"
			mv FD sort
		endif

		cd ..
	endif
end
