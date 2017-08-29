#!/bin/bash
# usage: moveprocessedfiles

for nsession in $( ls -1d *[0-9][0-9] ); do
	# make sure it is a directory
	if [ -d $nsession ];  then
		echo $nsession
		cd $nsession
	
		# check to see if there are any eyefilt files
		# added grep -v command to prevent stderr output from showing up
		nfiles=`ls -1 *_eyefilt.* 2>&1 | grep -v No | wc -l`
		if [ "$nfiles" -gt 0 ]; then
			echo "  eyefilt:"
			# check if the eyefilt directory exists
			if [ -d eyefilt ]; then
				# remove files and directories in eyefilt directory
				# to prevent confusion
				echo "    removing contents of eyefilt directory"
				rm -r eyefilt/*
			else
				echo "    creating eyefilt directory"
				mkdir eyefilt
			fi
			echo "    moving eyefilt files"
			mv *_eyefilt.* eyefilt
		fi
		
		# check to see if there are any eye files
		nfiles=`ls -1 *_eye.* 2>&1 | grep -v No | wc -l`
		if [ "$nfiles" -gt 0 ]; then
			echo "  eye:"
			# check if the eye directory exists
			if [ -d eye ]; then
				# remove files and directories in eye directory
				# to prevent confusion
				echo "    removing contents of eye directory"
				rm -r eye/*
			else
				echo "    creating eye directory"
				mkdir eye
			fi
			echo "    moving eye files"
			mv *_eye.* eye
		fi
	
		# check to see if there are any lfp files
		nfiles=`ls -1 *_lfp.* 2>&1 | grep -v No | wc -l`
		if [ "$nfiles" -gt 0 ]; then
			echo "  lfp:"
			# check if the lfp directory exists
			if [ -d lfp ]; then
				# remove files and directories in lfp directory
				# to prevent confusion
				echo "    removing contents of lfp directory"
				rm -r lfp/*
			else
				echo "    creating lfp directory"
				mkdir lfp
			fi
			echo "    moving lfp files"
			mv *_lfp.* lfp
		fi
	
		# check to see if there are any highpass files
		nfiles=`ls -1 *_highpass.* 2>&1 | grep -v No | wc -l`
		if [ "$nfiles" -gt 0 ]; then
			echo "  highpass:"
			# check if the highpass directory exists
			if [ -d highpass ]; then
				# remove files and directories in highpass directory
				# to prevent confusion
				echo "    removing contents of highpass directory"
				rm -r highpass/*
			else
				echo "    creating highpass directory"
				mkdir highpass
			fi
			echo "    moving highpass files"
			mv *_highpass.* highpass
		fi
	
		# check to see if there are any dat, hdr of cfg files
		nfiles=`ls -1 *.dat *.hdr *.cfg *waveforms.bin 2>&1 | grep -v No | wc -l`
		if [ "$nfiles" -gt 0 ]; then
			echo "  sort:"
			# check if there is a sort directory
			if [ -d sort ]; then
				# remove files and directories in sort directory
				# to prevent confusion
				echo "    removing contents of sort directory"
				rm -r sort/*
			else
				echo "    creating sort directory"
				mkdir sort
			fi
			echo "    moving sort files"
			mv *.dat *.hdr *.cfg *waveforms.bin sort
		fi
		
		# check to see if there is a FD directory
		if [ -d FD ]; then
			echo "  FD:"
			# check if there is a sort directory
			if [ -d sort ]; then
				# check if there is a FD directory already
				if [ -d sort/FD ]; then
					echo "    removing contents of sort/FD directory"
					# remove FD directory
					rm -r sort/FD
				fi
			else
				echo "    creating sort directory"
				# no sort directory so create one and move FD into it
				mkdir sort
			fi
			# move FD directory to sort
			echo "    moving FD directory"
			mv FD sort
		fi

		cd ..
	fi
done
