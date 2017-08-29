#!/bin/bash
# remotekke: archive fet files and send to ogier for processing

# find and archive files used by KlustaKwik
find . -name "*fet*" | xargs tar -cvf kk.tar
# get hostname and current directory
machine=`hostname`
destdir=`pwd`
# create shell script to copy final files from ogier back to current 
# directory
echo '#!/bin/bash
machine="MNAME"
destdir="DNAME"

scp kk2.tar ${machine}:${destdir}
ssh $machine "cd $destdir; tar -xvf kk2.tar; rm kk.tar kk2.tar"
' > scpdir1
# replace MNAME and DNAME with the appropriate hostname and current 
# directory
sed -e "s/MNAME/$machine/" -e "s:DNAME:$destdir:" scpdir1 > scpdir
# copy KlutaKwik files and shell script to ogier
scp kk.tar scpdir ogier:~/home/kk
# unpack the files on ogier and launch KlustaKwik
ssh ogier "cd home/kk; tar -xvf kk.tar; find . -name 'FD' -type d | xargs kkewrapper 5 30 1; "
rm scpdir1 scpdir
