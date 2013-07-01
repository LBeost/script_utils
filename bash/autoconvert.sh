#!/bin/bash

workDir="complete/"

pid=$(ps ax | awk '/avconv/ && !/awk/')
if [ ! -z "$pid" ]; then
	#echo "already running, stopping right now"
	exit
fi

# find media files
find $workDir -name '*.mp4' -o -name '*.mkv' -o -name '*.avi' | while read f; do
	newFile="${f%.*}.CONVERTED.mkv"
	width=$(avconv -i "$f" 2>&1 | gawk '{ match($0,/(Stream #0)(.*)Video:.*, ([0-9]*)x([0-9]*)(.*)/,r); if (RSTART>0) { printf "%s\n", r[3] } }')
	if [ "$f" == "${f/CONVERTED.mkv/}" ] && [ ! -f "$newFile" ]; then
		# no encoded version found
		if [ $width -gt 1200 ]; then
			# must re-encode to SD if width > 1200
			avconv -y -i "$f" -vcodec libx264 -preset fast -crf 25 \
				-r 23.976 -s 704x396 -threads 0 -v info \
				-acodec libmp3lame -b:a 128k -sn "$newFile"
		fi
	fi
done
