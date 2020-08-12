#!/bin/bash
#
# convert2UTF8.sh
#
# Copyright (C) 2013-2020 laurent beost
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <https://www.gnu.org/licenses>.
# Additional permission under GNU GPL version 3 section 7
#
# If you modify this Program, or any covered work, by linking or combining
# it with [name of library] (or a modified version of that library),
# containing parts covered by the terms of [name of library's license],
# the licensors of this Program grant you additional permission to convey
# the resulting work.



###
# This simple tool is designed to convert specific files to UTF-8
#

## config
dest_coding="utf-8"
file_type="java"

## converting
for file in $(find . -name "*.$file_type"); do
		coding=$(file --mime-encoding "$file" | awk '{print$2}')
		# convert from crlf to lf
		#sed -i -e 's/\x0D$//' $file
		# convert to UTF-8
		if [ "$coding" == "ASCII" ] || [ "$coding" == "us-ascii" ] || [ "$coding" == "ISO-8859" ]; then
				echo "o converting $file from $coding to $dest_coding"
				iconv --from-code=$coding --to-code=$dest_coding "$file" > "$file.new"
				mv "$file.new" "$(echo $file | sed 's/.new$//g')"
		else
				if [ "$coding" != "$dest_coding" ]; then
						echo "> unsupported $coding for $file"
				fi
		fi
done

echo "done!"

# remove tmp files
#find . -name '*.new' -delete
