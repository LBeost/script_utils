#!/bin/bash
#
# autoconvert.sh
#
# Copyright 2013 LBeost
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.


## HOW TO USE
#
# Simply run this script on the command line : autoconvert.sh ~/directory/
# or add a single line in your crontab :
# */5 * * * *      su -s /bin/bash your-user -c 'bash ~/autoconvert.sh ~/directory/'
#
###############


## functions
# display usage and exit
display_usage() {
	echo "usage : ${0##*/} <directory>"
}

## setting some variables and checking dependencies
# variables
workDir="$1"
nicelvl="-n19"
avconv=$(which avconv)
awk=$(which awk)
nice=$(which nice)
# checking paths
if [ -z $avconv ] || [ ! -f $avconf ]; then
	echo "avconv not found"
	exit -1
fi
if [ -z $awk ] || [ ! -f $awk ]; then
	echo "awk not found"
	exit -1
fi
if [ -z $nice ] || [ ! -f $nice ]; then
	echo "nice not found"
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
find $workDir -name '*.mp4' -o -name '*.mkv' -o -name '*.avi' -o -name '*.wmv' | while read f; do
	newFile="${f%.*}.SD.mkv"
	width=$($avconv -i "$f" 2>&1 | gawk '{ match($0,/(Stream #0)(.*)Video:.*, ([0-9]*)x([0-9]*)(.*)/,r); if (RSTART>0) { printf "%s\n", r[3] } }')
	if [ "$f" == "${f/SD.mkv/}" ] && [ ! -f "$newFile" ]; then
		# no encoded version found
		if [ $width -gt 1200 ]; then
			# must re-encode to SD if width > 1200
			$nice $nicelvl $avconv -y -i "$f" -vcodec libx264 -preset fast -crf 22 \
				-r 23.976 -s 704x396 -threads 0 -v info -acodec libmp3lame \
				-b:a 192k -ac 2 -sn "$newFile" ; returnValue=$?
		fi
		# if encoding is successfull, remove high quality version
		if [ $returnValue == 0 ]; then
			rm -f "$f"
		fi
	fi
done

