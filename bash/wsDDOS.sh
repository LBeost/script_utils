#!/bin/sh
# wsDDOS.sh
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

### CONFIG:
# host and port : replace with YOUR IP address and PORT
HOST="127.0.0.1"
PORT="44400"
# requests per second
RQS="3"

if [ "$1" == "install" ]; then
	iptables -N WSWGSF
	iptables -I INPUT 1 -p udp --dport $PORT -d $HOST -m u32 --u32 "0x20=0x67657473&&0x24=0x74617475&&0x25&0xff=0x73" -j WSWGSF
	iptables -A WSWGSF -m recent --set --name wswflood
	iptables -A WSWGSF -m recent --update --seconds 1 --hitcount $RQS --name wswflood --rsource -j LOG --log-prefix "firewall : war§sow getstatus flood " --log-level info
	iptables -A WSWGSF -m recent --update --seconds 1 --hitcount $RQS --name wswflood --rttl -j DROP
	iptables -A WSWGSF -j ACCEPT
	echo "installed :)"
elif [ "$1" == "remove" ]; then
	iptables -D INPUT -p udp --dport $PORT -d $HOST -m u32 --u32 "0x20=0x67657473&&0x24=0x74617475&&0x25&0xff=0x73" -j WSWGSF
	iptables -D WSWGSF -m recent --set --name wswflood
	iptables -D WSWGSF -m recent --update --seconds 1 --hitcount $RQS --name wswflood --rsource -j LOG --log-prefix "firewall : war§sow getstatus flood " --log-level info
	iptables -D WSWGSF -m recent --update --seconds 1 --hitcount $RQS --name wswflood --rttl -j DROP
	iptables -D WSWGSF -j ACCEPT
	iptables -X WSWGSF
	echo "removed :)"
else
	echo "Usage:"
	echo -e "${0##*/} install : add iptables rules"
	echo -e "${0##*/} remove : delete iptables rules"
	exit
fi
