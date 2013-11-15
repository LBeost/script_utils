#!/bin/bash
#
# convert2UTF8.sh
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.


##
# This simple tool is designed to convert .java files to UTF-8

destcoding="UTF-8"

## converting...
for file in $(find . -iname '*.java'); do
		coding=$(file "$file" | awk '{print$2}')
		if [ "$coding" == "ASCII" ]; then
				#echo "o converting $file from $coding to UTF-8"
				iconv --from-code=$coding --to-code=$destcoding "$file" > "$file.new"
		elif [ "$coding" == "ISO-8859" ]; then
				#echo "o converting $file from $coding-1 to UTF-8"
				iconv --from-code=$coding-1 --to-code=$destcoding "$file" > "$file.new"
		else
				if [ "$coding" != "UTF-8" ]; then
						echo "> unsupported $coding for $file"
				fi
		fi
done

## writting ;)
for file in $(find . -iname '*.java.new'); do mv "$file" "$(echo $file | sed 's/.new//g')"; done
