#!/bin/bash
# cpdescriptor ../070703/01/disco07070301_descriptor.txt

for i in $( find . -name "*[0-9].0001" ); do
	ses=`echo $i | sed -e 's/.0001/_descriptor.txt/'`;
	cp $1 $ses;
done
