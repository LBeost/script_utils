#!/bin/sh
#
# vacuumFirefox.sh
#
# Copyright 2010 LBeost
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

mozDir="$HOME/.mozilla/firefox/"
sqlite=$(which sqlite3)	# find sqlite binary
firefoxDir="$mozDir$(ls $mozDir | grep '\.default$')/" #find default profile

# check if sqlite binary exists
if [ -z $sqlite ] || [ ! -f $sqlite ]; then
	echo "> Sqlite v3 binary not found, abording..."
	exit
fi

# check if version is REALLY >= 3
sqliteVersion=$($sqlite --version | awk '{print$1}' 2> /dev/null)
if [ -n "$sqliteVersion" ] && [ "${sqliteVersion:0:1}" == "3" ]; then
	echo "o Sqlite v$sqliteVersion detected : ok"
else
	echo "> Sqlite must be > 3.0.0.0"
fi

# waiting firefox to be closed
if [ $(pgrep -x firefox) ] || [ $(pgrep -x firefox-bin) ]; then
	echo "o Waiting for firefox to be closed..."
	while [ $(pgrep -x firefox) ] || [ $(pgrep -x firefox-bin) ]; do sleep .5; done
fi

# just add empty line to separate "Please close firefox.." junk
if [ ! -z $stty_orig ]; then echo; fi

# replacing Google with HTTPS version :)
#$sqlite "$firefoxDir/chromeappsstore.sqlite" "INSERT OR REPLACE INTO \"webappsstore2\" VALUES('emoh.:moz-safe-about','search-engine','{\"name\":\"Google\",\"searchUrl\":\"https://www.google.com/search?q=_searchTerms_&ie=utf-8\"}',0,NULL);"


## remove useless print features form prefs.js
prefsJS="$firefoxDir/prefs.js"
prefsJSold="$firefoxDir/prefs.js.BAK"
if [ -f $prefsJS ]; then
	mv $prefsJS $prefsJSold
	awk '!/print.tmp.print/ && !/printer/' $prefsJSold > $prefsJS
fi

# processing every .sqlite files
echo "o Firefox is closed, running vacuum tasks..."
#for file in $(ls "$firefoxDir*.sqlite"); do
for file in $(ls "$firefoxDir" | grep '\.sqlite$'); do
#for file in $(ls "$firefoxDir" "$firefoxDir/OfflineCache" | grep '\.sqlite$'); do
	file="$firefoxDir$file"
	# check if file is REALLY an SQLite file
	if [ "$(file $file | awk '{print($2)}')" == "SQLite" ]; then
		size=$(ls -lh $file | awk '{print($5)}')
		# cleanning by using sqlite VACUUM command
		# which does NOT remove any files
		echo -en "> Processing ${file##*/} ($size)... [1/2]\r";
		$sqlite $file VACUUM;
		# reindexing too
		echo  -en "> Processing ${file##*/} ($size)... [2/2]\r";
		$sqlite $file REINDEX;
		nsize=$(ls -lh $file | awk '{print($5)}')
		echo  "> Processing ${file##*/} ($size > $nsize)... [ok]";
	fi
done

echo
echo "o Flushing file system buffers..."
sync
echo "Job done, enjoy faster firefox ;-)"
