#!/bin/bash

## functions
# display usage and exit
display_usage() {
	echo "usage : ${0##*/} <directory>"
}

## setting some variables and checking dependencies
# variables
workDir="$1"
avconv=$(which avconv)
awk=$(which awk)
# checking paths
if [ -z $avconv ] || [ ! -f $avconf ]; then
	echo "avconv not found"
	exit -1
fi
if [ -z $awk ] || [ ! -f $awk ]; then
	echo "awk not found"
	exit -1
fi

## checking if encoder is already running
process=$(ps ax | awk '/'"${avconv##*/}"'/ && !/awk/')
if [ ! -z "$process" ]; then
	echo "${0##*/} is already running, stopping right now"
	exit -2
fi


## checking proper usage
if [ -z "$workDir" ]; then
	display_usage
	exit
fi
if [ ! -d "$workDir" ]; then
	echo "no such directory : $workDir"
	display_usage
	exit -1
fi


## main : find media files in order to encode them
find $workDir -name '*.mp4' -o -name '*.mkv' -o -name '*.avi' | while read f; do
	newFile="${f%.*}.CONVERTED.mkv"
	width=$($avconv -i "$f" 2>&1 | gawk '{ match($0,/(Stream #0)(.*)Video:.*, ([0-9]*)x([0-9]*)(.*)/,r); if (RSTART>0) { printf "%s\n", r[3] } }')
	if [ "$f" == "${f/CONVERTED.mkv/}" ] && [ ! -f "$newFile" ]; then
		# no encoded version found
		if [ $width -gt 1200 ]; then
			# must re-encode to SD if width > 1200
			$avconv -y -i "$f" -vcodec libx264 -preset fast -crf 25 \
				-r 23.976 -s 704x396 -threads 0 -v info \
				-acodec libmp3lame -b:a 128k -sn "$newFile"
		fi
	fi
done
