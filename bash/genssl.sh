#!/bin/bash
#
# genssl.sh
# SSL certificates generator for NGiNX :]
#
# Copyright 2015 LBeost
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

## Configuration - Feel free to modify default values
cfg_keysize=4096
cfg_password="password"
cfg_country="FR"
cfg_state="Some-State"
cfg_locality="city"
cfg_organisation="Internet Widgits Pty Ltd"
cfg_mail="user@domain.tld"

## Functions
# ask a yes-no question (until "y" or "n" replied) and put result in $answer
yes_no_question() {
	question=$1
	echo $question
	read answer
	while [ ! -z $answer ] && [ "$answer" != "y" ] && [ "$answer" != "n" ]; do
		echo $question
		read answer
	done
}
# ask a question and store result into $answer
std_question() {
	question=$1
	echo $question
	read answer
	while [ -z $answer ]; do
		echo $question
		read answer
	done
}


## Main
# ask for certificate
std_question "Type your domain name, followed by [ENTER]"
domain=$answer

# set some variables
keyfile="$domain"".key"
csrfile="$domain"".csr"
crtfile="$domain"".crt"
dpkeyfile="$domain"".deprotected.key"

# check if certificate exists
if [ -f $keyfile ]; then
	yes_no_question "File '"$keyfile"' already exists. Overwrite (y/n [n])"
	if [ -z $answer ] || [ "$answer" == "n" ]; then
		echo "$keyfile not overwritten."
		exit -1
	fi
fi

# generate some keys
echo -ne "o Generating keys: please wait... [1/3]\r"
openssl genrsa -des3 -passout pass:$cfg_password -out $keyfile $cfg_keysize > /dev/null 2>&1

echo -ne "o Generating keys: please wait... [2/3]\r"
openssl req -new -sha512 -key $keyfile -passin pass:$cfg_password \
-subj "/C=$cfg_country/ST=$cfg_state/L=$cfg_locality/CN=$domain" \
-out $csrfile > /dev/null 2>&1

echo -ne "o Generating keys: please wait... [3/3]\r"
openssl rsa -in $keyfile -passin pass:$cfg_password -out $dpkeyfile > /dev/null 2>&1

echo
echo "o Generating keys: done !"

# display generated certificate request
echo
echo "Please paste this content to your SSL authority and press [ENTER]"
cat $csrfile
read dummy

# and ask for authority's certificate
echo
echo "Paste the content of your authority's reply here and press [ENTER]"
rm -f "$crtfile"
while read line; do
	[ -z "$line" ] && break
	echo "$line" >> $crtfile
done

echo
echo -ne "Your cerficates :
o $crtfile : your certificate
o $csrfile : your certificate request
o $keyfile : you key-file
o $dpkeyfile : your unprotected key-file"

echo
echo
echo "Just configure your webserver with the SSL keys files ('"$keyfile"' and '"$crtfile"')\
 and you're done!"
